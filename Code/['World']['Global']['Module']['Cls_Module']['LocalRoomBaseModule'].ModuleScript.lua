--- @module LocalRoomBase 本地的房间管理类
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local LocalRoomBase = class('LocalRoomBase')

--- 构造函数
function LocalRoomBase:initialize(_uuid, _player, _pos, _lock)
    ---桌游的位置
    self.vector3_pos = _pos
    self.num_id = -1
    self.t_config = {}
    self.str_uuid = _uuid
    ---房主
    self.player_owner = _player
    ---桌游区域的触发器
    self.model_trigger = world:CreateInstance(Config.GlobalConfig.WorldTable, 'model_trigger', localPlayer.Local.Independent, _pos)
    self.model_trigger.Color = Color(0, 0, 0, 0)
    self.model_trigger.Block = false
    self.model_trigger.CollisionGroup = localPlayer.CollisionGroup
    for i, v in pairs(self.model_trigger:GetChildren()) do
        v:SetActive(false)
    end
    local function Enter(_obj)
        if _obj == localPlayer then
            self:EnterRange()
        end
    end
    local function Leave(_obj)
        if _obj == localPlayer then
            self:LeaveRange()
			NetUtil.Fire_C('OutlineCtrlEvent', _obj, self.model_trigger, false)
        end
    end
    self.model_trigger.OnCollisionBegin:Connect(Enter)
	self.model_trigger.OnCollisionEnd:Connect(Leave)
    ---玩家本地的桌子
    self.local_table = nil
    ---本地桌子的默认焦点
    self.pos_focus = Config.GlobalConfig.LocalTableOffset

    ---观战玩家
    self.arr_watchPlayers = {}
    ---游戏中玩家
    self.arr_gamingPlayers = {}
    ---游戏中玩家座位索引key-座位索引 value-玩家UID
    self.arr_gamingSeat = {}

    ---本地维护的对象列表
    self.arr_units = {}
    ---本地维护的堆叠列表
    self.arr_stacks = {}
    ---此房间桌子的吸附位置点
    self.arr_adsorbPos = {}

    ---世界区域的桌子
    self.world_table = nil
    invoke(function()
        self.world_table = world.WorldTables:WaitForChild(self.str_uuid)
        if _player == localPlayer then
            HideWorldTable(self)
        end
    end)

    self.bool_lock = _lock
    ---本地玩家是否在这个房间中
    self.bool_lpIn = false
    print('本地接受房间创建事件, ', _uuid, _player, _pos)
end

function LocalRoomBase:Update(_dt)
    local unit_num, stack_num = SelectedObjs:GetSelectNum()
    for i, v in pairs(self.arr_units) do
        v:Update(_dt)
        if unit_num == 1 and stack_num == 0 then
            v:UpdateRange()
        end
    end
    for i, v in pairs(self.arr_stacks) do
        if unit_num == 0 and stack_num == 1 then
            v:UpdateRange()
        end
    end
end

--- FixUpdate函数
--- @param _dt number delta time 每帧时间
function LocalRoomBase:FixUpdate(_dt)
    for i, v in pairs(self.arr_units) do
        v:FixUpdate(_dt)
    end
end

--- 玩家进入房间的区域内
function LocalRoomBase:EnterRange()
    print('玩家靠近游戏区域, ', self.str_uuid)
    GameGui.m_roomUuid = self.str_uuid
	--- 打开交互按钮
	for k,v in pairs(world.WorldTables:GetChildren()) do
		if v.Name == self.str_uuid then
			NetUtil.Fire_C('OutlineCtrlEvent', localPlayer, v, true)
		end
	end
	NetUtil.Fire_C('OpenDynamicEvent', localPlayer, 'Interact', 32)
end

--- 玩家进入房间的区域内
function LocalRoomBase:LeaveRange()
	for k,v in pairs(world.WorldTables:GetChildren()) do
		if v.Name == self.str_uuid then
			NetUtil.Fire_C('OutlineCtrlEvent', localPlayer, v, false)
		end
	end
    GameGui.m_roomUuid = ''
	--- 关闭交互按钮
	NetUtil.Fire_C('CloseDynamicEvent', localPlayer, 'Interact')
end

---玩家进入房间,进入观战列表,若进入玩家为本地玩家,则需要进行摄像机处理和本地的桌子创建
function LocalRoomBase:EnterRoom(_player)
    self.arr_watchPlayers[_player.UserId] = _player
    if _player == localPlayer then
        UpdateTable(self)
        UpdateAdsorb(self)
		UpdateHandZone(self)
        InitCam(self)
        self.bool_lpIn = true
        ---本地关闭游戏中所有的玩家显示
        HidePlayers(self)
        HideWorldTable(self)
    end
