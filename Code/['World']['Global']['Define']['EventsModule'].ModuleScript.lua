--- CustomEvent的定义，用于事件动态生成
--- @module Event Defines
--- @copyright Lilith Games, Avatar Team
local Events = {}

-- 服务器事件列表
Events.ServerEvents = {
    -- 进入小游戏
    "EnterMiniGameEvent", -- @param _player, _gameId
    "ExitMiniGameEvent", -- @param nil
    -- 交互
    "InteractSEvent", -- @param _player, _id
    "LeaveInteractSEvent", -- @param _player, _id
    "MazeEvent",
    "PlayerHitEvent",
    "PlayerStartMoleHitEvent",
    "PlayerLeaveMoleHitEvent",
    "NormalShakeEvent",
    "SnailBetEvent",
    "PlayerLeaveChairEvent",
    "QteChairMoveEvent",
    "PlayerClickSitBtnEvent",
    -- 人间大炮发射
    "CannonFireEvent",
    -- 人间大炮调整方向
    "SetCannonDirEvent", -- @param _dir
    "LoadMDataEvent", -- @param _userId
    "SaveMDataEvent", -- @param _userId, _playerdata
    "SPlayerHitEvent",
    "NormalChairSpeedUpEvent"
}

-- 客户端事件列表
Events.ClientEvents = {
    -- 数据同步
    "SyncDataEvent", -- @param _playerData
    -- 数据载入结束
    "EndLoadDataEvent", -- @param nil
    -- 接触NPC
    "TalkToNpcEvent", -- @param _player, _npcId
    -- 离开NPC
    "LeaveNpcEvent", -- @param _player, _npcId
    --- 关闭通用UI事件
    "SetDefUIEvent", -- @param _bool, _nodes, _root
    --- 重置通用UI事件
    "ResetDefUIEvent",
    --- 进入小游戏修改UI事件
    "ChangeMiniGameUIEvent",
    --- 打开动态交互事件
    "OpenDynamicEvent", -- @param _type, _id
    -- 交互
    "InteractCEvent", -- @param _id
    "LeaveInteractCEvent", -- @param _player, _id
    -- NPC事件
    "TouchNpcEvent", -- @param _npcId, _npcObj
    -- 修改玩家当前相机
    "SetCurCamEvent", -- @param _cam
    -- 显示小游戏的GUI
    "SetMiniGameGuiEvent", -- @param  _gameId, _selfActive, _ctrlGuiActive
    --- 状态机改变触发
    "FsmTriggerEvent", -- @param  _state
    "CPlayerHitEvent",
    -- 修改是否能控制角色
    "SetPlayerControllableEvent", -- @param _bool
    "AddScoreAndBoostEvent",
    "ClientMazeEvent", -- @param _mazeEventEnum, _params
    "StartMoleEvent",
    "PlayerSitEvent",
    "ShakedEvent",
    "ShowSitBtnEvent",
    "HideSitBtnEvent",
    "ClientInitRaceEvent",
    -- 播放音效
    "PlayEffectEvent", -- @param _id, _pos
    --获得Buff
    "GetBuffEvent", --@param _buffID, _dur
    --移除Buff
    "RemoveBuffEvent", --@param _buffID
    "UpdateCoinEvent",
    "GetItemEvent",
    "RemoveItemEvent",
    "UseItemEvent",
    "CreateItemObjEvent",
    "LeaveMoleGameRangeEvent",
    "InsertInfoEvent",
    "SwitchStoreUIEvent",
    "GetItemFromPoolEvent",
    "UnequipCurWeaponEvent"
}

return Events
