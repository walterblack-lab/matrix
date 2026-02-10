-- MATRIX HUB V3.2 - ULTIMATE FAILSAFE
-- Description: Dynamic cleaning check to bypass CoreGui and Animation errors.

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Navigation = loadstring(game:HttpGet("https://raw.githubusercontent.com/walterblack-lab/matrix/refs/heads/main/navigation.lua"))()

_G.AutoFarm = false
local IgnoreList = {}

local Window = Rayfield:CreateWindow({
   Name = "MATRIX | ANTI-FREEZE V3.2",
   LoadingTitle = "Bypassing Game Errors...",
   ConfigurationSaving = { Enabled = false }
})

local FarmTab = Window:CreateTab("Auto Farm", 4483362458)

FarmTab:CreateToggle({
   Name = "Dynamic Cleaning Farm",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoFarm = Value
      if Value then
         task.spawn(function()
            while _G.AutoFarm do
               task.wait(0.5)
               pcall(function()
                  local root = game.Players.LocalPlayer.Character.HumanoidRootPart
                  local target = nil
                  local minDist = 200

                  -- 1. KERESÉS
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

                  -- 2. MOZGÁS ÉS OKOS VÁRAKOZÁS
                  if target then
                     local reached = Navigation.WalkTo(target.Position)
                     
                     if reached then
                        IgnoreList[target] = true
                        print("Matrix: Standing on puddle. Monitoring progress...")
                        
                        local startTime = tick()
                        local timeLimit = (target.Size.Magnitude > 10) and 13 or 8
                        
                        -- FAILSAFE CIKLUS: Addig várunk, amíg ott a folt, 
                        -- DE ha lefagy a játék (piros hiba), az időkorlát továbbléptet.
                        while target and target.Parent == workspace and target.Transparency < 1 and _G.AutoFarm do
                           task.wait(0.5)
                           if (tick() - startTime) > timeLimit then
                              warn("Matrix: Game freeze detected (Animation/UI error). Forcing next target.")
                              break 
                           end
                        end
                        print("Matrix: Spot cleared or bypassed.")
                     end
                  end
               end)
            end
         end)
      else
         IgnoreList = {}
      end
   end,
})

-- Settings / Manual Reset
local SettingsTab = Window:CreateTab("Settings", 4483362458)
SettingsTab:CreateButton({
   Name = "Clear Ignore List (If stuck)",
   Callback = function()
      IgnoreList = {}
      Rayfield:Notify({Title = "System Reset", Content = "Ignore list cleared!", Duration = 2})
   end,
})

SettingsTab:CreateButton({
   Name = "Unload",
   Callback = function()
      _G.AutoFarm = false
      Rayfield:Destroy()
   end,
})
