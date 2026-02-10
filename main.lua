-- MATRIX HUB V2.3 - PATHFINDING & OBSTACLE AVOIDANCE
-- Description: Uses PathfindingService to navigate around tables and walls.

local PathfindingService = game:GetService("PathfindingService")
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "MATRIX | PATHFINDING V2.3",
   LoadingTitle = "Calculating Navigation Meshes...",
   ConfigurationSaving = { Enabled = false }
})

local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

_G.AutoFarm = false
local IgnoreList = {}

-- UNLOAD FUNKCIÓ
SettingsTab:CreateButton({
   Name = "Destroy Script (Unload)",
   Callback = function()
      _G.AutoFarm = false
      Rayfield:Destroy()
      print("Matrix: Unloaded")
   end,
})

-- ÚTVONALKERESŐ FUNKCIÓ
local function WalkTo(targetPart)
    local player = game.Players.LocalPlayer
    local character = player.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    
    -- Útvonal kiszámítása
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentJumpHeight = 10,
    })
    
    local success, errorMessage = pcall(function()
        path:ComputeAsync(root.Position, targetPart.Position)
    end)
    
    if success and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        
        for i, waypoint in ipairs(waypoints) do
           if not _G.AutoFarm then break end
           
           -- Ha a pont ugrást igényel
           if waypoint.Action == Enum.PathWaypointAction.Jump then
               humanoid.Jump = true
           end
           
           humanoid:MoveTo(waypoint.Position)
           
           -- Megvárjuk, amíg az adott ponthoz odaér
           local reached = false
           local conn = humanoid.MoveToFinished:Connect(function() reached = true end)
           
           -- Ha túl sokáig tart egy pont (beragadt), ugrunk a következőre
           local t = 0
           while not reached and t < 2 do
               task.wait(0.1)
               t = t + 0.1
           end
           conn:Disconnect()
        end
        return true
    else
        -- Ha a Pathfinding nem sikerül (pl. elzárt hely), próbáljuk a sima MoveTo-t
        humanoid:MoveTo(targetPart.Position)
        return false
    end
end

FarmTab:CreateToggle({
   Name = "GPS Guided Auto Farm",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoFarm = Value
      if Value then
         task.spawn(function()
            while _G.AutoFarm do
               task.wait(0.5)
               pcall(function()
                  local root = game.Players.LocalPlayer.Character.HumanoidRootPart
                  
                  -- CÉLPONT KERESÉSE
                  local target = nil
                  local minDist = 200
                  for _, v in pairs(workspace:GetDescendants()) do
                     if v:IsA("BasePart") and (v.Name:lower():find("puddle") or v.Name:lower():find("spill")) then
                        if not IgnoreList[v] and v.Transparency < 1 then
                           local d = (root.Position - v.Position).Magnitude
                           if d < minDist then
                              minDist = d
                              target = v
                           end
                        end
                     end
                  end

                  -- MOZGÁS ÉS TAKARÍTÁS
                  if target then
                     print("Matrix: Navigating to " .. target.Name)
                     local reached = WalkTo(target)
                     
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
