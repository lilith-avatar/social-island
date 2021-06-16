--- CustomEvent的定义，用于事件动态生成
--- @module Event Defines
--- @copyright Lilith Games, Avatar Team
local Events = {}

-- 服务器事件列表
Events.ServerEvents = {
    -- 进入小游戏
    'EnterMiniGameEvent', -- @param _player, _gameId
    'ExitMiniGameEvent', -- @param nil
    -- 交互
    'InteractSEvent', -- @param _player, _id
    'LeaveInteractSEvent', -- @param _player, _id
    'MazeEvent',
    'PlayerHitEvent',
    'PlayerStartMoleHitEvent',
    'PlayerLeaveMoleHitEvent',
    'NormalShakeEvent',
    'SnailBetEvent',
    'PlayerLeaveChairEvent',
    'QteChairMoveEvent',
    'PlayerClickSitBtnEvent',
    -- 人间大炮发射
    'CannonFireEvent',
    -- 人间大炮调整方向
    'SetCannonDirEvent', -- @param _dir
    'LoadMDataEvent', -- @param _userId
    'SaveMDataEvent', -- @param _userId, _playerdata
    'SPlayerHitEvent',
    'NormalChairSpeedUpEvent',
    'PurchaseSEvent',
    'PlayerSitEvent',
    'JetOverEvent',
    'SpawnCoinEvent',
    'CreateBubleEvent',
    'SPlayEffectEvent',
    'SycnTimeSEvent',
    'FoodOnDeskEvent',
    'FoodRewardEvent',
    --物品被拿出
    'STakeOutItemEvent', -- @param _player,_itemID
    --物品被使用
    'SUseItemEvent', -- @param _player,_itemID
    --投射物发射
    'SProjectileShootEvent', -- @param _player,_projectileID,_projectileOBJ
    --投射物命中
    'SProjectileHitEvent', -- @param _player,_projectileID,_projectileOBJ,_hitObj,_hitPos
    'PlayerEatFoodEvent',
    'SInteractOnPlayerColBeginEvent',
    'SInteractOnPlayerColEndEvent',
    'PotShakeEvent',
    'TryCreateRoomEvent',
    'TryChangeRoomEvent',
    'TryEnterRoomEvent',
    'TryLeaveRoomEvent',
    'TryChangeLockEvent',
    'AllowEnterEvent',
    'TryChangeStateEvent',
    'TryCreateElementEvent',
    'TryDestroyElementEvent',
    'TrySelectUnitEvent',
    'TryCancelElementEvent',
    'TryMoveElementEvent',
    'TryRotateElementEvent',
    'TryCreateStackEvent',
    'TryDestroyStackEvent',
    'TrySelectStackEvent',
    'TryCancelStackEvent',
    'TryMoveStackEvent',
    'TryRotateStackEvent',
    'TryAddStackEvent',
    'TryRemoveStackEvent',
    'TryAdsorbEvent'
}

-- 客户端事件列表
Events.ClientEvents = {
    -- 数据同步
    'SyncDataEvent', -- @param _playerData
    -- 数据载入结束
    'EndLoadDataEvent', -- @param nil
    -- 接触NPC
    'TalkToNpcEvent', -- @param _player, _npcId
    -- 离开NPC
    'LeaveNpcEvent', -- @param _player, _npcId
    --- 关闭通用UI事件
    'SetDefUIEvent', -- @param _bool, _nodes, _root
    --- 重置通用UI事件
    'ResetDefUIEvent',
    --- 进入小游戏修改UI事件
    'ChangeMiniGameUIEvent',
    --- 打开动态交互事件
    'OpenDynamicEvent', -- @param _type, _id
    --- 关闭动态交互事件
    'CloseDynamicEvent',
    -- 交互
    'InteractCEvent', -- @param _id
    'LeaveInteractCEvent', -- @param _player, _id
    -- NPC事件
    'TouchNpcEvent', -- @param _npcId, _npcObj
    -- 修改玩家当前相机
    'SetCurCamEvent', -- @param _cam
    'SetFPSCamEvent',
    -- 显示小游戏的GUI
    'SetMiniGameGuiEvent', -- @param  _gameId, _selfActive, _ctrlGuiActive
    --- 状态机改变触发
    'FsmTriggerEvent', -- @param  _state
    'CPlayerHitEvent',
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
    'StopEffectEvent',
    --获得Buff
    'GetBuffEvent', --@param _buffID, _dur
    --移除Buff
    'RemoveBuffEvent', --@param _buffID
    'UpdateCoinEvent',
    'GetItemEvent',
    'RemoveItemEvent',
    'UseItemInBagEvent',
    'UseItemInHandEvent',
    'CreateItemObjEvent',
    'LeaveMoleGameRangeEvent',
    'InsertInfoEvent',
    'ShowNoticeInfoEvent',
    'SwitchStoreUIEvent',
    'GetItemFromPoolEvent',
    'UnequipCurEquipmentEvent',
    'GetMolePriceEvent',
    'SliderPurchaseEvent',
    'PurchaseConfirmEvent',
    'PurchaseCEvent',
    'ChangeChairIdEvent',
    'StartJetEvent',
    'ShowGetCoinNumEvent',
    'SycnTimeCEvent',
    'PlayerCookEvent',
    'GetFinalFoodEvent',
    'SycnDeskFoodNumEvent',
    'SetSelectFoodEvent',
    'SycnTimeCEvent',
    --物品被拿出
    'CTakeOutItemEvent', -- @param _itemID
    --物品被使用
    'CUseItemEvent', -- @param _itemID
    --投射物发射
    'CProjectileShootEvent', -- @param _projectileID,_projectileOBJ
    --投射物命中
    'CProjectileHitEvent', -- @param _projectileID,_projectileOBJ,_hitObj,_hitPos
    'CSnailResetEvent',
    'PlayerSkinUpdateEvent',
    'EatFoodEvent',
    'CInteractOnPlayerColBeginEvent',
    'CInteractOnPlayerColEndEvent',
    'SetCamDistanceEvent',
    'ResetTentCamEvent',
    'SwitchTeleportFilterEvent',
    'ShowFoodEvent',
    'FoodOnDeskActionEvent',
    'SInteractUploadEvent',
    'GetMoleRewardEvent',
    'PlayerTeleportEvent',
    'GetBetRewardEvent',
    'BetFailEvent',
    'BetSuccessEvent',
    'OutlineCtrlEvent',
    --通知事件
    'NoticeEvent',
    'ElementSyncEvent',
    'ElementCreateEvent',
    'ElementDestroyEvent',
    'ElementSelectEvent',
    'ElementCancelEvent',
    'ElementHandEvent',
    'ElementOutHandEvent',
    'StackSyncEvent',
    'StackCreateEvent',
    'StackDestroyEvent',
    'StackSelectEvent',
    'StackCancelEvent',
    'StackAddEvent',
    'StackRemoveEvent',
    'RoomCreatedEvent',
    'RoomGameChangedEvent',
    'RoomOwnerChangedEvent',
    'EnterRoomEvent',
    'LeaveRoomEvent',
    'LockChangeEvent',
    'StateChangedEvent',
    'RoomDestroyEvent',
    'EnterRoomSyncEvent', ---玩家进入房间后服务端同步给这个玩家这个房间当前的信息
    'EnterGameSyncEvent',
    'RequestEnterEvent',
    'PlayerInvincibleEvent',
    'PlayAnimationEvent'
}

return Events