end

---本地玩家尝试形成堆叠
function LocalRoomBase:TryCreateStack(_type)
    NetUtil.Fire_S('TryCreateStackEvent', localPlayer, _type)
end

---本地玩家尝试创建对象
---@param _id number 尝试创建的对象的ID
---@param _pos Vector3 对象的相对位置
function LocalRoomBase:TryCreateUnit(_id, _pos)
    NetUtil.Fire_S('TryCreateElementEvent', self.str_uuid, _id, self.pos_focus + self.local_table.Position + _pos)
end

--- 玩家房间中状态更改
function LocalRoomBase:SwitchState(_player, _state, _index)
    if _state == Const.GamingStateEnum.Watching then
        self.arr_gamingPlayers[_player.UserId] = nil
        self.arr_watchPlayers[_player.UserId] = _player
		for index, uid in pairs(self.arr_gamingSeat) do
            if uid == _player.UserId then
                self.arr_gamingSeat[index] = -1
				if(self:HasHandZone() and index and self.local_table and self.local_table['HandZone' .. index]) then
					self.local_table['HandZone' .. index].SurfaceGUI.TxtName.Text = '手牌区'
				end
            end
        end
    elseif _state == Const.GamingStateEnum.Gaming then
        self.arr_watchPlayers[_player.UserId] = nil
        self.arr_gamingPlayers[_player.UserId] = _player
        self.arr_gamingSeat[_index] = _player.UserId
		if(self:HasHandZone() and _index and self.local_table and self.local_table['HandZone' .. _index]) then
			self.local_table['HandZone' .. _index].SurfaceGUI.TxtName.Text = _player.Name
		end
    end
end

--- 玩家退出这个房间
function LocalRoomBase:LeaveRoom(_uid)
    self.arr_watchPlayers[_uid] = nil
    self.arr_gamingPlayers[_uid] = nil
    for index, uid in pairs(self.arr_gamingSeat) do
        if uid == _uid then
            self.arr_gamingSeat[index] = -1
			if(self:HasHandZone() and self.local_table) then
				self.local_table['HandZone' .. index].SurfaceGUI.TxtName.Text = '手牌区'
			end
		end
    end
    if _uid == localPlayer.UserId then
        RestoreCam(self)
        DestroyUnits(self)
        self.bool_lpIn = false
        ---本地开启所有的玩家形象展示
        ShowPlayers(self)
        ShowWorldTable(self)
    end
end

--- 房间游戏更改
function LocalRoomBase:ChangeGame(_id)
    self.num_id = _id
    if not Config.Game[_id] then
        return
    end
    self.t_config = Config.Game[_id]
    self.pos_focus = self.t_config.Focus
    self.arr_gamingSeat = {}
    for i = 1, self.t_config.GameMaxNum do
        table.insert(self.arr_gamingSeat, -1)
    end
    if self:CheckLocalPlayerIn() then
        UpdateTable(self)
        UpdateAdsorb(self)
		UpdateHandZone(self)
    end
end

--- 房间房主更改
function LocalRoomBase:ChangeOwner(_player)
    self.player_owner = _player
end

--- 房间的上锁状态更改
function LocalRoomBase:LockChange(_lock)
    self.bool_lock = _lock
end

function LocalRoomBase:HasEmptySeat()
	for i, v in pairs(self.arr_gamingSeat) do
		if(v == -1) then
			return true
		end
	end
	return false
end

function LocalRoomBase:Destroy()
    self.model_trigger.OnCollisionBegin:Clear()
    self.model_trigger:Destroy()
    table.cleartable(self)
end

function LocalRoomBase:UnitCreate(_uuid, _id, _pos)
    ---@type C_UnitBase
    local obj
    if Config.Unit[_id].Type == Const.ElementsTypeEnum.UnlimitedStack then
        obj = C_UnlimitedStackBase:new(_uuid, _id, _pos, self.local_table, self.arr_adsorbPos, self.num_id)
    else
        obj = C_UnitBase:new(_uuid, _id, _pos, self.local_table, self.arr_adsorbPos, self.num_id)
    end
    self.arr_units[_uuid] = obj
end

function LocalRoomBase:UnitInHand(_uuid, _player)
    ---@type C_UnitBase
    local obj = self.arr_units[_uuid]
    if obj then
        obj:InHand(_player)
    end
end

function LocalRoomBase:UnitOutHand(_uuid)
    ---@type C_UnitBase
    local obj = self.arr_units[_uuid]
    if obj then
        obj:OutHand()
    end
