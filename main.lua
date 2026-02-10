-- MATRIX HUB V3.3 - THE "ERROR BYPASS" EDITION
-- Logic: Forced position reset if the game engine freezes.

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Navigation = loadstring(game:HttpGet("https://raw.githubusercontent.com/walterblack-lab/matrix/refs/heads/main/navigation.lua"))()

_G.AutoFarm = false
local IgnoreList = {}

local Window = Rayfield:CreateWindow({
   Name = "MATRIX HUB | V3.3 FIX",
   LoadingTitle = "Bypassing Engine Errors...",
   Theme = "Green",
   ConfigurationSaving = { Enabled = false }
})

local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

FarmTab:CreateToggle({
   Name = "Ultra Farm (Anti-Stuck)",
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
                  local target = nil
                  local minDist = 200

                  -- KERESÉS
                  for _, v in pairs(workspace:GetDescendants()) do
                     if v:IsA("BasePart") and v.Name:lower():find("puddle") then
                        if not IgnoreList[v] and v.Transparency < 1 then
                           local d = (root.Position - v.Position).Magnitude
                           if d < minDist then
                              minDist = d
                              target = v
                           end
                        end
                     end
                  end

                  if target then
                     -- MOZGÁS INDÍTÁSA
                     local moveTask = task.spawn(function()
                        Navigation.WalkTo(target.Position)
                     end)
                     
                     -- MÁSODIK FAILSAFE: Figyeljük, hogy tényleg mozgunk-e
                     local lastPos = root.Position
                     local stuckTime = 0
                     
                     while _G.AutoFarm and target and target.Parent == workspace do
                        task.wait(1)
                        -- Ha 3 másodperce ugyanott vagyunk, de még nem értünk oda
                        if (root.Position - lastPos).Magnitude < 1 then
                           stuckTime = stuckTime + 1
                           if stuckTime >= 3 then
                              warn("Matrix: ENGINE FREEZE DETECTED. FORCING RESET.")
                              player.Character.Humanoid.Jump = true -- Felébresztjük a fizikát
                              task.cancel(moveTask) -- Megszakítjuk a beragadt navigációt
                              break -- Új keresés indul
                           end
                        else
                           stuckTime = 0
                        end
                        lastPos = root.Position
                        
                        -- Ha odaértünk és eltűnt a pocsolya
                        if target.Transparency >= 1 or not target.Parent then break end
                     end
                     IgnoreList[target] = true
                  end
               end)
            end
         end)
      else
         IgnoreList = {}
      end
   end,
})

SettingsTab:CreateButton({
   Name = "Clear Ignore List & Reset UI",
   Callback = function()
      IgnoreList = {}
      Rayfield:Notify({Title = "System", Content = "Full Reset Complete", Duration = 3})
   end,
})

SettingsTab:CreateButton({
   Name = "Unload",
   Callback = function()
      _G.AutoFarm = false
      Rayfield:Destroy()
   end,
})
