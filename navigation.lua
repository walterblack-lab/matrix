-- MATRIX NAVIGATION V1.5 - PATHFINDING RESTORED
-- Description: Professional pathfinding with lag-protection.

local PathfindingService = game:GetService("PathfindingService")
local Navigation = {}

function Navigation.WalkTo(targetPosition)
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")

    -- Útvonal létrehozása (AgentRadius 2.5 az asztalok elkerüléséhez)
    local path = PathfindingService:CreatePath({
        AgentRadius = 2.5,
        AgentCanJump = true,
        WaypointSpacing = 3
    })

    -- Hibakezelés a számításnál (ha laggol a szerver)
    local success, _ = pcall(function()
        path:ComputeAsync(root.Position, targetPosition)
    end)

    if success and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        
        for i, waypoint in ipairs(waypoints) do
            if not _G.AutoFarm then break end
            
            if waypoint.Action == Enum.PathWaypointAction.Jump then
                humanoid.Jump = true
            end
            
            humanoid:MoveTo(waypoint.Position)
            
            -- OKOS VÁRAKOZÁS (Hibatűréssel)
            local reached = false
            local conn = humanoid.MoveToFinished:Connect(function() reached = true end)
            
            local timeout = 0
            while not reached and timeout < 1.5 do
                task.wait(0.1)
                timeout = timeout + 0.1
                -- Lagg elleni ugrás, ha beragadna a fizika
                if humanoid.MoveDirection.Magnitude == 0 and timeout > 0.5 then
                    humanoid.Jump = true
                end
            end
            conn:Disconnect()
            if timeout >= 1.5 then break end
        end
        return true
    end
    -- Ha a Pathfinding valamiért nem sikerül (lagg), egyenesen odafutunk (Fallback)
    humanoid:MoveTo(targetPosition)
    return false
end

return Navigation