end

function LocalRoomBase:UnitDestroy(_uuid)
    SelectedObjs:Destroy(_uuid)
    ---@type C_UnitBase
    local obj = self.arr_units[_uuid]
    if obj then
        obj:Destroy()
        self.arr_units[_uuid] = nil
    end
end

function LocalRoomBase:StackCreate(_uuid, _units, _player)
    print('堆叠创建事件')
    local c_units = {}
    for i, v in pairs(_units) do
        ---@type C_UnitBase
        local c_unit = self.arr_units[v]
        if c_unit then
            table.insert(c_units, c_unit)
        end
    end
    if #c_units > 0 then
        ---@type C_StackBase
        local c_stack = C_StackBase:new(_uuid, c_units, _player, self.local_table, self.arr_adsorbPos)
        self.arr_stacks[_uuid] = c_stack
    end
end

function LocalRoomBase:StackDestroy(_uuid)
    ---@type C_StackBase
    local c_stack = self.arr_stacks[_uuid]
    if not c_stack then
        return
    end
    c_stack:Destroy()
    self.arr_stacks[_uuid] = nil
end

function LocalRoomBase:UnitSelect(_player, _uuid)
    ---@type C_UnitBase
    local obj = self.arr_units[_uuid]
    if not obj then
        return
    end
    obj:Select(_player)
end

function LocalRoomBase:UnitCancel(_playerUid, _uuid, _pos)
    ---@type C_UnitBase
    local obj = self.arr_units[_uuid]
    if not obj then
        return
    end
    obj:CancelSelect(_playerUid, _pos)
end

function LocalRoomBase:StackSelect(_player, _uuid)
    ---@type C_StackBase
    local obj = self.arr_stacks[_uuid]
    if not obj then
        return
    end
    obj:Select(_player)
end

function LocalRoomBase:StackCancel(_player, _uuid, _pos)
    ---@type C_StackBase
    local obj = self.arr_stacks[_uuid]
    if not obj then
        return
    end
    obj:CancelSelect(_player, _pos)
end

function LocalRoomBase:UnitSync(_info)
    for uuid, v in pairs(_info) do
        ---@type C_UnitBase
        local unit = self.arr_units[uuid]
        if unit then
            if v.Position then
                unit:SyncPosition(table.unpack(v.Position))
            end
            if v.Rotation then
                unit:SyncRotation(table.unpack(v.Rotation))
            end
        end
    end
end

function LocalRoomBase:StackSync(_info)
    for uuid, info in pairs(_info) do
        ---@type C_StackBase
        local stack = self.arr_stacks[uuid]
        if not stack then
            goto Continue
        end
        if info.Position then
            stack:SyncPosition(table.unpack(info.Position))
        end
        if info.Rotation then
            stack:SyncRotation(info.Rotation)
        end
        ::Continue::
    end
    --print('堆叠位置和旋转同步')
end

function LocalRoomBase:StackAdd(_stack_uuid, _unit_uuid, _index)
    print('堆叠中添加对象事件', _stack_uuid, _unit_uuid, _index)
    ---@type C_StackBase
    local stack = self.arr_stacks[_stack_uuid]
    ---@type C_UnitBase
    local unit = self.arr_units[_unit_uuid]
    if not stack or not unit then
        return
    end
    stack:Add(_index, unit)
end

function LocalRoomBase:StackRemove(_player, _stack_uuid, _index)
    ---@type C_StackBase
    local stack = self.arr_stacks[_stack_uuid]
    if not stack then
        return
    end
    stack:Remove(_index)
end

function LocalRoomBase:SyncRoomInfo(_unit_info, _stack_info)
    for uuid, info in pairs(_unit_info) do
        self:UnitCreate(info.Uuid, info.Id, info.Position[1])
        local unit = self:GetUnitByUUID(uuid)
        unit.euler_target = info.Rotation[1]
        if info.HandPlayer then
            unit:InHand(info.HandPlayer)
        end
        if info.Owner and not info.Stack then
            self:UnitSelect(info.Owner, uuid)
        end
    end
    for uuid, info in pairs(_stack_info) do
        self:StackCreate(info.Uuid, info.Units, info.Owner)
        if info.Owner then
            unit:Select(info.Owner)
        end
        self:StackSelect()
    end
    for uuid, info in pairs(_unit_info) do
        local unit = self:GetUnitByUUID(uuid)
        if info.Stack then
            local stack = self:GetStackByUUID(info.Stack)
            unit:JoinStack(stack, info.Owner)
        end
    end
end

