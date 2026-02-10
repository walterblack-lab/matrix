-- MATRIX NAVIGATION MODULE V1.3 - ANTI-ANIMATION LOCK
-- Description: Bypasses animation-related freezes.

local PathfindingService = game:GetService("PathfindingService")
local Navigation = {}

function Navigation.WalkTo(targetPosition)
    local character = game.Players.LocalPlayer.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")

    -- Kényszerített állapot-reset: Megszakítjuk a beragadt animációkat
    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        track:Stop()
    end

    local path = PathfindingService:CreatePath({
        AgentRadius = 2.0,
        AgentCanJump = true,
        WaypointSpacing = 2
    })

    local success, _ = pcall(function()
        path:ComputeAsync(root.Position, targetPosition)
    end)

    if success and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        for i, waypoint in ipairs(waypoints) do
            if not _G.AutoFarm then break end
            
            -- Ha a piros hiba miatt a humanoid "PlatformStand" vagy "Seated" állapotba kerülne, reseteljük
            humanoid.PlatformStand = false
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

            humanoid:MoveTo(waypoint.Position)
            
            local reached = false
            local conn = humanoid.MoveToFinished:Connect(function() reached = true end)
            
            local timeout = 0
            while not reached and timeout < 1.2 do
                task.wait(0.1)
                timeout = timeout + 0.1
                -- Ha nem mozdulunk a piros hiba miatt, ugrással kényszerítjük a fizikai motort
                if humanoid.MoveDirection.Magnitude == 0 and timeout > 0.3 then
                    humanoid.Jump = true
                end
            end
            conn:Disconnect()
            if timeout >= 1.2 then break end
        end
        return true
    end
    return false
end

return Navigation
