-- MATRIX HUB V3.1 - MAIN CONTROLLER
-- Description: Modular controller that calls the navigation file.

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Itt hívjuk be a navigációs fájlt a GitHubról
local Navigation = loadstring(game:HttpGet("https://raw.githubusercontent.com/walterblack-lab/matrix/refs/heads/main/navigation.lua"))()

_G.AutoFarm = false
local IgnoreList = {}

local Window = Rayfield:CreateWindow({
   Name = "MATRIX HUB | V3.1 MODULAR",
   LoadingTitle = "Connecting Modules...",
   ConfigurationSaving = { Enabled = false }
})

local FarmTab = Window:CreateTab("Auto Farm", 4483362458)

FarmTab:CreateToggle({
   Name = "GPS Guided Farm",
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

                  -- Pocsolya keresése
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
                     -- A navigációs modul használata
                     local reached = Navigation.WalkTo(target.Position)
                     if reached then
                        IgnoreList[target] = true
                        local waitTime = (target.Size.Magnitude > 10) and 11 or 6
                        task.wait(waitTime)
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

-- Settings / Unload
local SettingsTab = Window:CreateTab("Settings", 4483362458)
SettingsTab:CreateButton({
   Name = "Unload Script",
   Callback = function()
      _G.AutoFarm = false
      Rayfield:Destroy()
   end,
})
