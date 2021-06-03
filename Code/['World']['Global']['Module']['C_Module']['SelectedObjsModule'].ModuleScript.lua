--- @module SelectedObjs 客户端选中的物体的控制,单例
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local SelectedObjs = ModuleUtil.New('SelectedObjs', ClientBase)
local self = SelectedObjs

--- 初始化
function SelectedObjs:Init()
    ---选中的对象,不包含选中容器中的对象
    self.arr_selectedUnits = {}
    ---选中的容器
    self.arr_selectedStacks = {}
    ---每几个渲染帧同步一次
    self.num_timeLeft = GlobalData.SyncFrequency_C
    ---当前选中对象此帧移动的信息
    self.t_moveInfo = {}
    ---当前同步的方向
    self.vec_dir = Vector3.Zero
    self.num_time = 0
end

--- Update函数
--- @param _dt number delta time 每帧时间
function SelectedObjs:Update(_dt, _tt)
    
end

--- FixUpdate函数
--- @param _dt number delta time 每帧时间
function SelectedObjs:FixUpdate(_dt)

end

---选择对象
---@param _isAll boolean 若选择的为容器,是否全选容器,否则只选择容器上面的一个元素
function SelectedObjs:Select(_uuid, _isAll)
    local room = LocalRooms:GetLPRoom()
    if not room then
        return
    end
    ---@type C_StackBase
    local c_stack = LocalRooms:CheckInStack(_uuid)
    if c_stack then
        NetUtil.Fire_S('TrySelectStackEvent', room.str_uuid, localPlayer, c_stack.str_uuid, _isAll)
    else
        NetUtil.Fire_S('TrySelectUnitEvent', room.str_uuid, localPlayer, _uuid)
    end
end

---取消选择
---@param _uuid string 取消选择的对象UUID,若此对象在容器中则取消选择该容器,为空则为取消选择全部
function SelectedObjs:CancelSelect(_uuid)
    local room = LocalRooms:GetLPRoom()
    if not room then
        return
    end
    local targetPos = TryAdsorbPos()
    --wait()
    if not _uuid then
        ---取消选择所有
        for i, v in pairs(self.arr_selectedUnits) do
            NetUtil.Fire_S('TryCancelElementEvent', room.str_uuid, localPlayer, i, targetPos)
        end
        for i, v in pairs(self.arr_selectedStacks) do
            NetUtil.Fire_S('TryCancelStackEvent', room.str_uuid, localPlayer, i, targetPos)
        end
    else
        ---@type C_StackBase
        local c_stack = LocalRooms:CheckInStack(_uuid)
        if c_stack then
            ---取消选择这个容器
            NetUtil.Fire_S('TryCancelStackEvent', room.str_uuid, localPlayer, c_stack.str_uuid, targetPos)
        else
            ---取消选择这个对象
            NetUtil.Fire_S('TryCancelElementEvent', room.str_uuid, localPlayer, _uuid, targetPos)
        end
    end
end

---拖动选中物体
---@param _dir Vector3 移动的方向,长度表示此次移动的距离
function SelectedObjs:Move(_dir, _dt)
    local room = LocalRooms:GetLPRoom()
    if not room then
        return
    end
    if self:GetIsSync() then
        ---当前还有对象没有同步完成,不允许自己改变位置
        return
    end
    ---当前选中的对象是否有已经在边界外的
    for i, v in pairs(self.arr_selectedUnits) do
        if not v:CheckInRange(_dir * _dt) then
            return
        end
    end
    for i, v in pairs(self.arr_selectedStacks) do
        if not v:CheckInRange(_dir * _dt) then
            return
        end
    end
    self.num_timeLeft = self.num_timeLeft - 1
    self.vec_dir = self.vec_dir + _dir
    self.num_time = self.num_time + _dt
    local moveInfo1, sync1 = {}, false
    for i, v in pairs(self.arr_selectedUnits) do
        local fix = Vector3.Zero
        if v:GetOwner() then
            fix.y = -GlobalData.SelectHigh
        end
        v:UpdatePosition(_dir.Normalized, _dir.Magnitude, _dt)
        sync1 = true
    end
    if sync1 and self.num_timeLeft == 0 then
        for i, v in pairs(self.arr_selectedUnits) do
            local fix = Vector3.Zero
            if v:GetOwner() then
                fix.y = -GlobalData.SelectHigh
            end
            moveInfo1[i] = { v:GetPosition() + fix, self.vec_dir.Normalized, self.vec_dir.Magnitude, self.num_time }
        end
        NetUtil.Fire_S('TryMoveElementEvent', room.str_uuid, localPlayer, moveInfo1)
    end

    local moveInfo2, sync2 = {}, false
    for i, v in pairs(self.arr_selectedStacks) do
        local fix = Vector3.Zero
        if v:GetOwner() then
            fix.y = -GlobalData.SelectHigh
        end
        v:UpdatePosition(_dir.Normalized, _dir.Magnitude, _dt)
        moveInfo2[i] = { v:GetPosition() + fix, _dir.Normalized, _dir.Magnitude, _dt }
        sync2 = true
    end
    if sync2 then
        NetUtil.Fire_S('TryMoveStackEvent', room.str_uuid, localPlayer, moveInfo2)
    end
    self.t_moveInfo.Unit = sync1 and moveInfo1 or nil
    self.t_moveInfo.Stack = sync2 and moveInfo2 or nil

    if self.num_timeLeft == 0 then
        self.num_timeLeft = GlobalData.SyncFrequency_C
        self.vec_dir = Vector3.Zero
        self.num_time = 0
    end
