--- @module GameRoomBase 游戏房间基类
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local GameRoomBase = class('GameRoomBase')

---@module handZone
local handZone = class('handZone')
function handZone:initialize(_tableObj, _pos, _rot)
    self.m_obj = world:CreateInstance('HandZone', 'HandZone', _tableObj)
    self.m_obj.LocalPosition = _pos
    self.m_obj.LocalRotation = _rot
    self.m_obj:SetActive(false)
    self.m_size = Vector2(self.m_obj.Size.x, self.m_obj.Size.z)
    self.m_pos = self.m_obj.Position
end

function handZone:WorldToLocal(_pos)
    local delta = _pos - self.m_pos
    return Vector3(delta:Dot(self.m_obj.Right), delta:Dot(self.m_obj.Forward), delta:Dot(self.m_obj.Up))
end

--- @param _pos Vector3 世界坐标
function handZone:IsIn(_pos)
    local localDelta = self:WorldToLocal(_pos)
    if (math.abs(localDelta.x) > 0.5 * self.m_size.x) then
        return false
    end
    if (math.abs(localDelta.y) > 0.5 * self.m_size.y) then
        return false
    end
    return true
end

function handZone:Destroy()
    if self.m_obj and not self.m_obj:IsNull() then
        self.m_obj:Destroy()
    end
    table.cleartable(self)
end

--- 构造函数,房间创建后创建者自动进入房间
function GameRoomBase:initialize(_parent, _player, _pos, _maxNum, _lock)
    self.num_max = _maxNum
    self.vector3_pos = _pos
    self.num_id = -1
    self.t_config = {}
    self.str_uuid = 'Room_' .. UUID()
    ---世界下放置的桌子,供给外面的玩家看的
    self.model_worldTable = world:CreateInstance(Config.GlobalConfig.WorldTable, self.str_uuid, _parent, _pos)
    ---@type GameAniBase 房间的动画管理类
    self.ins_ani = GameAniBase:new(self)
    ---房间内所有的可以操作的对象实例
    self.arr_units = {}
    ---房间内所有的堆叠实例
    self.arr_stacks = {}
    ---房间中的游戏玩家
    self.arr_gamingPlayers = {}
    ---房间中的观战玩家
    self.arr_watchingPlayers = {}
    ---同步剩余时间
    self.num_syncTime = 1 / GlobalData.SyncFrequency_S
    ---房主
    self.player_owner = _player
    ---房间中的座位信息 key-座位索引 value-{Model:座位模型 Player:座位上的玩家}
    self.arr_seats = {}
    ---房间中的手牌区信息
    self.arr_handArea = {}
    ---房间是否被房主上锁
    self.bool_locked = _lock
    ---每个房间实例化后都会通知给所有的玩家
    NetUtil.Broadcast('RoomCreatedEvent', self.str_uuid, _player, _pos, _lock)
    self:TryEnter(_player)
    self.model_worldTable.GameName.NameTxt.Text = LanguageUtil.GetText(Config.GuiText.BoardGame_4.Txt), 3, true
    ---埋点
    UploadLog('creat_event', {
        user_id = _player.UserId,
        gameroot_id = CloudLogUtil.gameId,
        player_count = _maxNum
    })
end

---房间的更新函数
function GameRoomBase:Update(_dt)
    self.num_syncTime = self.num_syncTime - _dt
    if self.num_syncTime <= 0 then
        self.num_syncTime = 1 / GlobalData.SyncFrequency_S
        TrySync(self)
    end
    if self.num_id ~= -1 then
        self.ins_ani:Update(_dt)
    end
end

---更改房间的游戏,由房主进行
function GameRoomBase:Change(_id, _player)
    if _player ~= self.player_owner then
        print('必须由房主进行游戏的更改')
        return
    end
    ChangeGame(self, _id)

end

--- 玩家尝试进入房间,直接进入观战,相应的客户端弹出选择座位界面
function GameRoomBase:TryEnter(_player)
    if self:GetGameNum() + self:GetWatchNum() >= self.num_max then
        NetUtil.Fire_C('InsertInfoEvent', _player, LanguageUtil.GetText(Config.GuiText.BoardGame_5.Txt), 3, true)
        return
    end
    if BoardGameMgr:GetPlayerRoom(_player) then
        NetUtil.Fire_C('InsertInfoEvent', _player, LanguageUtil.GetText(Config.GuiText.BoardGame_5.Txt), 6, true)
        return
    end
    self.arr_watchingPlayers[_player.UserId] = _player
    LeaveSeat(self, _player)
    NetUtil.Broadcast('EnterRoomEvent', self.str_uuid, _player)
    -- NetUtil.Broadcast('StateChangedEvent', self.str_uuid, _player, Const.GamingStateEnum.Watching)
    SyncRoomInfo(self, _player)
    ---埋点
    UploadLog('join_event', {
        user_id = _player.UserId,
        gameroot_id = CloudLogUtil.gameId,
    })
	
	self:SwitchState(_player, Const.GamingStateEnum.Gaming)
