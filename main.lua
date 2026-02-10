-- MATRIX HUB V4.0 - MODULAR SYSTEM
-- Logic: High-priority nearest target selection.

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local PathLogic = loadstring(game:HttpGet("https://raw.githubusercontent.com/walterblack-lab/matrix/refs/heads/main/path_logic.lua"))()
local Mover = loadstring(game:HttpGet("https://raw.githubusercontent.com/walterblack-lab/matrix/refs/heads/main/mover.lua"))()

_G.AutoFarm = false
local IgnoreList = {}

local Window = Rayfield:CreateWindow({
   Name = "MATRIX HUB | V4.0 PRO",
   LoadingTitle = "Modular System Loading...",
   Theme = "Green",
   ConfigurationSaving = { Enabled = false }
})

local FarmTab = Window:CreateTab("Auto Farm", 4483362458)

FarmTab:CreateToggle({
   Name = "Modular GPS Farm",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoFarm = Value
      if Value then
         task.spawn(function()
            while _G.AutoFarm do
               pcall(function()
                  local root = game.Players.LocalPlayer.Character.HumanoidRootPart
                  local target = nil
                  local minDist = math.huge

                  -- 1. KERESÉS (Mindig a legközelebbit!)
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

                  -- 2. NAVIGÁCIÓ ÉS MOZGÁS
                  if target then
                     local waypoints = PathLogic.GetPath(root.Position, target.Position)
                     for _, wp in ipairs(waypoints) do
                        if not _G.AutoFarm then break end
                        Mover.MoveToPoint(wp.Position, wp.Action == Enum.PathWaypointAction.Jump)
                     end
                     
                     -- 3. TAKARÍTÁS FAILSAFE
                     IgnoreList[target] = true
                     local cleanStart = tick()
                     while target and target.Parent and target.Transparency < 1 and _G.AutoFarm do
                        task.wait(0.5)
                        if (tick() - cleanStart) > 12 then break end
                     end
                  end
               end)
               task.wait(0.5)
            end
         end)
      else
         IgnoreList = {}
      end
   end,
})

local SettingsTab = Window:CreateTab("Settings", 4483362458)
SettingsTab:CreateButton({ Name = "Reset System", Callback = function() IgnoreList = {} end })