---根据UUID获取指定的对象实例
---@return C_UnitBase
function LocalRoomBase:GetUnitByUUID(_uuid)
    return self.arr_units[_uuid]
end

---获取指定UUID的堆叠
------@return C_StackBase
function LocalRoomBase:GetStackByUUID(_uuid)
    return self.arr_stacks[_uuid]
end

---获取一个对象是否在堆叠中,返回所在的堆叠
---@return C_StackBase
function LocalRoomBase:CheckInStack(_uuid)
    local c_unit = self.arr_units[_uuid]
    if c_unit then
        return c_unit.ins_stack
    else
        return
    end
end

---根据堆叠UUID获取其中的数量
function LocalRoomBase:GetStackCountByUUID(_uuid)
    local stack = self:GetStackByUUID(_uuid)
    if not stack then
        return 0
    end
    return stack:GetCount()
end

---获取当前房中游戏的玩家的座位索引,不在座位上返回nil
---@return number 该玩家的座位索引
function LocalRoomBase:GetPlayerSeat(_uid)
    for i, v in pairs(self.arr_gamingSeat) do
        if v == _uid then
            return i
        end
    end
end

---检查本地玩家是否在这个房间中
function LocalRoomBase:CheckLocalPlayerIn()
    return self.bool_lpIn
end

---更新本地的桌子
function UpdateTable(self)
    if self.local_table then
        self.local_table:Destroy()
    end
    if self.num_id ~= -1 then
        ---房间中有游戏
        self.local_table = world:CreateInstance(self.t_config.PlayerTable, '默认桌子', localPlayer.Local.Independent, self.vector3_pos)
    else
        ---房间中没有游戏,需要创建默认的桌子
        self.local_table = world:CreateInstance(Config.GlobalConfig.LocalDefaultTable, '玩家桌子', localPlayer.Local.Independent, self.vector3_pos)
    end
end

function UpdateHandZone(self)
	for i, v in ipairs(self.local_table:GetChildren()) do
		if(string.sub(v.Name, 1, 8) == 'HandZone') then
			v:Destroy()
		end
	end
	if(-1 == self.num_id) then
		print('未获得游戏编号')
		return
	end
	local config = Config.Game[self.num_id].HandCard
	local n = #config
	for i = 1, n do
		local zone = world:CreateInstance('HandZone', 'HandZone' .. i, self.local_table)
		zone.LocalPosition = config[i].Position
		zone.LocalRotation = config[i].Rotation
		zone:SetActive(true)
		if(self.arr_gamingSeat[i] ~= -1) then
			zone.SurfaceGUI.TxtName.Text = world:GetPlayerByUserId(self.arr_gamingSeat[i]).Name
		end
	end
end

---摄像机初始化
function InitCam(self)
    if self.num_id == -1 then
        GameFlow:Enter(self.local_table.Position + Config.GlobalConfig.LocalTableOffset)
    else
        GameFlow:Enter(self.local_table.Position + self.t_config.Focus)
    end
end

---摄像机恢复
function RestoreCam(self)
    GameFlow:Quit()
end

---房间中的玩家隐藏掉
function HidePlayers(self)
    for i, v in pairs(world:FindPlayers()) do
        NotReplicate(function()
            v.Avatar:SetActive(false)
        end)
    end
end

---房间中的玩家显示
function ShowPlayers(self)
    for i, v in pairs(world:FindPlayers()) do
        NotReplicate(function()
            v.Avatar:SetActive(true)
        end)
    end
end

---隐藏世界下的桌子
function HideWorldTable(self)
    if self.world_table then
        NotReplicate(function()
            self.world_table:SetActive(false)
        end)
    end
end

---显示世界下的桌子
function ShowWorldTable(self)
    if self.world_table then
        NotReplicate(function()
            self.world_table:SetActive(true)
        end)
    end
end

---本地桌游信息销毁
function DestroyUnits(self)
    if self.local_table then
        self.local_table:Destroy()
    end
    for i, v in pairs(self.arr_stacks) do
        v:Destroy()
    end
    for i, v in pairs(self.arr_units) do
        v:Destroy()
    end
    self.arr_stacks = {}
    self.arr_units = {}
end

---更新本地的平面吸附点
function UpdateAdsorb(self)
    self.arr_adsorbPos = {}
    if self.local_table.Adsorb then
        for i, v in ipairs(self.local_table.Adsorb:GetChildren()) do
            table.insert(self.arr_adsorbPos, v.Position)
        end
    end
end

function LocalRoomBase:HasHandZone()
	local id = self.num_id
	return #(Config.Game[id].HandCard) > 0
end

return LocalRoomBase