end

--- 房主允许玩家进入游戏
function GameRoomBase:AllowEnter(_player, _enter_player, _index)
    if not _player or not _enter_player then
        return
    end
    if self.player_owner ~= _player then
		NetUtil.Fire_C('InsertInfoEvent', _player, LanguageUtil.GetText(Config.GuiText.BoardGame_8.Txt), 3, true)
        return
    end
    ---房主允许,按照传的座位索引尝试进入游戏
    if self.arr_gamingPlayers[_enter_player.UserId] then
		NetUtil.Fire_C('InsertInfoEvent', _player, LanguageUtil.GetText(Config.GuiText.BoardGame_9.Txt), 3, true)
        return
    end
    if self:GetGameNum() >= self.t_config.GameMaxNum then
		NetUtil.Fire_C('InsertInfoEvent', _player, LanguageUtil.GetText(Config.GuiText.BoardGame_10.Txt), 3, true)
        return
    end
    if TakeSeat(self, _enter_player, _index) then
        self.arr_watchingPlayers[_enter_player.UserId] = nil
        self.arr_gamingPlayers[_enter_player.UserId] = _enter_player
        NetUtil.Broadcast('StateChangedEvent', self.str_uuid, _enter_player, Const.GamingStateEnum.Gaming, _index)
    end
end

--- 玩家尝试对房间上锁状态进行更改
function GameRoomBase:TryChangeLock(_player, _lock)
    if self.player_owner ~= _player then
		NetUtil.Fire_C('InsertInfoEvent', _player, LanguageUtil.GetText(Config.GuiText.BoardGame_11.Txt), 3, true)
        return
    end
    if self.bool_locked and _lock then
		NetUtil.Fire_C('InsertInfoEvent', _player, LanguageUtil.GetText(Config.GuiText.BoardGame_12.Txt), 3, true)
        return
    end
    if not self.bool_locked and not _lock then
		NetUtil.Fire_C('InsertInfoEvent', _player, LanguageUtil.GetText(Config.GuiText.BoardGame_13.Txt), 3, true)
        return
    end
    self.bool_locked = _lock
    NetUtil.Broadcast('LockChangeEvent', self.str_uuid, _lock)
end

--- 玩家在房间时,切换游戏状态
---@param _index number 若是切换到游戏状态,则选择的座位号,不填会随机选择一个
function GameRoomBase:SwitchState(_player, _state, _index)
    if not self:CheckPlayer(_player) then
		NetUtil.Fire_C('InsertInfoEvent', _player, LanguageUtil.GetText(Config.GuiText.BoardGame_14.Txt), 3, true)
        return
    end
    if self.num_id == -1 then
        print('房主还未选择游戏')
        return
    end
    if _state == Const.GamingStateEnum.Watching then
        ---切换到观战状态
        if self.arr_watchingPlayers[_player.UserId] then
			NetUtil.Fire_C('InsertInfoEvent', _player, LanguageUtil.GetText(Config.GuiText.BoardGame_15.Txt), 3, true)
            return
        end
        self.arr_gamingPlayers[_player.UserId] = nil
        self.arr_watchingPlayers[_player.UserId] = _player
        LeaveSeat(self, _player)
        NetUtil.Broadcast('StateChangedEvent', self.str_uuid, _player, Const.GamingStateEnum.Watching)
    elseif _state == Const.GamingStateEnum.Gaming then
        ---切换到游戏状态
        if self.arr_gamingPlayers[_player.UserId] then
			NetUtil.Fire_C('InsertInfoEvent', _player, LanguageUtil.GetText(Config.GuiText.BoardGame_16.Txt), 3, true)
            return
        end
        if self:GetGameNum() >= self.t_config.GameMaxNum then
			NetUtil.Fire_C('InsertInfoEvent', _player, LanguageUtil.GetText(Config.GuiText.BoardGame_10.Txt), 3, true)
            return
        end
        if not _index then
            ---未传座位索引,需要在没有人的座位中随机一个
            for i, v in pairs(self.arr_seats) do
                if not v.Model.Seat.Occupant then
                    _index = i
                end
            end
        end
        if not _index then
            NetUtil.Fire_C('InsertInfoEvent', _player, LanguageUtil.GetText(Config.GuiText.BoardGame_17.Txt), 3, true)
            return
        end
        if self.bool_locked and _player ~= self.player_owner then
            ---房间上锁并且请求者不是房主,需要房主同意,给房主发消息
            NetUtil.Fire_C('RequestEnterEvent', self.player_owner, self.str_uuid, _player, _index)
        else
            ---房间未上锁或者是房主进行自己的状态更改,直接尝试按照传入的座位索引坐下
            if TakeSeat(self, _player, _index) then
                self.arr_watchingPlayers[_player.UserId] = nil
                self.arr_gamingPlayers[_player.UserId] = _player
                NetUtil.Broadcast('StateChangedEvent', self.str_uuid, _player, Const.GamingStateEnum.Gaming, _index)
            end
        end
    end
