--- CustomEvent的定义，用于事件动态生成
-- @module Event Defines
-- @copyright Lilith Games, Avatar Team
local Events = {}

-- 服务器事件列表
Events.ServerEvents = {
    -- 进入小游戏
    'EnterMiniGame', -- @param _player, _gameId
    'ExitMiniGame' -- @param nil
}

-- 客户端事件列表
Events.ClientEvents = {
    --NPC事件
    'TouchNpcEvent' -- @param _npcId
}
return Events