end

---物体停止拖动,上行一次最新数据
function SelectedObjs:StopMove()
    local room = LocalRooms:GetLPRoom()
    if not room then
        return
    end
    if self.t_moveInfo.Unit then
        NetUtil.Fire_S('TryMoveElementEvent', room.str_uuid, localPlayer, self.t_moveInfo.Unit)
    end
    if self.t_moveInfo.Stack then
        NetUtil.Fire_S('TryMoveStackEvent', room.str_uuid, localPlayer, self.t_moveInfo.Stack)
    end
end

---Y轴旋转停止,需要做修正
function SelectedObjs:StopRotate_Y()
    local room = LocalRooms:GetLPRoom()
    if not room then
        return
    end
    local rotateInfo = {}
    for i, v in pairs(self.arr_selectedUnits) do
        v:StopRotate()
        rotateInfo[i] = v:GetRotation()
    end
    for i, v in pairs(self.arr_selectedStacks) do
        v:StopRotate()
        for uuid, rot in pairs(v:GetRotation()) do
            rotateInfo[uuid] = rot
        end
    end
    NetUtil.Fire_S('TryRotateElementEvent', room.str_uuid, localPlayer, rotateInfo)
end

---Y轴旋转
function SelectedObjs:Rotate_Y(_spd)
    local room = LocalRooms:GetLPRoom()
    if not room then
        return
    end
    for i, v in pairs(self.arr_selectedUnits) do
        v:UpdateRotation(EulerDegree(0, _spd, 0))
    end
    for i, v in pairs(self.arr_selectedStacks) do
        v:UpdateRotation(EulerDegree(0, _spd, 0))
    end
end

---翻转一次,暂时做成正反面翻转,执行完成后立即同步角度
function SelectedObjs:Flip()
    local room = LocalRooms:GetLPRoom()
    if not room then
        return
    end
    for i, v in pairs(self.arr_selectedUnits) do
        v:UpdateRotation(EulerDegree(180, 0, 0))
    end
    for i, v in pairs(self.arr_selectedStacks) do
        v:UpdateRotation(EulerDegree(180, 0, 0))
    end
    self:StopRotate_Y()
end

---序列翻转
function SelectedObjs:Reverse()

end

---尝试堆叠
---@param _type number 尝试堆叠的类型,不填则尝试堆叠选中的所有
function SelectedObjs:Stack(_type)
    LocalRooms:TryCreateStack(_type)
end

---吸附,传入尝试吸附的一个物体UUID   SelectedObjs:Adsorb('Unit_37a6aa63-3931-4a31-ca18-155769a24235')
function SelectedObjs:Adsorb(_uuid)
    local room = LocalRooms:GetLPRoom()
    if not room then
        return
    end
    local unit = LocalRooms:GetUnitByUUID(_uuid)
    if not unit then
        return
    end
    NetUtil.Fire_S('TryAdsorbEvent', room.str_uuid, localPlayer, _uuid)
end

---展开操作
function SelectedObjs:Unfold()

end

---切牌
function SelectedObjs:Cut()

end

