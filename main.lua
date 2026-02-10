-- MATRIX HUB V2.2 - UNLOAD & GHOST PROTECTION
-- Description: Added Unload function and fixed target re-locking.

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "MATRIX | V2.2 PRO",
   LoadingTitle = "Initializing Ghost Protection...",
   ConfigurationSaving = { Enabled = false }
})

local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

_G.AutoFarm = false
local IgnoreList = {} -- Ide kerülnek a már kitakarított pocsolyák

-- UNLOAD FUNKCIÓ
SettingsTab:CreateButton({
   Name = "Destroy Script (Unload)",
   Callback = function()
      _G.AutoFarm = false
      Rayfield:Destroy()
      print("Matrix: Script Unloaded Successfully")
   end,
})

FarmTab:CreateToggle({
   Name = "Smart Walk Farm (Improved)",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoFarm = Value
      if Value then
         task.spawn(function()
            while _G.AutoFarm do
               task.wait(0.5)
               pcall(function()
                  local player = game.Players.LocalPlayer
                  local root = player.Character.HumanoidRootPart
                  local humanoid = player.Character.Humanoid
                  
                  -- 1. KERESÉS (Kiszűrve az IgnoreList-et)
                  local target = nil
                  local minDist = 200

                  for _, v in pairs(workspace:GetDescendants()) do
                     if v:IsA("BasePart") and (v.Name:lower():find("puddle") or v.Name:lower():find("spill")) then
                        -- Csak ha nem voltunk még rajta ÉS nem átlátszó (már eltűnt)
                        if not IgnoreList[v] and v.Transparency < 1 then
                           local d = (root.Position - v.Position).Magnitude
                           if d < minDist then
                              minDist = d
                              target = v
                           end
                        end
                     end
                  end

                  -- 2. MOZGÁS ÉS TAKARÍTÁS
                  if target then
                     print("Matrix: New target found: " .. target.Name)
                     humanoid:MoveTo(target.Position)
                     
                     local reached = false
                     local conn = humanoid.MoveToFinished:Connect(function() reached = true end)
                     
                     -- Várunk amíg odaér (max 10mp)
                     local t = 0
                     while not reached and t < 10 and _G.AutoFarm do
                        task.wait(0.2)
                        t = t + 0.2
                     end
                     conn:Disconnect()

                     if reached then
                        -- Behelyezzük az ignore listába, hogy ne jöjjön vissza ide
                        IgnoreList[target] = true
                        
                        -- Dinamikus várakozás
                        local waitTime = (target.Size.Magnitude > 10) and 11 or 6
                        print("Matrix: Cleaning... Waiting " .. waitTime .. "s")
                        task.wait(waitTime)
                     end
                  end
               end)
            end
         end)
      else
         -- Ha kikapcsolod, ürítjük a listát, hogy legközelebb megint lássa őket
         IgnoreList = {}
      end
   end,
})
