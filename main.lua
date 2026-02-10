-- MATRIX HUB V4.7 - FINAL FIX
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local PathLogic = loadstring(game:HttpGet("https://raw.githubusercontent.com/walterblack-lab/matrix/refs/heads/main/path_logic.lua"))()
local Mover = loadstring(game:HttpGet("https://raw.githubusercontent.com/walterblack-lab/matrix/refs/heads/main/mover.lua"))()

_G.AutoFarm = false
local IgnoreList = {}

local function GetJanitorLevel()
    local p = game.Players.LocalPlayer
    local lvl = 1
    pcall(function()
        local frame = p.PlayerGui.Skills.SkillsHolder.SkillsScrollingFrame
        for _, item in pairs(frame:GetChildren()) do
            local title = item:FindFirstChild("SkillTitle")
            if title and title.Text:find("Janitor") then
                lvl = tonumber(title.Text:match("%d+")) or 1
                break
            end
        end
    end)
    return lvl
end

local Window = Rayfield:CreateWindow({
   Name = "MATRIX HUB | V4.7",
   LoadingTitle = "Matrix Anti-Stuck System",
   Theme = "Green",
   ConfigurationSaving = { Enabled = false }
})

local FarmTab = Window:CreateTab("Main", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

-- Keybind a menühöz
FarmTab:CreateKeybind({
   Name = "Minimize Menu",
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
                  local root = game.Players.LocalPlayer.Character.HumanoidRootPart
                  local target = nil
                  local minDist = math.huge
                  local myLevel = GetJanitorLevel()

                  -- EZ AZ A RÉSZ, AMIT KERESTÉL:
                  for _, v in pairs(workspace:GetDescendants()) do
                     if v:IsA("BasePart") and v.Name:lower():find("puddle") then
                        
                        -- 1. SZINT ELLENŐRZÉS (SÁRGA SZÍN SZŰRÉS)
                        -- Ha a Piros és Zöld csatorna is erős, az sárgát jelent
                        local isYellow = (v.Color.R > 0.8 and v.Color.G > 0.8)
                        
                        if isYellow and myLevel < 20 then
                           -- Ha sárga és kicsi a szinted, átugorjuk (nem csinálunk semmit)
                        else
                           -- 2. TÁVOLSÁG ELLENŐRZÉS (Csak ha nem tiltott folt)
                           if not IgnoreList[v] and v.Transparency < 1 then
                              local d = (root.Position - v.Position).Magnitude
                              if d < minDist then
                                 minDist = d
                                 target = v
                              end
                           end
                        end
                     end
                  end

                  -- MOZGÁS A KIVÁLASZTOTT CÉLPONTHOZ
                  if target then
                     local waypoints = PathLogic.GetPath(root.Position, target.Position)
                     if #waypoints > 0 then
                        for _, wp in ipairs(waypoints) do
                           if not _G.AutoFarm then break end
                           Mover.MoveToPoint(wp.Position, wp.Action == Enum.PathWaypointAction.Jump)
                        end
                        IgnoreList[target] = true
                        task.wait(6.5)
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
         IgnoreList = {}
      end
   end,
})

SettingsTab:CreateButton({ Name = "Unload", Callback = function() _G.AutoFarm = false Rayfield:Destroy() end })
