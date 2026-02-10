-- MATRIX MOVER MODULE V4.0
-- Description: Physical movement controller with aggressive stuck prevention.

local Mover = {}

function Mover.MoveToPoint(targetPos, jumpRequired)
    local player = game.Players.LocalPlayer
    local character = player.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")

    if jumpRequired then humanoid.Jump = true end
    
    humanoid:MoveTo(targetPos)

    local reached = false
    local connection = humanoid.MoveToFinished:Connect(function() reached = true end)
    
    local startT = tick()
    local lastPos = root.Position

    while not reached and _G.AutoFarm do
        task.wait(0.1)
        
        -- Stuck check: Ha 0.6 másodpercig nem mozdulunk eleget
        if (tick() - startT) > 0.6 then
            if (root.Position - lastPos).Magnitude < 0.5 then
                humanoid.Jump = true -- Megpróbáljuk "átlökni" az asztalon
            end
            lastPos = root.Position
            startT = tick()
        end
        
        -- Timeout: Ne várjunk egy pontra 2 másodpercnél többet
        if (tick() - startT) > 2 then break end
    end
    
    if connection then connection:Disconnect() end
end

return Mover
