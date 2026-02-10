-- MATRIX NAVIGATION MODULE V1.0
-- Description: Advanced pathfinding to avoid obstacles.

local PathfindingService = game:GetService("PathfindingService")
local Navigation = {}

function Navigation.WalkTo(targetPosition)
    local character = game.Players.LocalPlayer.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")

    -- Útvonal tervezése: nagyobb rádiusz az asztalok elkerüléséhez
    local path = PathfindingService:CreatePath({
        AgentRadius = 3, 
        AgentCanJump = true,
        WaypointSpacing = 4
    })

    local success, _ = pcall(function()
        path:ComputeAsync(root.Position, targetPosition)
    end)

    if success and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        for _, waypoint in ipairs(waypoints) do
            if not _G.AutoFarm then break end
            
            if waypoint.Action == Enum.PathWaypointAction.Jump then
                humanoid.Jump = true
            end
            
            humanoid:MoveTo(waypoint.Position)
            
            local reached = false
            local conn = humanoid.MoveToFinished:Connect(function() reached = true end)
            
            local timeout = 0
            while not reached and timeout < 2 do
                task.wait(0.1)
                timeout = timeout + 0.1
                -- Anti-stuck: ha beragad, ugrik egyet
                if humanoid.MoveDirection.Magnitude == 0 and timeout > 0.5 then
                    humanoid.Jump = true
                end
            end
            conn:Disconnect()
        end
        return true
    end
    return false
end

return Navigation
