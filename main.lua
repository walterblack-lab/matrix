-- MATRIX HUB V2.0 - PATHFINDING ENGINE
-- Logic: Human-like walking to prevent teleport detection.

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "MATRIX | ANTI-DETECTION", LoadingTitle = "Bypassing Server Checks..."})
local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
_G.AutoFarm = false

FarmTab:CreateToggle({
   Name = "Safe Human Walk Farm",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoFarm = Value
      if Value then
         task.spawn(function()
            while _G.AutoFarm do
               task.wait(0.1)
               pcall(function()
                  local player = game.Players.LocalPlayer
                  local character = player.Character
                  local humanoid = character:FindFirstChildOfClass("Humanoid")
                  local root = character:FindFirstChild("HumanoidRootPart")
                  
                  if not humanoid or not root then return end

                  -- KERESÉS: Megkeressük a legközelebbi pocsolyát
                  local closestPuddle = nil
                  local shortestDist = 150 -- Csak a közeli pocsolyákat nézzük

                  for _, v in pairs(workspace:GetDescendants()) do
                     if v:IsA("BasePart") and (v.Name:lower():find("puddle") or v.Name:lower():find("spill")) then
                        local dist = (root.Position - v.Position).Magnitude
                        if dist < shortestDist then
                           shortestDist = dist
                           closestPuddle = v
                        end
                     end
                  end

                  -- MOZGÁS: Ha találtunk egyet, odasétálunk
                  if closestPuddle then
                     print("Matrix: Walking to puddle: " .. closestPuddle.Name)
                     
                     -- A Humanoid:MoveTo() parancs elindítja a sétát
                     humanoid:MoveTo(closestPuddle.Position)
                     
                     -- Megvárjuk, amíg odaér (vagy amíg 8 másodperc eltelik)
                     local reached = false
                     local connection
                     connection = humanoid.MoveToFinished:Connect(function()
                        reached = true
                        connection:Disconnect()
                     end)
                     
                     -- Addig várunk itt, amíg oda nem érünk a pocsolyához
                     local timeout = 0
                     while not reached and _G.AutoFarm and timeout < 8 do
                        task.wait(0.1)
                        timeout = timeout + 0.1
                     end
                     
                     -- Megérkeztünk, várunk a takarításra
                     if reached then
                        print("Matrix: Reached target. Cleaning...")
                        task.wait(1.5) 
                     end
                  end
               end)
            end
         end)
      end
   end,
})
