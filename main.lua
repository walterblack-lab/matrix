-- MATRIX HUB V1.2 - DEBUG MODE
-- Description: Professional targeting with console feedback

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "MATRIX DEBUG HUB",
   LoadingTitle = "Testing Puddle Sensors...",
   ConfigurationSaving = { Enabled = false }
})

local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
_G.AutoFarm = false

FarmTab:CreateToggle({
   Name = "Auto Sweep (Debug)",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoFarm = Value
      if Value then
         warn("Matrix: Farm Enabled!") -- Megjelenik a konzolban (F9)
         task.spawn(function()
            while _G.AutoFarm do
               task.wait(0.5)
               local success, err = pcall(function()
                  local root = game.Players.LocalPlayer.Character.HumanoidRootPart
                  
                  -- KERESÉS TÖBB HELYEN (Hermanos + Universal)
                  local target = nil
                  local debris = workspace:FindFirstChild("Debris")
                  local puddles = debris and debris:FindFirstChild("Puddles")
                  
                  if puddles and #puddles:GetChildren() > 0 then
                     target = puddles:GetChildren()[1]
                     print("Matrix: Found puddle in Debris folder")
                  else
                     -- Ha nincs a mappában, átnézzük a Workspace-t kulcsszóra
                     for _, obj in pairs(workspace:GetChildren()) do
                        if obj:IsA("BasePart") and (obj.Name:find("Puddle") or obj.Name:find("Water")) then
                           target = obj
                           print("Matrix: Found puddle in Workspace by Name: " .. obj.Name)
                           break
                        end
                     end
                  end

                  if target then
                     local dist = (root.Position - target.Position).Magnitude
                     if dist < 200 then
                        print("Matrix: Moving to target. Distance: " .. math.floor(dist))
                        root.CFrame = target.CFrame + Vector3.new(0, 1, 0)
                        firetouchinterest(root, target, 0)
                        task.wait(0.1)
                        firetouchinterest(root, target, 1)
                     else
                        warn("Matrix: Target too far! (" .. math.floor(dist) .. " studs)")
                     end
                  else
                     warn("Matrix: No puddles found on map!")
                  end
               end)
               if not success then warn("Matrix Error: " .. err) end
            end
         end)
      end
   end,
})
