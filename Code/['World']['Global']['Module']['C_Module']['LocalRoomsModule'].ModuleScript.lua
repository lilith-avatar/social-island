--- @module LocalRooms 客户端游戏中房间控制
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local LocalRooms = ModuleUtil.New('LocalRooms', ClientBase)
local self = LocalRooms

--- 初始化
function LocalRooms:Init()
    Game.SetFPSQuality(Enum.FPSQuality.High)
    ---本地的房间列表 key-uuid value-ins_room
    self.arr_rooms = {}
    ---@type LocalRoomBase 本地玩家所在的游戏房间
    self.room_localPlayer = nil
    world.OnPlayerAdded:Connect(function(_player)
        if _player ~= localPlayer then
            OtherPlayerAdded(_player)
        end
    end)
end

--- Update函数
--- @param _dt number delta time 每帧时间
function LocalRooms:Update(_dt, _tt)
    if self.room_localPlayer then
        self.room_localPlayer:Update(_dt)
    end
end

--- FixUpdate函数
--- @param _dt number delta time 每帧时间
function LocalRooms:FixUpdate(_dt)
    if self.room_localPlayer then
        self.room_localPlayer:FixUpdate(_dt)
    end
end

--- 本地玩家尝试离开自己所在的房间
function LocalRooms:TryLeaveRoom()
    if self:GetLPRoom() then
        NetUtil.Fire_S('TryLeaveRoomEvent', localPlayer, self:GetLPRoom().str_uuid)
    end
end

--- 本地玩家尝试更改自己的游戏状态
---@param _index number 若是切换到游戏状态,则选择的座位号,不填服务端会随机选择一个
function LocalRooms:TrySwitchState(_state, _index)
    if self:GetLPRoom() then
        NetUtil.Fire_S('TryChangeStateEvent', localPlayer, self:GetLPRoom().str_uuid, _state, _index)
    end
end

--- 本地玩家尝试更改房间的游戏
function LocalRooms:TryChangeRoom(_id)
    if self:GetLPRoom() then
        NetUtil.Fire_S('TryChangeRoomEvent', localPlayer, self:GetLPRoom().str_uuid, _id)
    end
end
--- 本地玩家尝试创建一个房间
function LocalRooms:TryCreateRoom(_capacity, _isLocked)
    if not self:GetLPRoom() then
        NetUtil.Fire_S('TryCreateRoomEvent', localPlayer, localPlayer.Position + localPlayer.Forward * 2, _capacity, _isLocked)
    end
end

--- 本地玩家尝试进入一个房间
function LocalRooms:TryEnterRoom(_uuid)
    if not self:GetLPRoom() and self:GetRoomByUuid(_uuid) then
        NetUtil.Fire_S('TryEnterRoomEvent', localPlayer, _uuid)
    end
end

--- 本地玩家尝试上更改房间上锁状态
function LocalRooms:TryChangeLock(_lock)
    if self:GetLPRoom() then
        NetUtil.Fire_S('TryChangeLockEvent', self:GetLPRoom().str_uuid, localPlayer, _lock)
    end
end

--- 请求创建无限元素的堆叠
function LocalRooms:TryCreateUnlimited()
    if self:GetLPRoom() then
        self.room_localPlayer:TryCreateUnit(100001, Vector3(-1.5, 0, 0))
        self.room_localPlayer:TryCreateUnit(100002, Vector3(1.5, 0, 0))
    end
end

--- 请求创建一个对象
function LocalRooms:TryCreateUnit()
    if self:GetLPRoom() then
        self.room_localPlayer:TryCreateUnit(10001, Vector3(0, 0, 1.5))
    end
end

--- 请求创建堆叠
function LocalRooms:TryCreateStack(_type)
    if self:GetLPRoom() then
        self.room_localPlayer:TryCreateStack(_type)
    end
end

--- 房间创建事件
function LocalRooms:RoomCreatedEventHandler(_uuid, _owner, _pos, _lock)
    local room = LocalRoomBase:new(_uuid, _owner, _pos, _lock)
    self.arr_rooms[_uuid] = room
end

--- 房间中玩家离开事件
---@param _room_uuid string 离开的房间UUID
---@param _uid string 离开的玩家UID
function LocalRooms:LeaveRoomEventHandler(_room_uuid, _uid)
    local room = self:GetRoomByUuid(_room_uuid)
    if not room then
        return
    end
    if _uid == localPlayer.UserId then
        self.room_localPlayer = nil
    end
    room:LeaveRoom(_uid)
    if _uid == localPlayer.UserId then
        ---手牌区销毁逻辑
        HandMapping:LeaveGame()
    end
end

