-- MATRIX NAVIGATION MODULE V1.1
-- Description: Advanced pathfinding with stuck-prevention logic.

local PathfindingService = game:GetService("PathfindingService")
local Navigation = {}

function Navigation.WalkTo(targetPosition)
    local character = game.Players.LocalPlayer.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")

    local path = PathfindingService:CreatePath({
        AgentRadius = 2.5, -- Kicsit kisebb, hogy beférjen szűkebb helyekre is
        AgentCanJump = true,
        WaypointSpacing = 3
    })

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
            
            local reached = false
            local conn = humanoid.MoveToFinished:Connect(function() reached = true end)
            
            local timeout = 0
            local lastPos = root.Position
            
            while not reached and timeout < 1.5 do -- Rövidebb timeout a pörgősebb mozgáshoz
                task.wait(0.1)
                timeout = timeout + 0.1
                
                -- ELAKADÁS ELLENI ELLENŐRZÉS:
                if (root.Position - lastPos).Magnitude < 0.1 and timeout > 0.4 then
                    humanoid.Jump = true -- Megpróbál kiszabadulni ugrással
                end
                lastPos = root.Position
            end
            conn:Disconnect()
            
            -- Ha nagyon beragadt egy ponthoz, inkább szakítsuk meg ezt az utat
            if timeout >= 1.5 and not reached then
                warn("Matrix: Waypoint timeout, recalculating...")
                return false 
            end
        end
        return true
    end
    return false
end

return Navigation
