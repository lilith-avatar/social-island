--- @module C_StackBase 客户端堆叠控制类
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local C_StackBase = class('C_StackBase')

--- 初始化
function C_StackBase:initialize(_uuid, _units, _player, _parent, _adsorb)
    self.str_uuid = _uuid
    self.arr_units = _units
    self.obj_parent = _parent
    ---这个东西选中的玩家
    self.player_selected = _player
    ---此堆叠中对象的类型
    self.enum_type = self.arr_units[1].enum_type
    print('堆叠创建成功')
    for i, v in pairs(_units) do
        v:JoinStack(self)
        --v:Select(_player)
    end
    UpdateByOrder(self)
    self.obj_modelT = {}
    for i, v in pairs(_units) do
        self.obj_modelT[i] = v.obj_modelT:Clone(_parent['Shadow'])
        self.obj_modelT[i]:SetActive(false)
    end
    ---对象的吸附点
    self.arr_adsorbPos = _adsorb
    ---吸附距离
    self.num_adsorbDis = 0.2
    ---选中对象当前是否在吸附范围内
    self.bool_inRange = false
end

--- Update函数
--- @param _dt number delta time 每帧时间
function C_StackBase:Update(_dt, _tt)

end

function C_StackBase:UpdateRange()
    if self.player_selected == localPlayer then
        local pos = self:CheckAdsorb()
        if pos then
            ---当前在吸附范围内
            if not self.bool_inRange then
                ---进入吸附范围
                for i, v in pairs(self.obj_modelT) do
                    v:SetActive(true)
                end
                self.bool_inRange = true
            end
            for i, v in pairs(self.obj_modelT) do
                v.Position = Vector3(pos.x, self.arr_units[i].obj_model.Position.y - GlobalData.SelectHigh, pos.z)
                --v:UpdateShadow(Vector2(pos.x, pos.z))
            end
            --print(self.obj_modelT.Position)
        else
            ---当前不在吸附范围内
            if self.bool_inRange then
                ---离开吸附范围
                --self.obj_modelT:SetActive(false)
                for i, v in pairs(self.obj_modelT) do
                    v:SetActive(false)
                end
                self.bool_inRange = false
            end
        end
    end
end

--- FixUpdate函数
--- @param _dt number delta time 每帧时间
function C_StackBase:FixUpdate(_dt)

end

--- 堆叠被选中
function C_StackBase:Select(...)
    for i, v in pairs(self.arr_units) do
        v:Select(...)
    end
end

--- 堆叠取消选中
function C_StackBase:CancelSelect(...)
    for i, v in pairs(self.arr_units) do
        v:CancelSelect(...)
    end
    self.bool_inRange = false
    for i, v in pairs(self.obj_modelT) do
        v:SetActive(false)
    end
end

---插入
---@param _unit C_UnitBase
function C_StackBase:Add(_index, _unit)
    _unit:JoinStack(self, self.player_selected)
    if _index == 1 then
        local pos = self.arr_units[1].obj_model.Position
        if self:GetOwner() then
            pos = pos - Vector3.Up * GlobalData.SelectHigh
        end
        print(pos, self.arr_units[1].obj_model)
        ---@type Vector3
        local dir = pos - _unit.obj_model.Position
        table.insert(self.arr_units, 1, _unit)
        UpdateByOrder(self, pos)
        _unit:SyncPosition(_unit.obj_model.Position, dir.Normalized, 0.01, 0.1, true)
        _unit:SyncPosition(pos, dir.Normalized, 0.01, 0.1, true)
        _unit:SyncPosition(pos, dir.Normalized, 0.01, 0.1, true)
    else
        table.insert(self.arr_units, _index, _unit)
        UpdateByOrder(self)
    end
    local obj = _unit.obj_modelT:Clone(self.obj_parent['Shadow'])
    table.insert(self.obj_modelT, obj)
    obj:SetActive(false)
end

---移出
---@return C_StackBase
function C_StackBase:Remove(_index)
    print('堆叠移除', _index)
    ---@type S_UnitBase
    local unit = table.remove(self.arr_units, _index)
    unit:OutStack()
    local obj = table.remove(self.obj_modelT, _index)
    obj:Destroy()
    if _index ~= self:GetCount() + 1 then
        UpdateByOrder(self)
    end
    return unit
end

