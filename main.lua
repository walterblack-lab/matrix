-- MATRIX HUB V4.2 - DEEP LEVEL SEARCH
-- Code Description: Searches multiple locations for the "Janitor" level value.

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local function GetJanitorLevel()
    local p = game.Players.LocalPlayer
    
    -- 1. Próba: Leaderstats (A legvalószínűbb)
    local ls = p:FindFirstChild("leaderstats")
    if ls then
        local j = ls:FindFirstChild("Janitor") or ls:FindFirstChild("Janitor Level")
        if j then return j.Value end
    end
    
    -- 2. Próba: Külön mappák (pl. "Data", "Skills", "Levels")
    local folders = {p:FindFirstChild("Data"), p:FindFirstChild("Skills"), p:FindFirstChild("Levels")}
    for _, folder in pairs(folders) do
        if folder then
            local j = folder:FindFirstChild("Janitor") or folder:FindFirstChild("Level")
            if j then return j.Value end
        end
    end

    -- 3. Próba: Rejtett értékek közvetlenül a játékos alatt
    local hidden = p:FindFirstChild("JanitorLevel") or p:FindFirstChild("Janitor")
    if hidden and hidden:IsA("ValueBase") then return hidden.Value end

    return "Not Found"
end

local currentLevel = GetJanitorLevel()

local Window = Rayfield:CreateWindow({
   Name = "MATRIX HUB | V4.2",
   LoadingTitle = "Searching for Level: " .. tostring(currentLevel),
   Theme = "Green",
   ConfigurationSaving = { Enabled = false }
})

local StatsTab = Window:CreateTab("Janitor Info", 4483362458)

StatsTab:CreateSection("Skill Detection")
local LvlLabel = StatsTab:CreateLabel("Detected Janitor Level: " .. tostring(currentLevel))

StatsTab:CreateButton({
   Name = "Re-Scan Level",
   Callback = function()
      local newLvl = GetJanitorLevel()
      LvlLabel:Set("Detected Janitor Level: " .. tostring(newLvl))
      Rayfield:Notify({Title = "Scanner", Content = "Level found: " .. tostring(newLvl), Duration = 3})
   end,
})