end

--- 玩家尝试离开房间
function GameRoomBase:TryLeave(_player)
    if not self:CheckPlayer(_player) then
        NetUtil.Fire_C('InsertInfoEvent', _player, LanguageUtil.GetText(Config.GuiText.BoardGame_14.Txt), 3, true)
        return
    end
    ---需要先取消选中自己选择的东西
    CancelSelectAll(self, _player)
    self.arr_gamingPlayers[_player.UserId] = nil
    self.arr_watchingPlayers[_player.UserId] = nil
    LeaveSeat(self, _player)
    OutAllHand(self, _player)
    NetUtil.Broadcast('LeaveRoomEvent', self.str_uuid, _player.UserId)
    if self.player_owner == _player then
        ---若是房主自己离开,需要转让房主,并检查房间中是否还有玩家
        self.player_owner = nil
        for i, v in pairs(self.arr_watchingPlayers) do
            self.player_owner = v
            break
        end
        for i, v in pairs(self.arr_gamingPlayers) do
            self.player_owner = v
            break
        end
        if not self.player_owner then
            ---房间中没有其他玩家了,销毁这个房间
            self:Destroy()
        else
            ---房间中仍存在其他玩家,通知所有人房主变更事件
            NetUtil.Broadcast('RoomOwnerChangedEvent', self.str_uuid, self.player_owner)
        end
    end
    ---埋点
    UploadLog('quit_event', {
        user_id = _player.UserId,
    })
end

--- 获取观战人数
function GameRoomBase:GetWatchNum()
    return table.nums(self.arr_watchingPlayers)
end

--- 获取游戏中的人数
function GameRoomBase:GetGameNum()
    return table.nums(self.arr_gamingPlayers)
end

--- 获取一个玩家是否在这个房间中
function GameRoomBase:CheckPlayer(_player)
    local player
    player = self.arr_watchingPlayers[_player.UserId] or self.arr_gamingPlayers[_player.UserId]
    return player and true or false
end

--- 检查一个玩家是否可以操作元素
function GameRoomBase:CheckOperate(_player)
    local player = self.arr_gamingPlayers[_player.UserId]
    return player and true or false
end

--- 销毁房间
function GameRoomBase:Destroy()
    ---销毁所有堆叠
    for i, v in pairs(self.arr_stacks) do
        DestroyStack(self, i)
    end
    ---销毁所有对象
    for i, v in pairs(self.arr_units) do
        DestroyElement(self, i)
    end
    ---销毁所有的座位
    DestroySeat(self)
    ---销毁所有手牌区
    DestroyHandArea(self)
    self.ins_ani:Destroy()
    ---所有玩家全部离开房间
    for i, v in pairs(self.arr_watchingPlayers) do
        NetUtil.Broadcast('LeaveRoomEvent', self.str_uuid, v.UserId)
    end
    for i, v in pairs(self.arr_gamingPlayers) do
        NetUtil.Broadcast('LeaveRoomEvent', self.str_uuid, v.UserId)
    end
    ---销毁外置桌子
    self.model_worldTable:Destroy()
    BoardGameMgr.arr_rooms[self.str_uuid] = nil
    ---通知所有玩家
    NetUtil.Broadcast('RoomDestroyEvent', self.str_uuid)
    table.cleartable(self)
end

--- 客户端尝试创建元素
function GameRoomBase:TryCreateElement(_id, _pos)
    return CreateElement(self, _id, _pos)
end

--- 客户端尝试删除元素
function GameRoomBase:TryDestroyElement(_uuid)
    DestroyElement(self, _uuid)
end

--- 客户端尝试选中
function GameRoomBase:TrySelect(_player, _uuid)
    if not self:CheckOperate(_player) then
        return
    end
    Select(self, _player, _uuid)
end

---客户端尝试取消选中
function GameRoomBase:TryCancelSelect(_player, _uuid, _pos)
    CancelSelect(self, _player, _uuid, _pos)
end

--- 客户端尝试选择堆叠
function GameRoomBase:TrySelectStack(_player, _uuid, _isAll)
    if not self:CheckOperate(_player) then
        return
    end
    SelectStack(self, _player, _uuid, _isAll)