--- 获取此堆叠选中的玩家
function C_StackBase:GetOwner()
    return self.player_selected
end

---获取当前的类型
function C_StackBase:GetType()
    return self.enum_type
end

---获取元素数量
function C_StackBase:GetCount()
    return #self.arr_units
end

function C_StackBase:CheckInRange(_dir)
    return self.arr_units[1]:CheckInRange(_dir)
end

--- 更新堆叠中所有对象的位置
function C_StackBase:UpdatePosition(...)
    for i, v in pairs(self.arr_units) do
        v:UpdatePosition(...)
    end
end

--- 更新堆叠中所有对象的旋转
function C_StackBase:UpdateRotation(...)
    for i, v in pairs(self.arr_units) do
        v:UpdateRotation(...)
    end
end

--- 服务端同步位置
function C_StackBase:SyncPosition(_new, _newDir, _newSpd, _dt, _forced)
    print('服务端同步duidie位置', _new, _newDir, _newSpd, _dt, _forced)
    local pos = _new
    for i, v in pairs(self.arr_units) do
        v:SyncPosition(pos, _newDir, _newSpd, _dt, _forced)
        pos = pos + v.num_height * Vector3.Up
    end
end

--- 服务端同步角度
function C_StackBase:SyncRotation(_info)
    for index, rot in pairs(_info) do
        if self.arr_units[index] then
            self.arr_units[index]:SyncRotation(rot)
        end
    end
end

--- 获取堆叠位置(最下面一个对象的位置)
function C_StackBase:GetPosition()
    return self.arr_units[1]:GetPosition()
end

--- 获取堆叠旋转
function C_StackBase:GetRotation()
    local res = {}
    for i, v in pairs(self.arr_units) do
        res[i] = v:GetRotation()
    end
    return res
end

--- 旋转停止
function C_StackBase:StopRotate()
    for i, v in pairs(self.arr_units) do
        v:StopRotate()
    end
end

--- 堆叠销毁
function C_StackBase:Destroy()
    for i, v in pairs(self.arr_units) do
        v:OutStack()
    end
    for i, v in pairs(self.obj_modelT) do
        if not v:IsNull() then
            v:Destroy()
        end
    end
    table.cleartable(self)
end

--- 获取一个对象在堆叠中的序号
function C_StackBase:GetIndex(_unit)
    return table.indexof(self.arr_units, _unit)
end

---获取当前是否正在接受外部同步
function C_StackBase:GetIsSync()
    for i, v in pairs(self.arr_units) do
        if v:GetIsSync() then
            return true
        end
    end
    return false
end

---检查当前是否在一个吸附点上
function C_StackBase:CheckAdsorb()
    if self:GetOwner() ~= localPlayer then
        ---当前未选中或者选中的不是自己,不进行吸附的更新
        return
    end
    local posS = self.arr_units[1].obj_model.Position
    local dis2, index = math.huge, 0
    for i, pos in ipairs(self.arr_adsorbPos) do
        local x = posS.x - pos.x
        local z = posS.z - pos.z
        local dis = x * x + z * z
        if dis <= self.num_adsorbDis ^ 2 then
            ---在吸附范围内
            if dis < dis2 then
                index = i
                dis2 = dis
            end
        end
    end
    if index ~= 0 then
        ---当前在一个位置的吸附范围内,返回吸附的位置
        return self.arr_adsorbPos[index]
    end
end

---按照顺序更新一次堆叠中所有元素的位置,在创建,插入和移出对象时候调用一次
---@param _self S_StackBase
function UpdateByOrder(_self, _pos)
    local unit1Pos = _pos or _self.arr_units[1].obj_model.Position
    local y = 0
    for i, v in ipairs(_self.arr_units) do
        if i ~= 1 then
            local pos = unit1Pos + Vector3.Up * y
            --print(pos)
            ---@type Vector3
            local dir = pos - v.obj_model.Position
            v:SyncPosition(v.obj_model.Position, dir.Normalized, 0.01, 0.1, true)
            v:SyncPosition(pos, dir.Normalized, 0.01, 0.1, true)
            v:SyncPosition(pos, dir.Normalized, 0.01, 0.1, true)
            --v:UpdatePosition(dir.Normalized, dir.Magnitude * 5, 0.2)
        end
        y = y + v.num_height
    end
end

return C_StackBase