---发牌
function SelectedObjs:Deal()

end

---元素被删除,需要先取消选中
function SelectedObjs:Destroy(_uuid)
    self.arr_selectedUnits[_uuid] = nil
end

---获取一个对象是否被自己选中
function SelectedObjs:GetSelectOrNot(_uuid)
    if self.arr_selectedUnits[_uuid] then
        return true
    end
    local unit = LocalRooms:GetUnitByUUID(_uuid)
    if unit and unit.ins_stack and self.arr_selectedStacks[unit.ins_stack.str_uuid] then
        return true
    end
    return false
end

---获取当前是否有选中的物体
function SelectedObjs:HadSelectUnits()
    if table.nums(self.arr_selectedUnits) == 0 and table.nums(self.arr_selectedStacks) == 0 then
        return false
    end
    return true
end

---对象选中事件
function SelectedObjs:ElementSelectEventHandler(_room_uuid, _player, _uuid)
    if not LocalRooms:GetLPRoom() or LocalRooms:GetLPRoom().str_uuid ~= _room_uuid then
        return
    end
    ---@type C_UnitBase
    local obj = LocalRooms:GetUnitByUUID(_uuid)
    if obj and _player == localPlayer and obj:GetType() ~= Const.ElementsTypeEnum.UnlimitedStack then
        self.arr_selectedUnits[_uuid] = obj
    end
end

---对象取消选中事件
function SelectedObjs:ElementCancelEventHandler(_room_uuid,_playerUid, _uuid)
    if not LocalRooms:GetLPRoom() or LocalRooms:GetLPRoom().str_uuid ~= _room_uuid then
        return
    end
    if _playerUid == localPlayer.UserId then
        self.arr_selectedUnits[_uuid] = nil
    end
end

---堆叠选中事件
function SelectedObjs:StackSelectEventHandler(_room_uuid,_player, _uuid)
    if not LocalRooms:GetLPRoom() or LocalRooms:GetLPRoom().str_uuid ~= _room_uuid then
        return
    end
    print('堆叠选中事件')
    local stack = LocalRooms:GetStackByUUID(_uuid)
    if stack and _player == localPlayer then
        self.arr_selectedStacks[_uuid] = stack
    end
end

---堆叠取消选中事件
function SelectedObjs:StackCancelEventHandler(_room_uuid,_player, _uuid)
    if not LocalRooms:GetLPRoom() or LocalRooms:GetLPRoom().str_uuid ~= _room_uuid then
        return
    end
    if _player == localPlayer then
        self.arr_selectedStacks[_uuid] = nil
    end
end

function SelectedObjs:StackCreateEventHandler(_room_uuid,_uuid, _units, _player)
    if not LocalRooms:GetLPRoom() or LocalRooms:GetLPRoom().str_uuid ~= _room_uuid then
        return
    end
    for i, v in pairs(_units) do
        self.arr_selectedUnits[v] = nil
    end
end

---获取当前选中的对象是否还有正在接受同步的
function SelectedObjs:GetIsSync()
    for i, v in pairs(self.arr_selectedStacks) do
        if v:GetIsSync() then
            return true
        end
    end
    for i, v in pairs(self.arr_selectedUnits) do
        if v:GetIsSync() then
            return true
        end
    end
    return false
end

---获取当期选中的对象数量和堆叠数量
function SelectedObjs:GetSelectNum()
    return table.nums(self.arr_selectedUnits), table.nums(self.arr_selectedStacks)
end

---取消选择后尝试进行吸附的操作
function TryAdsorbPos()
    local unit_num, stack_num = self:GetSelectNum()
    if unit_num == 1 and stack_num == 0 then
        ---只有一个选中的对象,发送事件前将对象移动到指定的x,z位置
        for i, v in pairs(self.arr_selectedUnits) do
            local pos = v:CheckAdsorb()
            if pos then
                print('对象吸附到平面指定位置', pos)
                return Vector2(pos.x, pos.z)
            end
            break
        end
    elseif unit_num == 0 and stack_num == 1 then
        ---只有一个选中的堆叠
        for i, v in pairs(self.arr_selectedStacks) do
            local pos = v:CheckAdsorb()
            if pos then
                print('堆叠吸附到平面指定位置', pos)
                return Vector2(pos.x, pos.z)
            end
            break
        end
    end
end

return SelectedObjs