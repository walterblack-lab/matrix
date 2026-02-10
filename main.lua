-- Matrix Hub V1.0
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "MATRIX PRO HUB",
   LoadingTitle = "Bypassing BlockSpin Anti-Cheat...",
   LoadingSubtitle = "by Matrix Developer",
   ConfigurationSaving = { Enabled = false }
})

local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
_G.AutoFarm = false

FarmTab:CreateToggle({
   Name = "Auto Puddle Sweep",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoFarm = Value
      if Value then
         task.spawn(function()
            while _G.AutoFarm do
               task.wait(0.1)
               pcall(function()
                  local root = game.Players.LocalPlayer.Character.HumanoidRootPart
                  -- A Hermanos fájlokból kinyert útvonal:
                  local puddles = workspace:FindFirstChild("Debris") and workspace.Debris:FindFirstChild("Puddles")
                  
                  if puddles then
                     for _, p in pairs(puddles:GetChildren()) do
                        if not _G.AutoFarm then break end
                        if (root.Position - p.Position).Magnitude < 150 then
                           root.CFrame = p.CFrame + Vector3.new(0, 1, 0)
                           firetouchinterest(root, p, 0)
                           task.wait(0.05)
                           firetouchinterest(root, p, 1)
                           break
                        end
                     end
                  end
               end)
            end
         end)
      end
   end,
})

Rayfield:Notify({
   Title = "Matrix Loaded!",
   Content = "Source: Hermanos-Tools Integrated",
   Duration = 5
})