end

--- 客户端尝试创建堆叠
function GameRoomBase:TryCreateStack(_player, _type, _shuffle)
    if not self:CheckOperate(_player) then
        return
    end
    CreateStack(self, _player, _type, _shuffle)
end

--- 客户端尝试堆叠中插入一个
function GameRoomBase:TryStackAdd(_player, _stack_uuid, _unit_uuid)
    if not self:CheckOperate(_player) then
        return
    end
    StackAdd(self, _player, _stack_uuid, _unit_uuid)
end

--- 客户端销毁堆叠
function GameRoomBase:TryDestroyStack(_uuid)
    DestroyStack(self, _uuid)
end

--- 客户端尝试取消选中堆叠
function GameRoomBase:TryCancelSelectStack(_player, _uuid, _pos)
    CancelSelectStack(self, _player, _uuid, _pos)
end

--- 客户端尝试吸附一个对象到选中物体中
function GameRoomBase:TryAdsorb(_player, _uuid)
    if not self:CheckOperate(_player) then
        return
    end
    ---@type S_UnitBase
    local unit = self.arr_units[_uuid]
    if not unit then
        return
    end
    local type = unit:GetType()
    if type == Const.ElementsTypeEnum.UnlimitedStack then
        return
    end
    local owner = unit:GetOwner()
    if owner and owner ~= _player then
        return
    elseif owner and owner == _player then
        ---这个对象是在选中中的,尝试创建堆叠并打乱
        CreateStack(self, _player, type, true)
    else
        ---尝试形成这个类型的堆叠
        CreateStack(self, _player, type)
        local units, stacks = BoardGameMgr:GetTypeSelected(_player, type)
        Select(self, _player, _uuid)
        if table.nums(stacks) > 0 then
            ---有形成的堆叠,只可能有一个,将此对象加入堆叠最下面,并取消选择个对象
            for i, v in pairs(stacks) do
                --wait(2)
                StackAdd(self, _player, i, _uuid)
                break
            end
        elseif table.nums(units) > 0 then
            ---没有形成的堆叠,只有对象并且只可能有一个.将这个对象和吸附的对象形成堆叠,并将吸附对象放在最下面
            for i, v in pairs(units) do
                unit:Select(_player)
                v:Select(_player)
                ---@type S_StackBase
                local stack = S_StackBase:new({ v, unit })
                local uuid = stack.str_uuid
                self.arr_stacks[uuid] = stack
                stack:Select(_player)
                Broadcast('StackCreateEvent', uuid, stack:GetUnitsUUID(), _player)
                Broadcast('StackSelectEvent', _player, uuid)
                break
            end
        else
            ---没有形成的堆叠和对象,只能追加选择,不做任何其他操作

        end
    end
end

---物品旋转和翻转
---@param _infoLst table key-uuid value-最新的角度
function GameRoomBase:TryRotateElement(_player, _infoLst)
    if not self:CheckOperate(_player) then
        return
    end
    for uuid, rot in pairs(_infoLst) do
        ---@type S_UnitBase
        local unit = self.arr_units[uuid]
        if unit then
            unit:UpdateRotation(_player, rot)
        end
    end
end

---物品移动
function GameRoomBase:TryMoveElement(_player, _infoLst)
    if not self:CheckOperate(_player) then
        return
    end
    for uuid, v in pairs(_infoLst) do
        ---@type S_UnitBase
        local unit = self.arr_units[uuid]
        if unit then
            unit:UpdatePosition(_player, v[1], v[2], v[3], v[4])
        end
    end
end

---堆叠移动
function GameRoomBase:TryMoveStack(_player, _infoLst)
    if not self:CheckOperate(_player) then
        return
    end
    for uuid, v in pairs(_infoLst) do
        ---@type S_StackBase
        local stack = self.arr_stacks[uuid]
        if stack then
            stack:UpdatePosition(_player, v[1], v[2], v[3], v[4])
        end
    end
end

---堆叠旋转
function GameRoomBase:TryRotateStack(_player, _infoLst)
    if not self:CheckOperate(_player) then
        return
    end
    for uuid, rot in pairs(_infoLst) do
        ---@type S_StackBase
        local stack = self.arr_units[uuid]
        if stack then
            stack:UpdateRotation(_player, rot)
        end
    end
end

