--- @module S_StackBase 服务端堆叠控制类
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local S_StackBase = class('S_StackBase')

--- 初始化
--- @param _units table 形成堆叠的所有物体
function S_StackBase:initialize(_units)
    self.str_uuid = 'Stack_' .. UUID()
    self.arr_units = _units
    self.player_owner = nil
    self.enum_type = _units[1]:GetType()
    --UpdateByOrder(self, _player)
    for i, v in pairs(_units) do
        v:JoinStack(self)
    end
end

--- Update函数
--- @param _dt number delta time 每帧时间
function S_StackBase:Update(_dt, _tt)

end

---插入
---@param _unit S_UnitBase
function S_StackBase:Add(_index, _unit)
    _unit:JoinStack(self)
    table.insert(self.arr_units, _index, _unit)
end

---移出
---@return S_StackBase
function S_StackBase:Remove(_index)
    ---@type S_UnitBase
    local unit = table.remove(self.arr_units, _index)
    unit:OutStack()
    return unit
end

---获取其中全部对象
function S_StackBase:GetUnits()
    return self.arr_units
end

---获取其中全部对象的UUID
function S_StackBase:GetUnitsUUID()
    local res = {}
    for i, v in pairs(self.arr_units) do
        table.insert(res, v.m_uuid)
    end
    return res
end

---玩家选中这个堆叠
function S_StackBase:Select(_player)
    if self.player_owner then
        return false
    end
    self.player_owner = _player
    for i, v in pairs(self.arr_units) do
        v:Select(_player)
    end
    return true
end

---玩家取消选中
function S_StackBase:CancelSelect(_player, _pos)
    if self.player_owner == _player then
        self.player_owner = nil
        for i, v in pairs(self.arr_units) do
            v:CancelSelect(_player, _pos)
        end
        return true
    end
    return false
end

---位置更新,接受牌叠最下面对象的位置,计算所有位置并全部更新
function S_StackBase:UpdatePosition(_player, _pos, _dir, _spd, _dt)
    local pos, y = _pos, 0
    for i, v in ipairs(self.arr_units) do
        if i ~= 1 then
            pos = pos + Vector3.Up * y
        end
        v:UpdatePosition(_player, pos, _dir, _spd, _dt)
        y = y + v.m_height
    end
end

---角度更新
function S_StackBase:UpdateRotation(...)
    for i, v in pairs(self.arr_units) do
        v:UpdateRotation(...)
    end
end

function S_StackBase:IsChanged()
    return self.arr_units[1]:IsChanged()
end

---获取堆叠的最新位置
---@return Vector3
function S_StackBase:GetLatestPosData()
    return self.arr_units[1]:GetLatestPosData()
end

---获取堆叠中所有元素最新的角度
---@return table key-uuid value-角度
function S_StackBase:GetLatestRotData()
    local res = {}
    for i, v in pairs(self.arr_units) do
        res[i] = v:GetLatestRotData()
    end
    return res
end

---获取选中的玩家
function S_StackBase:GetOwner()
    return self.player_owner
end

function S_StackBase:GetType()
    return self.enum_type
end

---获取元素数量
function S_StackBase:GetCount()
    return #self.arr_units
end

function S_StackBase:TrySyncPos()
    for i, v in pairs(self.arr_units) do
        v:TrySyncPos()
    end
end

function S_StackBase:TrySyncRot()
    for i, v in pairs(self.arr_units) do
        v:TrySyncRot()
    end
end

---销毁
function S_StackBase:Destroy()
    for i, v in pairs(self.arr_units) do
        v:OutStack()
    end
    table.cleartable(self)
end

---按照顺序更新一次堆叠中所有元素的位置,在创建,插入和移出对象时候调用一次
---@param _self S_StackBase
function UpdateByOrder(_self, _player)
    local unit1Pos = _self.arr_units[1].m_position
    local y = 0
    for i, v in ipairs(_self.arr_units) do
        if i ~= 1 then
            local pos = unit1Pos + Vector3.Up * y
            local dir = pos - v.m_position
            v:UpdatePosition(_player, pos, dir.Normalized, 0.1, 0.1)
        end
        y = y + v.m_height
    end
end

return S_StackBase