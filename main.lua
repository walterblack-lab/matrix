-- MATRIX HUB V4.4 - LIVE LEVEL & XP SYNC
-- Description: Constantly updates level/XP and adapts the farm logic.

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local PathLogic = loadstring(game:HttpGet("https://raw.githubusercontent.com/walterblack-lab/matrix/refs/heads/main/path_logic.lua"))()
local Mover = loadstring(game:HttpGet("https://raw.githubusercontent.com/walterblack-lab/matrix/refs/heads/main/mover.lua"))()

_G.AutoFarm = false
local IgnoreList = {}

-- === ADATOK LEKÉRÉSE (ÉLŐBEN) ===
local function GetJanitorData()
    local p = game.Players.LocalPlayer
    local data = { level = 18, xp = "0/0" }
    
    pcall(function()
        local skills = p.PlayerGui.Skills.SkillsHolder.SkillsScrollingFrame:FindFirstChild("SkillOptionTemplate")
        if skills then
            -- Szint kinyerése
            local lvlText = skills.SkillTitle.Text
            data.level = tonumber(lvlText:match("%d+")) or 18
            
            -- XP kinyerése (Scanner alapján: XPBar.SkillBarAmount)
            local xpBar = skills.PaddingFrame:FindFirstChild("XPBar")
            if xpBar and xpBar:FindFirstChild("SkillBarAmount") then
                data.xp = xpBar.SkillBarAmount.Text -- Pl: "176 / 450"
            end
        end
    end)
    return data
end

local startData = GetJanitorData()
local Window = Rayfield:CreateWindow({
   Name = "MATRIX HUB | V4.4",
   LoadingTitle = "Initializing Neural Link...",
   Theme = "Green",
   ConfigurationSaving = { Enabled = false }
})

local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
local StatsTab = Window:CreateTab("Stats", 4483362458)

-- ÉLŐ CÍMKÉK
local LvlLabel = StatsTab:CreateLabel("Current Level: " .. startData.level)
local XPLabel = StatsTab:CreateLabel("Current XP: " .. startData.xp)

-- === ÉLŐ FRISSÍTŐ CIKLUS ===
-- Ez a háttérben fut és 5 másodpercenként frissíti a kijelzőt
task.spawn(function()
    while true do
        local liveData = GetJanitorData()
        LvlLabel:Set("Current Level: " .. liveData.level)
        XPLabel:Set("Current XP: " .. liveData.xp)
        task.wait(5) 
    end
end)

FarmTab:CreateToggle({
   Name = "Auto-Adapting Farm",
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
                  local myLevel = GetJanitorData().level -- Mindig az aktuális szinttel számol

                  for _, v in pairs(workspace:GetDescendants()) do
                     if v:IsA("BasePart") and v.Name:lower():find("puddle") then
                        -- Sárga folt szűrő (Color alapú)
                        local isYellow = (v.Color.G > 0.7 and v.Color.R > 0.7)
                        
                        if (not isYellow or myLevel >= 20) and not IgnoreList[v] and v.Transparency < 1 then
                           local d = (root.Position - v.Position).Magnitude
                           if d < minDist then
                              minDist = d
                              target = v
                           end
                        end
                     end
                  end

                  if target then
                     local waypoints = PathLogic.GetPath(root.Position, target.Position)
                     if #waypoints > 0 then
                        for _, wp in ipairs(waypoints) do
                           if not _G.AutoFarm then break end
                           Mover.MoveToPoint(wp.Position, wp.Action == Enum.PathWaypointAction.Jump)
                        end
                        IgnoreList[target] = true
                        task.wait(6)
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