--- 更改游戏,销毁房间中所有对象,所有玩家离开游戏状态,进入观战状态,然后房主进入一号位游戏
function ChangeGame(self, _id)
    if _id == -1 then
        print('当前房间未选择游戏,不可以重置游戏')
        return
    end
    if not Config.Game[_id].Enable then
        print('此游戏暂未开启')
        return
    end
    self.num_id = _id
    self.t_config = Config.Game[_id]
    self.model_worldTable.GameName.NameTxt.Text = self.t_config.Name
    ---销毁所有堆叠
    for i, v in pairs(self.arr_stacks) do
        DestroyStack(self, i)
    end
    ---销毁所有对象
    for i, v in pairs(self.arr_units) do
        DestroyElement(self, i)
    end
    ---游戏状态的玩家切换状态为观战
    for i, v in pairs(self.arr_gamingPlayers) do
        print('游戏状态的玩家切换状态为观战', v)
        self:SwitchState(v, Const.GamingStateEnum.Watching)
    end
    NetUtil.Broadcast('RoomGameChangedEvent', self.str_uuid, _id)
    DestroySeat(self)
    DestroyHandArea(self)
    PreCreateSeat(self)
    PreCreateUnits(self)
    PreCreateStack(self)
    PreCreateHandArea(self)
    self.ins_ani:ChangeGame(_id)
    self:SwitchState(self.player_owner, Const.GamingStateEnum.Gaming, 1)
    ---埋点
    UploadLog('select_event', {
        game_id = _id,
    })
end

---检查所有对象上一帧的位置和旋转并进行同步
function TrySync(self)
    local syncData, isSync = {}, false
    for uuid, unit in pairs(self.arr_units) do
        if unit:GetStack() then
            ---元素在堆叠中,不直接同步元素,同步堆叠
            goto Continue
        end
        local posChange, rotChange = unit:IsChanged()
        if posChange then
            ---单位这个时间点的数据和上一次同步的数据不同,需要进行一次同步操作
            local latestPosData = unit:GetLatestPosData()
            syncData[uuid] = syncData[uuid] or {}
            syncData[uuid].Position = latestPosData
            unit:TrySyncPos()
            isSync = true
        end
        if rotChange then
            local latestRotData = unit:GetLatestRotData()
            syncData[uuid] = syncData[uuid] or {}
            syncData[uuid].Rotation = latestRotData
            unit:TrySyncRot()
            isSync = true
        end
        :: Continue ::
    end
    if isSync then
        Broadcast('ElementSyncEvent', self, syncData)
    end
    syncData, isSync = {}, false
    for uuid, stack in pairs(self.arr_stacks) do
        local posChange, rotChange = stack:IsChanged()
        if posChange then
            local latestPosData = stack:GetLatestPosData()
            syncData[uuid] = syncData[uuid] or {}
            syncData[uuid].Position = latestPosData
            stack:TrySyncPos()
            isSync = true
        end
        if rotChange then
            local latestRotData = stack:GetLatestRotData()
            syncData[uuid] = syncData[uuid] or {}
            syncData[uuid].Rotation = latestRotData
            stack:TrySyncRot()
            isSync = true
        end
    end
    if isSync then
        Broadcast('StackSyncEvent', self, syncData)
    end
end

--- 世界下生成对象
function CreateElement(self, _id, _originPos)
    ---@type S_UnitBase
    local s_unit
    if Config.Unit[_id].Type == Const.ElementsTypeEnum.UnlimitedStack then
        s_unit = S_UnlimitedStackBase:new(_id, _originPos, self.num_id, self.model_worldTable.Position)
    else
        s_unit = S_UnitBase:new(_id, _originPos, self.num_id, self.model_worldTable.Position)
    end
    self.arr_units[s_unit.m_uuid] = s_unit
    Broadcast('ElementCreateEvent', self, s_unit.m_uuid, _id, _originPos)
    return s_unit.m_uuid
end

--- 放入手牌区
function HandIn(self, _player, _uuid)
    ---@type S_UnitBase
    local unit = self.arr_units[_uuid]
    if not unit then
        return
    end
    if unit:InHand(_player) then
        Broadcast('ElementHandEvent', self, _player, _uuid)
        self.ins_ani:Play(_player.UserId, Const.GameAniEnum.InHand)
    end
end

--- 对象取消选择后尝试检测是否在某个玩家的手牌区,若在则进入此玩家的手牌
function CheckInHand(self, _uuid)
    ---@type S_UnitBase
    local unit = self.arr_units[_uuid]
    if not unit then
        return
    end
    if unit:GetStack() or not unit.config.InHand then
        return
    end
    local index
    for i, v in pairs(self.arr_handArea) do
        if v:IsIn(unit.m_position) then
            index = i
            break
        end
    end
    if not index then
        return
    end
    local player = self.arr_seats[index].Player
    if not player then
        return
    end
    HandIn(self, player, _uuid)
end

--- 离开手牌区
function HandOut(self, _uuid, _player)
    ---@type S_UnitBase
    local unit = self.arr_units[_uuid]
    if not unit then
        return
    end
    if unit:OutHand() then
        Broadcast('ElementOutHandEvent', self, _uuid)
        self.ins_ani:Play(_player.UserId, Const.GameAniEnum.OutHand)
    end
