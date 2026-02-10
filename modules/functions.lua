-- Matrix Functions Module
local Functions = {}

function Functions.TeleportTo(cframe)
    local root = game.Players.LocalPlayer.Character.HumanoidRootPart
    root.CFrame = cframe
end

function Functions.Sweep(target)
    local root = game.Players.LocalPlayer.Character.HumanoidRootPart
    firetouchinterest(root, target, 0)
    task.wait(0.05)
    firetouchinterest(root, target, 1)
end

return Functions
