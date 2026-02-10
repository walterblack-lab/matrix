-- MATRIX V1.8 - NO GUESSING EDITION
-- Code Description: Teleports only to active touch-zones within range.

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "MATRIX | FINAL FOCUS", LoadingTitle = "Locating Touch Zones..."})
local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
_G.AutoFarm = false

FarmTab:CreateToggle({
   Name = "Real Puddle Finder",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoFarm = Value
      if Value then
         task.spawn(function()
            while _G.AutoFarm do
               task.wait(0.5)
               pcall(function()
                  local root = game.Players.LocalPlayer.Character.HumanoidRootPart
                  -- Minden olyan tárgyat nézünk, ami interakcióba léphet veled
                  for _, v in pairs(workspace:GetDescendants()) do
                     if v:IsA("TouchInterest") and v.Parent:IsA("BasePart") then
                        local target = v.Parent
                        -- Csak a közeledben lévőket nézzük (100 stud), hogy ne repkedj össze-vissza
                        if (root.Position - target.Position).Magnitude < 100 then
                           -- IDE TELEPORTÁL: Pontosan a tárgy közepébe
                           root.CFrame = target.CFrame
                           print("Matrix: Standing on potential target: " .. target.Name)
                           task.wait(1) -- Idő a takarításhoz
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