end

---世界下销毁对象
function DestroyElement(self, _uuid)
    local unit = self.arr_units[_uuid]
    if unit then
        if unit:GetStack() then
            print('不可以销毁牌堆中的牌')
            return
        end
        unit:Destroy()
    end
    self.arr_units[_uuid] = nil
    Broadcast('ElementDestroyEvent', self, _uuid)
end

---选择对象
function Select(self, _player, _uuid)
    ---@type S_UnitBase
    local s_unit = self.arr_units[_uuid]
    if s_unit and s_unit:Select(_player, self) then
        Broadcast('ElementSelectEvent', self, _player, _uuid)
        self.ins_ani:Play(_player.UserId, Const.GameAniEnum.Select)
    end
    HandOut(self, _uuid, _player)
end

---取消选择对象
function CancelSelect(self, _player, _uuid, _pos)
    ---@type S_UnitBase
    local s_unit = self.arr_units[_uuid]
    if s_unit then
        if s_unit:CancelSelect(_player, _pos) then
            Broadcast('ElementCancelEvent', self, _player.UserId, _uuid, _pos)
            self.ins_ani:Play(_player.UserId, Const.GameAniEnum.Cancel)
        end
    end
    CheckInHand(self, _uuid)
end

---选择堆叠
function SelectStack(self, _player, _uuid, _isAll)
    ---@type S_StackBase
    local stack = self.arr_stacks[_uuid]
    if not stack then
        return
    end
    print('选择堆叠', _player, _uuid, _isAll)
    if _isAll then
        ---尝试选择这个堆叠
        if stack:Select(_player) then
            Broadcast('StackSelectEvent', self, _player, _uuid)
            self.ins_ani:Play(_player.UserId, Const.GameAniEnum.Select)
        end
    else
        ---尝试选中这个堆叠上面的一个元素,若堆叠中只有两个元素,则堆叠会被销毁
        local count = stack:GetCount()
        local unit = stack:Remove(count)
        Broadcast('StackRemoveEvent', self, _player, _uuid, count)
        if count == 2 then
            ---需要销毁这个堆叠
            DestroyStack(self, _uuid)
        end
        --Broadcast('ElementCancelEvent', self, _player, unit.m_uuid)
        if unit:Select(_player) then
            Broadcast('ElementSelectEvent', self, _player, unit.m_uuid)
            self.ins_ani:Play(_player.UserId, Const.GameAniEnum.Select)
        end
    end
end

---创建堆叠
function CreateStack(self, _player, _type, _shuffle)
    local arr_selectedUnits, arr_selectedStacks = BoardGameMgr:GetSelected(_player)
    ---key-type value-uuids
    local info = {}
    for i, v in pairs(arr_selectedUnits) do
        local type = v:GetType()
        if _type then
            ---当前尝试堆叠指定的类型
            if _type == type then
                info[type] = info[type] or {}
                table.insert(info[type], i)
            end
        else
            info[type] = info[type] or {}
            table.insert(info[type], i)
        end
        :: Continue ::
    end
    for i, v in pairs(arr_selectedStacks) do
        local type = v:GetType()
        if _type then
            ---当前尝试堆叠指定的类型
            if _type == type then
                info[type] = info[type] or {}
                table.insert(info[type], i)
            end
        else
            info[type] = info[type] or {}
            table.insert(info[type], i)
        end
    end

    local s_units = {}
    for type, v in pairs(info) do
        local type_units = {}
        for _, uuid in pairs(v) do
            if string.startswith(uuid, 'Stack_') then
                ---@type S_StackBase 这个是堆叠
                local stack = self.arr_stacks[uuid]
                if stack and not (stack:GetOwner() and stack:GetOwner() ~= _player) then
                    ---若当前这个堆叠是由这个玩家选中的,则需要先取消选中
                    local units = stack:GetUnits()
                    table.insertto(type_units, units)
                    DestroyStack(self, uuid)
                end
            end
            if string.startswith(uuid, 'Unit_') then
                ---@type S_UnitBase 这个是对象
                local unit = self.arr_units[uuid]
                if unit and not (unit:GetOwner() and unit:GetOwner() ~= _player) then
                    ---当前这个对象是这个玩家选中的,则需要先取消这个的选中
                    if unit:CancelSelect(_player) then
                        Broadcast('ElementCancelEvent', self, _player.UserId, uuid)
                    end
                    table.insert(type_units, unit)
                end
            end
        end
        if #type_units > 1 then
            ---这个类型的对象数量超过1个,可以形成这个对象的堆叠
            s_units[type] = type_units
        elseif #type_units == 1 then
            ---这个类型对象只有一个,选中这个对象(可能需要根据参数)
            if type_units[1]:Select(_player) then
                Broadcast('ElementSelectEvent', self, _player, type_units[1].m_uuid)
            end
        end
    end
    if table.nums(s_units) == 0 then
        return
    end
    for type, v in pairs(s_units) do
        if _shuffle then
            v = Shuffle(v)
        end
        ---@type S_StackBase
        local stack = S_StackBase:new(v)
        local uuid = stack.str_uuid
        self.arr_stacks[uuid] = stack
        stack:Select(_player)
        Broadcast('StackCreateEvent', self, uuid, stack:GetUnitsUUID(), _player)
        Broadcast('StackSelectEvent', self, _player, uuid)
    end
