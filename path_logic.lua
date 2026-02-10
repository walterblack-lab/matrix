-- MATRIX PATH LOGIC V4.0
-- Description: Handles path calculation with error recovery.

local PathfindingService = game:GetService("PathfindingService")
local PathLogic = {}

function PathLogic.GetPath(startPos, targetPos)
    local path = PathfindingService:CreatePath({
        AgentRadius = 2.5,
        AgentCanJump = true,
        WaypointSpacing = 3
    })

    local success, _ = pcall(function()
        path:ComputeAsync(startPos, targetPos)
    end)

    if success and path.Status == Enum.PathStatus.Success then
        return path:GetWaypoints()
    else
        -- Vészhelyzeti terv: ha a Pathfinding elbukik, egyenes vonalú pontokat adunk
        warn("Matrix: Pathfinding failed, using direct vector.")
        return { {Position = targetPos, Action = Enum.PathWaypointAction.Walk} }
    end
end

return PathLogic
