-- MATRIX HUB V4.3 - UI DATA EXTRACTOR
-- Description: Reads level directly from the Skills UI found by scanner.

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- MODULOK BEHÍVÁSA
local PathLogic = loadstring(game:HttpGet("https://raw.githubusercontent.com/walterblack-lab/matrix/refs/heads/main/path_logic.lua"))()
local Mover = loadstring(game:HttpGet("https://raw.githubusercontent.com/walterblack-lab/matrix/refs/heads/main/mover.lua"))()

_G.AutoFarm = false
local IgnoreList = {}

-- === SZINT KIOLVASÁSA A UI-BÓL ===
local function GetJanitorLevel()
    local p = game.Players.LocalPlayer
    pcall(function()
        -- A scanner által talált pontos útvonal
        local skillUI = p.PlayerGui.Skills.SkillsHolder.SkillsScrollingFrame:FindFirstChild("SkillOptionTemplate")
        if skillUI and skillUI:FindFirstChild("SkillTitle") then
            local text = skillUI.SkillTitle.Text -- Pl: "Janitor: 18"
            local level = text:match("%d+") -- Kiszedi a számot a szövegből
            return tonumber(level)
        end
    end)
    return 18 -- Alapértelmezett, ha épp nincs nyitva/nem találja
end

local currentLevel = GetJanitorLevel()

local Window = Rayfield:CreateWindow({
   Name = "MATRIX HUB | JANITOR LVL: " .. tostring(currentLevel),
   LoadingTitle = "Syncing with Janitor Skills...",
   Theme = "Green",
   ConfigurationSaving = { Enabled = false }
})

local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
local StatsTab = Window:CreateTab("Stats", 4483362458)

-- STATS MEGJELENÍTÉS
StatsTab:CreateLabel("Current Janitor Level: " .. tostring(currentLevel))
StatsTab:CreateLabel("Target Level for Yellow Spills: 20")

FarmTab:CreateToggle({
   Name = "Smart Janitor Farm (Lvl Filter)",
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

                  for _, v in pairs(workspace:GetDescendants()) do
                     if v:IsA("BasePart") and v.Name:lower():find("puddle") then
                        -- OKOS SZŰRŐ: Ha sárga a folt, de nem vagyunk 20-asok, kihagyjuk
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
                        -- Ha nem talál utat, ne próbálkozzon ezzel a folttal egy ideig
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