end

---堆叠取消选中
function CancelSelectStack(self, _player, _uuid, _pos)
    ---@type S_StackBase
    local stack = self.arr_stacks[_uuid]
    if not stack then
        return
    end
    stack:CancelSelect(_player, _pos)
    Broadcast('StackCancelEvent', self, _player, stack.str_uuid, _pos)
    self.ins_ani:Play(_player.UserId, Const.GameAniEnum.Cancel)
end

---堆叠中插入一个
function StackAdd(self, _player, _stack_uuid, _unit_uuid)
    ---@type S_StackBase
    local stack = self.arr_stacks[_stack_uuid]
    ---@type S_UnitBase
    local unit = self.arr_units[_unit_uuid]
    if not stack or not unit then
        print('堆叠或者对象不存在')
        return
    end
    if unit:GetStack() then
        print('对象已经在堆叠中了')
        return
    end
    if stack:GetOwner() ~= _player or unit:GetOwner() ~= _player then
        print('堆叠或对象选中玩家不正确')
        return
    end
    if stack:GetType() ~= unit:GetType() then
        print('对象类型和堆叠类型不同,不可以插入')
        return
    end
    Broadcast('ElementCancelEvent', self, _player.UserId, _unit_uuid)
    stack:Add(1, unit)
    Broadcast('StackAddEvent', self, _stack_uuid, _unit_uuid, 1)
end

---销毁堆叠
function DestroyStack(self, _uuid)
    ---@type S_StackBase
    local s_stack = self.arr_stacks[_uuid]
    if not s_stack then
        return
    end
    local owner = s_stack:GetOwner()
    if owner then
        s_stack:CancelSelect(owner)
        Broadcast('StackCancelEvent', self, owner, _uuid)
    end
    s_stack:Destroy()
    self.arr_stacks[_uuid] = nil
    Broadcast('StackDestroyEvent', self, _uuid)
    print('销毁堆叠,当前剩余堆叠数量为:', table.nums(self.arr_stacks))
end

---根据游戏最大人数,预创建指定数量的座位供玩家坐  无高度偏移
function PreCreateSeat(self)
    local angle = 2 * math.pi / self.t_config.GameMaxNum
    for i = 0, self.t_config.GameMaxNum - 1 do
        local x = math.cos(angle * i) * self.t_config.WorldTableRadius
        local z = math.sin(angle * i) * self.t_config.WorldTableRadius
        local seat = world:CreateInstance(self.t_config.WorldSeat, '世界下椅子_' .. tostring(i), self.model_worldTable)
        seat.LocalPosition = Vector3(x, 0, z)
        seat.Forward = self.model_worldTable.Position - seat.Position
        table.insert(self.arr_seats, { Model = seat, Player = nil })
    end
end

---根据游戏配置预创建指定的道具
function PreCreateUnits(self)
    for i, v in pairs(self.t_config.PreCreate) do
        CreateElement(self, v.Id, v.Position + self.t_config.Focus + self.model_worldTable.Position)
    end
end

---根据游戏配置预先创建指定的堆叠
function PreCreateStack(self)
    ---先生成堆叠中的对象
    for i, v in pairs(self.t_config.PreCreateStack) do
        local pos = v.Position
        local units = {}
        for index, unit_id in ipairs(v.Units) do
            local unit_uuid = CreateElement(self, unit_id, pos + self.t_config.Focus + self.model_worldTable.Position + (index - 1) * Vector3.Up * Config.Unit[unit_id].Height)
            table.insert(units, self.arr_units[unit_uuid])
        end
        ---@type S_StackBase
        local stack = S_StackBase:new(units)
        local uuid = stack.str_uuid
        self.arr_stacks[uuid] = stack
        Broadcast('StackCreateEvent', self, uuid, stack:GetUnitsUUID())
    end
end

