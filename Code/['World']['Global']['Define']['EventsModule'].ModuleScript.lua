--- CustomEvent的定义，用于事件动态生成
--- @module Event Defines
--- @copyright Lilith Games, Avatar Team
local Events = {}

-- 服务器事件列表
Events.ServerEvents = {
    "LeaveZeppelinEvent",
    -- 进入小游戏
    "EnterMiniGameEvent", -- @param _player, _gameId
    "ExitMiniGameEvent" -- @param nil
}

-- 客户端事件列表
Events.ClientEvents = {
    -- NPC事件
    "TouchNpcEvent", -- @param _npcId
    -- 修改玩家当前相机
    "SetCurCamEvent" -- @param _cam
}

return Events
