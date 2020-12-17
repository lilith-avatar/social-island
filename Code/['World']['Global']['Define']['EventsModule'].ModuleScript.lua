--- CustomEvent的定义，用于事件动态生成
--- @module Event Defines
--- @copyright Lilith Games, Avatar Team
local Events = {}

-- 服务器事件列表
Events.ServerEvents = {
    "LeaveZeppelinEvent",
    -- 进入小游戏
    'EnterMiniGameEvent', -- @param _player, _gameId
    'ExitMiniGameEvent', -- @param nil
    'PlayerHitEvent',
    'PlayerStartMoleHitEvent',
    'PlayerLeaveMoleHitEvent',
    'RaceGameStartEvent',
	'RaceGameOverEvent',
    -- 人间大炮发射
    "CannonFireEvent",
    -- 人间大炮调整方向
    "SetCannonDirEvent" -- @param _dir
}

-- 客户端事件列表
Events.ClientEvents = {
    -- NPC事件
    "TouchNpcEvent", -- @param _npcId
    -- 修改玩家当前相机
    "SetCurCamEvent", -- @param _cam
    -- 显示小游戏的GUI
    "SetMiniGameGuiEvent", -- @param  _gameId,_selfActive, _ctrlGuiActive
    --- 状态机改变触发
    "FsmTriggerEvent", -- @param  _state
    -- 修改是否能控制角色
    "SetPlayerControllableEvent", -- @param _bool
    'AddScoreAndBoostEvent',
    'StartMoleEvent',
    'ClintInitRaceEvent',
    -- 播放音效
    'PlayEffectEvent' -- @param _id, _pos
}

return Events