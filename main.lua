-- MATRIX HUB V1.5 - THE CLEAN VERSION
-- Logic: Independent from external cleaners. Focused purely on detection.

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "MATRIX PRO | V1.5",
   LoadingTitle = "Starting Clean Engine...",
   ConfigurationSaving = { Enabled = false }
})

local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
_G.AutoFarm = false

FarmTab:CreateToggle({
   Name = "Ultimate Puddle Farm",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoFarm = Value
      if Value then
         task.spawn(function()
            while _G.AutoFarm do
               task.wait(0.2) -- Gyorsabb reakcióidő
               pcall(function()
                  local player = game.Players.LocalPlayer
                  local character = player.Character
                  local root = character and character:FindFirstChild("HumanoidRootPart")
                  
                  if not root then return end

                  -- KERESÉS A TELJES JÁTÉKBAN (Mindenre kiterjedő)
                  for _, object in pairs(workspace:GetDescendants()) do
                     if not _G.AutoFarm then break end
                     
                     -- Minden olyan tárgyat nézünk, aminek köze lehet a takarításhoz
                     if object:IsA("TouchInterest") and object.Parent:IsA("BasePart") then
                        local p = object.Parent
                        -- Csak akkor megyünk oda, ha a neve "Puddle", "Spill", vagy "Liquid" (Hermanos-logic)
                        if p.Name:find("Puddle") or p.Name:find("Spill") or p.Name:find("Mess") then
                           
                           -- Teleport a pocsolya fölé
                           root.CFrame = p.CFrame + Vector3.new(0, 1, 0)
                           
                           -- Virtuális érintés (firetouchinterest)
                           firetouchinterest(root, p, 0)
                           task.wait(0.05)
                           firetouchinterest(root, p, 1)
                           
                           print("Matrix: Found and Cleaned: " .. p.Name)
                           task.wait(0.1) -- Rövid szünet a következő előtt
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
