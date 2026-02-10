-- MATRIX HUB V4.8 - LIVE STATUS EDITION
-- Code Description: Adds a dynamic status label to show what the bot is currently cleaning.

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local PathLogic = loadstring(game:HttpGet("https://raw.githubusercontent.com/walterblack-lab/matrix/refs/heads/main/path_logic.lua"))()
local Mover = loadstring(game:HttpGet("https://raw.githubusercontent.com/walterblack-lab/matrix/refs/heads/main/mover.lua"))()

_G.AutoFarm = false
local IgnoreList = {}

local Window = Rayfield:CreateWindow({
   Name = "MATRIX HUB | V4.8",
   LoadingTitle = "Status System Online",
   Theme = "Green",
   ConfigurationSaving = { Enabled = false }
})

local FarmTab = Window:CreateTab("Main", 4483362458)

-- ÉLŐ ÁLLAPOTJELZŐ CÍMKE
local StatusLabel = FarmTab:CreateLabel("Status: Idle")

FarmTab:CreateToggle({
   Name = "Start Smart Farm",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoFarm = Value
      if Value then
         task.spawn(function()
            while _G.AutoFarm do
               pcall(function()
                  StatusLabel:Set("Status: Searching for targets...")
                  
                  local root = game.Players.LocalPlayer.Character.HumanoidRootPart
                  local target = nil
                  local minDist = math.huge

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
                     -- MEGHATÁROZZUK A TÍPUST A SZÍN ALAPJÁN
                     local isYellow = (target.Color.R > 0.8 and target.Color.G > 0.8)
                     local spillType = isYellow and "🟡 Yellow Spill" or "🔵 Blue Puddle"
                     
                     StatusLabel:Set("Status: Pathfinding to " .. spillType)
                     
                     local waypoints = PathLogic.GetPath(root.Position, target.Position)
                     if #waypoints > 0 then
                        StatusLabel:Set("Status: Moving to " .. spillType)
                        for _, wp in ipairs(waypoints) do
                           if not _G.AutoFarm then break end
                           Mover.MoveToPoint(wp.Position, wp.Action == Enum.PathWaypointAction.Jump)
                        end
                        
                        StatusLabel:Set("Status: Cleaning " .. spillType .. "...")
                        IgnoreList[target] = true
                        task.wait(6.5) -- Takarítási idő
                     else
                        StatusLabel:Set("Status: Path Blocked - Skipping")
                        IgnoreList[target] = true
                        task.wait(0.1)
                     end
                  else
                     StatusLabel:Set("Status: No targets found")
                  end
               end)
               task.wait(0.5)
            end
            StatusLabel:Set("Status: Idle")
         end)
      else
         StatusLabel:Set("Status: Idle")
         IgnoreList = {}
      end
   end,
})
