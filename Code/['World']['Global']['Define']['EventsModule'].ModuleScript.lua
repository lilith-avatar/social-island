--- CustomEvent的定义，用于事件动态生成
--- @module Event Defines
--- @copyright Lilith Games, Avatar Team
local Events = {}

-- 服务器事件列表
Events.ServerEvents = {
    -- 进入小游戏
    'EnterMiniGameEvent', -- @param _player, _gameId
    'ExitMiniGameEvent', -- @param nil
    -- 接触NPC
    'TouchNpcEvent', -- @param _player, _npcId
    -- 离开NPC
    'LeaveNpcEvent', -- @param _player, _npcId
    -- 开始与NPC对话
    'StartTalkNpcEvent', -- @param _player, _npcId
    -- 交互
    'InteractSEvent', -- @param _player, _id
    'MazeEvent',
    'PlayerHitEvent',
    'PlayerStartMoleHitEvent',
    'PlayerLeaveMoleHitEvent',
    'NormalShakeEvent',
    'PlayerLeaveChairEvent',
    'QteChairMoveEvent',
    'PlayerClickSitBtnEvent',
    'RaceGameStartEvent',
    'RaceGameOverEvent',
    -- 人间大炮发射
    'CannonFireEvent',
    -- 人间大炮调整方向
    'SetCannonDirEvent', -- @param _dir
    'LoadMDataEvent', -- @param _userId
    'SaveMDataEvent', -- @param _userId, _playerdata
    'StartBattleEvent', -- @param _isNpc, _playerA, _playerB
    'PlantFlowerEvent' -- @param _userId, _flowerObj
}

-- 客户端事件列表
Events.ClientEvents = {
    -- 数据同步
    'SyncDataEvent', -- @param _playerData
    -- 数据载入结束
    'EndLoadDataEvent', -- @param nil
    --- 关闭通用UI事件
    'SetDefUIEvent', -- @param _bool, _nodes, _root
    --- 重置通用UI事件
    'ResetDefUIEvent',
    --- 打开动态交互事件
    'OpenDynamicEvent', -- @param _type, _id
    -- 交互
    'InteractCEvent', -- @param _id
    -- NPC事件
    'TouchNpcEvent', -- @param _npcId, _npcObj
    -- 修改玩家当前相机
    'SetCurCamEvent', -- @param _cam
    -- 显示小游戏的GUI
    'SetMiniGameGuiEvent', -- @param  _gameId, _selfActive, _ctrlGuiActive
    --- 状态机改变触发
    'FsmTriggerEvent', -- @param  _state
    -- 修改是否能控制角色
    'SetPlayerControllableEvent', -- @param _bool
    'AddScoreAndBoostEvent',
    'ClientMazeEvent', -- @param _mazeEventEnum, _params
    'StartMoleEvent',
    'PlayerSitEvent',
    'ShakedEvent',
    'ShowSitBtnEvent',
    'HideSitBtnEvent',
    'ClientInitRaceEvent',
    -- 播放音效
    'PlayEffectEvent', -- @param _id, _pos
    'LoadMDataBackEvent',
    --准备战斗
    'ReadyBattleEvent',
    --宠物战斗事件
    'MBattleEvent', --@param _enum,_arg1,_arg2
    --获得Buff
    'GetBuffEvent', --@param _buffID, _dur
    --移除Buff
    'RemoveBuffEvent', --@param _buffID
    'GetCoinEvent',
    'CreateItemObjEvent',
    --开始扫描事件
    'MonsterScanEvent', --@param _pos,_euler,_time
    'LeaveMoleGameRangeEvent'
}

return Events