---房间上锁后观战玩家尝试选择座位后发起的请求,只有房主会接受此请求
function LocalRooms:RequestEnterEventHandler(_room_uuid, _requester, _index)
    --[[
	print('玩家请求游戏', _room_uuid, _requester, _index)
    if not _requester then
        return
    end
    ---暂时等待三秒直接同意
    wait(3)
    print('暂时等待三秒直接同意')
    NetUtil.Fire_S('AllowEnterEvent', _room_uuid, localPlayer, _requester, _index)
	]]
end

--- 房间游戏更改事件
function LocalRooms:RoomGameChangedEventHandler(_uuid, _id)
    local room = self:GetRoomByUuid(_uuid)
    if not room then
        return
    end
    room:ChangeGame(_id)
	if room == self:GetLPRoom() then
		local index = room:GetPlayerSeat(localPlayer.UserId)
		if(index) then
			CameraControl:SetSeat(_index, #(room.arr_gamingSeat))
		end
    end
end

--- 房间上锁状态更改事件
function LocalRooms:LockChangeEventHandler(_room_uuid, _lock)
    local room = self:GetRoomByUuid(_room_uuid)
    if not room then
        return
    end
    room:LockChange(_lock)
end

--- 房间房主更改事件
function LocalRooms:RoomOwnerChangedEventHandler(_uuid, _owner)
    local room = self:GetRoomByUuid(_uuid)
    if not room then
        return
    end
    room:ChangeOwner(_owner)
end

--- 房间销毁事件
function LocalRooms:RoomDestroyEventHandler(_uuid)
    local room = self:GetRoomByUuid(_uuid)
    if not room then
        return
    end
    self.arr_rooms[_uuid] = nil
    room:Destroy()
end

---玩家进入一个房间事件,进入房间后自动弹出选择座位界面
function LocalRooms:EnterRoomEventHandler(_uuid, _player)
	if FsmMgr.playerActFsm.curState.stateName == "Idle" or FsmMgr.playerActFsm.curState.stateName == "BowIdle" then
		local room = self:GetRoomByUuid(_uuid)
		if not room then
			return
		end
		if _player == localPlayer then
			self.room_localPlayer = room
		end
		room:EnterRoom(_player)
	end
end

--- 房间中玩家状态更改事件
function LocalRooms:StateChangedEventHandler(_room_uuid, _player, _state, _index)
    local room = self:GetRoomByUuid(_room_uuid)
    if not room then
        return
    end
    room:SwitchState(_player, _state, _index)
    if (_player == localPlayer and self:GetLPRoom() and self:GetLPRoom():HasHandZone()) then
        if (_index) then
            HandMapping:InitZone(room.num_id, room.local_table, _index)
        else
            HandMapping:LeaveGame()
        end
    end
	
	if _player == localPlayer and self:GetLPRoom() and _state == Const.GamingStateEnum.Gaming then
        CameraControl:SetSeat(_index, #(room.arr_gamingSeat))
    end
end

---本地玩家进入房间后的信息同步
function LocalRooms:EnterRoomSyncEventHandler(_uuid, _units_info, _stack_info)
    local room = self:GetRoomByUuid(_uuid)
    if not room then
        return
    end
    room:SyncRoomInfo(_units_info, _stack_info)
end

---自己刚刚进入游戏时候同步的房间事件
function LocalRooms:EnterGameSyncEventHandler(_data)
    for uuid, value in pairs(_data) do
        local room = LocalRoomBase:new(uuid, value.Owner, value.Position)
        for i, v in pairs(value.Watching) do
            room.arr_watchPlayers[v.UserId] = v
        end
        for i, v in pairs(value.Gaming) do
            room.arr_gamingPlayers[v.UserId] = v
        end
        room:ChangeGame(value.GameId)
        room.arr_gamingSeat = value.Seats
        room.bool_lock = value.Lock
        self.arr_rooms[uuid] = room
    end
end

---模型创建成功事件
function LocalRooms:ElementCreateEventHandler(_room_uuid, _uuid, _id, _pos)
    local room = self:GetRoomByUuid(_room_uuid)
    if not room then
        return
    end
    room:UnitCreate(_uuid, _id, _pos)
end

---对象进入手牌事件
function LocalRooms:ElementHandEventHandler(_room_uuid, _player, _uuid)
    local room = self:GetRoomByUuid(_room_uuid)
    if not room then
        return
    end
    room:UnitInHand(_uuid, _player)
end

---对象离开手牌事件
function LocalRooms:ElementOutHandEventHandler(_room_uuid, _uuid)
    local room = self:GetRoomByUuid(_room_uuid)
    if not room then
        return
    end
    room:UnitOutHand(_uuid)
end

---模型删除事件
function LocalRooms:ElementDestroyEventHandler(_room_uuid, _uuid)
    local room = self:GetRoomByUuid(_room_uuid)
    if not room then
        return
    end
    room:UnitDestroy(_uuid)
end

---堆叠创建事件
function LocalRooms:StackCreateEventHandler(_room_uuid, _uuid, _units, _player)
    local room = self:GetRoomByUuid(_room_uuid)
    if not room then
        return
    end
    room:StackCreate(_uuid, _units, _player)
end

---堆叠销毁事件
function LocalRooms:StackDestroyEventHandler(_room_uuid, _uuid)
    local room = self:GetRoomByUuid(_room_uuid)
    if not room then
        return
    end
    room:StackDestroy(_uuid)
end

---对象选中事件
function LocalRooms:ElementSelectEventHandler(_room_uuid, _player, _uuid)
    local room = self:GetRoomByUuid(_room_uuid)
    if not room then
        return
    end
    room:UnitSelect(_player, _uuid)
end

---对象取消选中事件
function LocalRooms:ElementCancelEventHandler(_room_uuid, _playerUid, _uuid, _pos)
    local room = self:GetRoomByUuid(_room_uuid)
    if not room then
        return
    end
    room:UnitCancel(_playerUid, _uuid, _pos)
end

---堆叠选中事件
function LocalRooms:StackSelectEventHandler(_room_uuid, _player, _uuid)
    local room = self:GetRoomByUuid(_room_uuid)
    if not room then
        return
    end
    room:StackSelect(_player, _uuid)
end

---堆叠取消选中事件
function LocalRooms:StackCancelEventHandler(_room_uuid, _player, _uuid, _pos)
    local room = self:GetRoomByUuid(_room_uuid)
    if not room then
        return
    end
    room:StackCancel(_player, _uuid, _pos)
end

---模型同步事件
function LocalRooms:ElementSyncEventHandler(_room_uuid, _info)
    local room = self:GetRoomByUuid(_room_uuid)
    if not room then
        return
    end
    room:UnitSync(_info)
    --print('本地模型同步事件')
end

---堆叠位置和旋转同步
function LocalRooms:StackSyncEventHandler(_room_uuid, _info)
    local room = self:GetRoomByUuid(_room_uuid)
    if not room then
        return
    end
    room:StackSync(_info)
    --print('本地堆叠同步事件')
end

---堆叠中添加对象事件
function LocalRooms:StackAddEventHandler(_room_uuid, _stack_uuid, _unit_uuid, _index)
    local room = self:GetRoomByUuid(_room_uuid)
    if not room then
        return
    end
    room:StackAdd(_stack_uuid, _unit_uuid, _index)
end

---堆叠中移除对象事件
function LocalRooms:StackRemoveEventHandler(_room_uuid, _player, _stack_uuid, _index)
    local room = self:GetRoomByUuid(_room_uuid)
    if not room then
        return
    end
    room:StackRemove(_player, _stack_uuid, _index)
end

--- 根据UUID获取指定的房间
---@return LocalRoomBase
function LocalRooms:GetRoomByUuid(_uuid)
    return self.arr_rooms[_uuid]
end

--- 获取本地玩家所在的游戏房间
function LocalRooms:GetLPRoom()
    return self.room_localPlayer
end

--- 获取本地房间中的玩家的座位号
function LocalRooms:GetPlayerSeat(_uid)
    local room = self:GetLPRoom()
    if room then
        return room:GetPlayerSeat(_uid)
    end
end

---根据UUID获取指定的对象实例,只有玩家在房间中才会执行
---@return C_UnitBase
function LocalRooms:GetUnitByUUID(_uuid)
    if self.room_localPlayer then
        return self.room_localPlayer:GetUnitByUUID(_uuid)
    end
end

---获取指定UUID的堆叠
------@return C_StackBase
function LocalRooms:GetStackByUUID(_uuid)
    if self.room_localPlayer then
        return self.room_localPlayer:GetStackByUUID(_uuid)
    end
end

---获取一个对象是否在堆叠中,返回所在的堆叠
---@return C_StackBase
function LocalRooms:CheckInStack(_uuid)
    if self.room_localPlayer then
        return self.room_localPlayer:CheckInStack(_uuid)
    end
end

---根据堆叠UUID获取其中的数量
function LocalRooms:GetStackCountByUUID(_uuid)
    if self.room_localPlayer then
        return self.room_localPlayer:GetStackCountByUUID(_uuid)
    end
end

---别的玩家进入游戏后,若当前玩家在桌游中,需要本地隐藏这个加入的玩家
function OtherPlayerAdded(_player)
    if self:GetLPRoom() then
        NotReplicate(function()
            _player.Avatar:SetActive(false)
        end)
    end
end

return LocalRooms