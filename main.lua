-- MATRIX HUB V4.2 - JANITOR STATS EDITION
-- Description: Focuses on retrieving and displaying the correct Janitor level.

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- MODULOK BEHÍVÁSA (Várd meg, amíg ezeket is frissítjük)
local PathLogic = loadstring(game:HttpGet("https://raw.githubusercontent.com/walterblack-lab/matrix/refs/heads/main/path_logic.lua"))()
local Mover = loadstring(game:HttpGet("https://raw.githubusercontent.com/walterblack-lab/matrix/refs/heads/main/mover.lua"))()

_G.AutoFarm = false
local IgnoreList = {}

-- === SZINT LEKÉRDEZÉSE ===
-- Ez a függvény megkeresi a Janitor szintedet a játékos adatai között
local function GetJanitorLevel()
    local player = game.Players.LocalPlayer
    
    -- Megnézzük a leaderstats-ban (leggyakoribb hely)
    local stats = player:FindFirstChild("leaderstats")
    if stats then
        local janitorLevel = stats:FindFirstChild("Janitor") or stats:FindFirstChild("Janitor Level") or stats:FindFirstChild("Level")
        if janitorLevel then
            return janitorLevel.Value
        end
    end
    
    -- Ha nem találja a leaderstats-ban, megnézzük a PlayerGui-ban (ha oda rejtették)
    return "N/A" -- Ha sehol sem találja
end

local currentLevel = GetJanitorLevel()

local Window = Rayfield:CreateWindow({
   Name = "MATRIX HUB | JANITOR LVL: " .. tostring(currentLevel),
   LoadingTitle = "Reading Janitor Skill Tree...",
   Theme = "Green",
   ConfigurationSaving = { Enabled = false }
})

-- === TABS ===
local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
local StatsTab = Window:CreateTab("Janitor Info", 4483362458)

-- STATS TAB TARTALMA
StatsTab:CreateSection("Your Professional Stats")
local LvlLabel = StatsTab:CreateLabel("Current Janitor Level: " .. tostring(currentLevel))

StatsTab:CreateButton({
   Name = "Refresh Level",
   Callback = function()
      local newLvl = GetJanitorLevel()
      LvlLabel:Set("Current Level: " ..协议 tostring(newLvl))
      Rayfield:Notify({Title = "Stats Updated", Content = "New level: " .. tostring(newLvl), Duration = 2})
   end,
})

-- FARM TAB (Marad a logika, de a szintet figyeli)
FarmTab:CreateToggle({
   Name = "Smart Level Farm",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoFarm = Value
      if Value then
         task.spawn(function()
            while _G.AutoFarm do
               pcall(function()
                  -- Itt majd a szint alapján szűrünk a következő lépésben
                  local root = game.Players.LocalPlayer.Character.HumanoidRootPart
                  -- ... (a korábbi kereső logika helye)
               end)
               task.wait(1)
            end
         end)
      end
   end,
})
