-- MATRIX HUB V1.9 - PURE POSITIONING
-- No touches, no chains, just walking simulation.

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "MATRIX | POSITION ONLY", LoadingTitle = "Scanning Floor..."})
local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
_G.AutoFarm = false

FarmTab:CreateToggle({
   Name = "Teleport to Puddles",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoFarm = Value
      if Value then
         task.spawn(function()
            while _G.AutoFarm do
               task.wait(1) -- Lassabb tempó, hogy a játék érzékelje az ottlétedet
               pcall(function()
                  local root = game.Players.LocalPlayer.Character.HumanoidRootPart
                  
                  -- Megkeressük a legközelebbi kék foltot (MeshPart vagy Part)
                  for _, v in pairs(workspace:GetDescendants()) do
                     if not _G.AutoFarm then break end
                     
                     -- BlockSpin specifikus keresés: a pocsolya neve vagy anyaga
                     if v:IsA("BasePart") and (v.Name:lower():find("puddle") or v.Name:lower():find("spill")) then
                        
                        -- Csak akkor megyünk oda, ha messzebb van mint 3 egység
                        local dist = (root.Position - v.Position).Magnitude
                        if dist > 3 and dist < 100 then
                           -- Teleport 1 egységgel a pocsolya FÖLÉ, hogy ráessél
                           root.CFrame = v.CFrame * CFrame.new(0, 1, 0)
                           print("Matrix: Arrived at puddle. Waiting for auto-clean...")
                           task.wait(2) -- Várunk, amíg a seprű magától felszívja
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
