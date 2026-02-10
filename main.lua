-- MATRIX HUB V4.9 - DYNAMIC CLEANING TIME
-- Description: Adjusts wait time based on object size to prevent leaving half-finished spills.

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local PathLogic = loadstring(game:HttpGet("https://raw.githubusercontent.com/walterblack-lab/matrix/refs/heads/main/path_logic.lua"))()
local Mover = loadstring(game:HttpGet("https://raw.githubusercontent.com/walterblack-lab/matrix/refs/heads/main/mover.lua"))()

_G.AutoFarm = false
local IgnoreList = {}

local Window = Rayfield:CreateWindow({
   Name = "MATRIX HUB | V4.9",
   LoadingTitle = "Optimizing Cleaning Cycles...",
   Theme = "Green",
   ConfigurationSaving = { Enabled = false }
})

local FarmTab = Window:CreateTab("Main", 4483362458)
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
                  local root = game.Players.LocalPlayer.Character.HumanoidRootPart
                  local target = nil
                  local minDist = math.huge

                  StatusLabel:Set("Status: Searching...")

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
                     -- TÍPUS ÉS MÉRET MEGHATÁROZÁSA
                     local isLarge = target.Size.Magnitude > 10 -- A nagy foltoknak nagyobb a kiterjedése
                     local isYellow = (target.Color.R > 0.8 and target.Color.G > 0.8)
                     local name = isYellow and "🟡 Yellow Spill" or "🔵 Blue Puddle"
                     
                     -- DINAMIKUS IDŐZÍTÉS
                     -- Ha nagy, 11 másodperc, ha kicsi, 6.5 másodperc
                     local waitTime = isLarge and 11 or 6.5
                     
                     StatusLabel:Set("Status: Moving to " .. name)
                     
                     local waypoints = PathLogic.GetPath(root.Position, target.Position)
                     if #waypoints > 0 then
                        for _, wp in ipairs(waypoints) do
                           if not _G.AutoFarm then break end
                           Mover.MoveToPoint(wp.Position, wp.Action == Enum.PathWaypointAction.Jump)
                        end
                        
                        StatusLabel:Set("Status: Cleaning " .. name .. " (" .. waitTime .. "s)")
                        IgnoreList[target] = true
                        task.wait(waitTime) -- Itt várja meg a teljes folyamatot
                     else
                        IgnoreList[target] = true
                        task.wait(0.1)
                     end
                  end
               end)
               task.wait(0.5)
            end
         end)
      else
         _G.AutoFarm = false
         IgnoreList = {}
         StatusLabel:Set("Status: Idle")
      end
   end,
})
