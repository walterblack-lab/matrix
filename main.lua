-- MATRIX HUB V5.0 - FINAL STABILIZATION
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local PathLogic = loadstring(game:HttpGet("https://raw.githubusercontent.com/walterblack-lab/matrix/refs/heads/main/path_logic.lua"))()
local Mover = loadstring(game:HttpGet("https://raw.githubusercontent.com/walterblack-lab/matrix/refs/heads/main/mover.lua"))()

_G.AutoFarm = false
local IgnoreList = {}

local Window = Rayfield:CreateWindow({
   Name = "MATRIX HUB | V5.0",
   LoadingTitle = "WC & Spill Fix Online",
   Theme = "Green",
   ConfigurationSaving = { Enabled = false }
})

local FarmTab = Window:CreateTab("Main", 4483362458)
local StatusLabel = FarmTab:CreateLabel("Status: Idle")

-- KEYBIND ÉS UNLOAD (Ahogy kérted)
FarmTab:CreateKeybind({
   Name = "Hide Menu",
   CurrentKeybind = "RightShift",
   HoldToInteract = false,
   Callback = function() Rayfield:ToggleUI() end,
})

FarmTab:CreateToggle({
   Name = "Start Smart Farm",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoFarm = Value
      if Value then
         task.spawn(function()
            while _G.AutoFarm do
               pcall(function()
                  local character = game.Players.LocalPlayer.Character
                  local root = character.HumanoidRootPart
                  local target = nil
                  local minDist = math.huge

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

                  if target then
                     -- 2. PONTOS SÁRGA DETEKTÁLÁS (Sárga = Magas R és G, alacsony B)
                     local isYellow = (target.Color.R > 0.7 and target.Color.G > 0.7 and target.Color.B < 0.5)
                     local name = isYellow and "🟡 Yellow Spill" or "🔵 Blue Puddle"
                     local waitTime = isYellow and 15 or 7 -- A sárgára 15 másodpercet várunk
                     
                     StatusLabel:Set("Status: Moving to " .. name)
                     
                     local waypoints = PathLogic.GetPath(root.Position, target.Position)
                     if #waypoints > 0 then
                        for _, wp in ipairs(waypoints) do
                           if not _G.AutoFarm then break end
                           
                           -- ANTI-STUCK (WC VÉDELEM)
                           local startPos = root.Position
                           Mover.MoveToPoint(wp.Position, wp.Action == Enum.PathWaypointAction.Jump)
                           
                           -- Ha nem mozdultunk a pont felé eleget (elakadtunk a falban/WC-ben)
                           if (root.Position - startPos).Magnitude < 1 then
                              character.Humanoid.Jump = true
                              root.CFrame = root.CFrame * CFrame.new(0, 0, 2) -- Kicsit hátrébb lép
                           end
                        end
                        
                        StatusLabel:Set("Status: Cleaning " .. name .. " (" .. waitTime .. "s)")
                        IgnoreList[target] = true
                        task.wait(waitTime)
                     else
                        IgnoreList[target] = true
                        task.wait(0.1)
                     end
                  end
               end)
               task.wait(0.5)
            end
         end)
      end
   end,
})

local SettingsTab = Window:CreateTab("Settings", 4483362458)
SettingsTab:CreateButton({ Name = "Unload Script", Callback = function() _G.AutoFarm = false Rayfield:Destroy() end })