---根据配置生成每个座位对应的手牌区数据
function PreCreateHandArea(self)
    for i, v in pairs(self.t_config.HandCard) do
        local handArea = handZone:new(self.model_worldTable, v.Position, v.Rotation)
        table.insert(self.arr_handArea, handArea)
    end
end

---销毁所有座位
function DestroySeat(self)
    LeaveSeat(self)
    for i, v in pairs(self.arr_seats) do
        v.Model:Destroy()
    end
    self.arr_seats = {}
end

---销毁所有手牌区
function DestroyHandArea(self)
    for i, v in pairs(self.arr_handArea) do
        v:Destroy()
    end
    self.arr_handArea = {}
end

---玩家入座,按照索引坐在这个位置上
---@param _player PlayerInstance 入座的玩家
---@param _index number 尝试入座的索引
---@return number 返回当前坐下的座位索引
function TakeSeat(self, _player, _index)
    local seat = self.arr_seats[_index]
    if not seat then
        print('该索引座位不存在', _index)
        return false
    end
    if seat.Model.Seat.Occupant then
        NetUtil.Fire_C('InsertInfoEvent', _player, LanguageUtil.GetText(Config.GuiText.BoardGame_18.Txt), 3, true)
        return false
    end
    invoke(function()
        wait()
        if self.arr_gamingPlayers and not seat.Model:IsNull() then
            seat.Model.Seat:Sit(_player)
        end
    end)
    seat.Player = _player
    _player.Avatar:PlayAnimation('SitIdle', 2, 1, 0, true, true, 1)
    self.ins_ani:Seat(_player.UserId)
    return true
end

---玩家出座
---@param _player PlayerInstance 出座的玩家,不填则将所谓玩家全部出座
function LeaveSeat(self, _player)
    if not _player then
        for i, v in ipairs(self.arr_seats) do
            local player = v.Model.Seat.Occupant
            v.Model.Seat:Leave()
            if player then
                player.Avatar:StopAnimation('SitIdle', 2)
                player.Position = player.Position + player.Back + Vector3.Up * 0.5
                self.ins_ani:LeaveSeat(player.UserId)
            end
        end
    else
        for i, v in ipairs(self.arr_seats) do
            if v.Model.Seat.Occupant == _player then
                v.Model.Seat:Leave()
                _player.Avatar:StopAnimation('SitIdle', 2)
                _player.Position = _player.Position + _player.Back + Vector3.Up * 0.5
            end
        end
        self.ins_ani:LeaveSeat(_player.UserId)
    end
end

---将一个玩家所有手牌移出手牌区
function OutAllHand(self, _player)
    for uuid, unit in pairs(self.arr_units) do
        if unit:GetHandPlayer() == _player then
            HandOut(self, uuid, _player)
        end
    end
end

---取消一个玩家选择的所有对象
---@param self GameRoomBase
function CancelSelectAll(self, _player)
    if self:CheckPlayer(_player) then
        for i, v in pairs(self.arr_units) do
            if v:GetOwner() == _player and not v:GetStack() then
                CancelSelect(self, _player, i)
            end
        end
        for i, v in pairs(self.arr_stacks) do
            if v:GetOwner() == _player then
                CancelSelectStack(self, _player, i)
            end
        end
    end
end

---玩家进入房间后的房间对象信息同步
function SyncRoomInfo(self, _player)
    local unitsInfo, stackInfo = {}, {}
    for i, v in pairs(self.arr_units) do
        local info = {
            Uuid = v.m_uuid,
            Id = v.m_id,
            Owner = v.m_owner,
            Stack = v:GetStack() and v:GetStack().str_uuid or nil,
            Rotation = v:GetLatestRotData(),
            Position = v:GetLatestPosData(),
            HandPlayer = v:GetHandPlayer(),
        }
        unitsInfo[i] = info
    end
    for i, v in pairs(self.arr_stacks) do
        local info = {
            Uuid = v.str_uuid,
            Owner = v.player_owner,
            Units = {},
        }
        for _, s_unit in pairs(v:GetUnits()) do
            table.insert(info.Units, s_unit.m_uuid)
        end
        stackInfo[i] = info
    end
    NetUtil.Fire_C('EnterRoomSyncEvent', _player, self.str_uuid, unitsInfo, stackInfo)
end

---向房间中的所有玩家广播,默认广播的第一个参数是房间UUID
function Broadcast(_event, self, ...)
    NetUtil.R_Broadcast(_event, self.arr_gamingPlayers, self.str_uuid, ...)
    NetUtil.R_Broadcast(_event, self.arr_watchingPlayers, self.str_uuid, ...)
end

---桌游模拟器自带埋点函数
function UploadLog(_key, _table)
    local arg = LuaJsonUtil:encode(_table)
    TrackService.CloudLogFromServer({ _key, 'Z1004', arg })
end

return GameRoomBase