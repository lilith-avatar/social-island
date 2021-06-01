--- @module S_UnitBase 服务端实体控制
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local S_UnitBase = class('S_UnitBase')

--- 初始化
function S_UnitBase:initialize(_id, _pos, _gameId, _worldPos)
    ---在哪个玩家的手牌区
    self.handPlayer = nil
    self.m_id = _id
    self.m_gameId = _gameId
    self.config = Config.Unit[_id]
    self.m_uuid = 'Unit_' .. UUID()
    ---@type PlayerInstance 选择此实体的玩家
    self.m_owner = nil
    self.m_height = self.config.Height
    ---@type S_StackBase 当前对象所在的堆叠实例
    self.m_stack = nil
    self.m_type = self.config.Type
    ---对象移动的范围 x上限 x下限 z上限 z下限
    self.rec_range = {
        Config.Game[_gameId].Focus.x + Config.Game[_gameId].Area[1] * 0.5 + _worldPos.x,
        Config.Game[_gameId].Focus.x - Config.Game[_gameId].Area[1] * 0.5 + _worldPos.x,
        Config.Game[_gameId].Focus.z + Config.Game[_gameId].Area[2] * 0.5 + _worldPos.z,
        Config.Game[_gameId].Focus.z - Config.Game[_gameId].Area[2] * 0.5 + _worldPos.z,
    }

    self.m_rotation = self.config.DefaultRot
    self.m_position = _pos
    self.m_dir = Vector3.Zero
    self.m_spd = 0
    self.m_dt = 1 / GlobalData.SyncFrequency_S

    --上一次尝试同步时的四种数据
    self.m_pre_rotation = self.m_rotation
    self.m_pre_position = _pos
    self.m_pre_dir = Vector3.Zero
    self.m_pre_spd = 0
    self.m_pre_dt = self.m_dt
end

--- Update函数
--- @param _dt number delta time 每帧时间
function S_UnitBase:Update(_dt, _tt)
    
end

---玩家选择此物体
function S_UnitBase:Select(_player)
    if self.m_owner then
        ---此物体被其他玩家选中了,不可以被选中
        return false
    end
    self.m_owner = _player
    return true
end

---玩家取消选择
function S_UnitBase:CancelSelect(_player, _pos)
    if self.m_owner == _player then
        self.m_owner = nil
        if _pos then
            self.m_position.x = _pos.x
            self.m_position.z = _pos.y
            self.m_pre_position.x = _pos.x
            self.m_pre_position.z = _pos.y
        end
        return true
    end
    return false
end

--- 更新实体的位置
function S_UnitBase:UpdatePosition(_player, _pos, _dir, _spd, _dt)
    if not self:CheckInRange(_pos) then
        return
    end
    if self.m_owner == _player then
        self.m_position = _pos
        self.m_dir = _dir
        self.m_spd = _spd
        self.m_dt = _dt + self.m_dt
        --print('服务,更新实体的位置')
    end
end

--- 更新实体的旋转
function S_UnitBase:UpdateRotation(_player, _rot)
    if self.m_owner == _player then
        self.m_rotation = _rot
    end
end

--- 数据是否变化
---@return boolean,boolean 位置是否变化,角度是否变化
function S_UnitBase:IsChanged()
    local res1, res2 = false, false
    if self.m_spd ~= self.m_pre_spd or self.m_position ~= self.m_pre_position or self.m_dir ~= self.m_pre_dir then
        res1 = true
    end
    if self.m_rotation ~= self.m_pre_rotation then
        res2 = true
    end
    return res1, res2
end

---进入玩家的手牌区
function S_UnitBase:InHand(_player)
    if self:GetStack() then
        return false
    end
    if not self.config.InHand then
        return false
    end
    self.handPlayer = _player
    return true
end

---离开玩家的手牌区
function S_UnitBase:OutHand()
    if self.handPlayer then
        self.handPlayer = nil
        return true
    end
    return false
end

---进入堆叠
function S_UnitBase:JoinStack(_stack)
    self:OutHand()
    self.m_stack = _stack
    self.m_owner = _stack:GetOwner()
end

---从堆叠中离开
function S_UnitBase:OutStack()
    local stack = self.m_stack
    self.m_stack = nil
    return stack
end

--- 外部同步一次位置
function S_UnitBase:TrySyncPos()
    self.m_pre_position = self.m_position
    self.m_pre_dir = self.m_dir
    self.m_pre_spd = self.m_spd
    self.m_pre_dt = self.m_dt
    self.m_dt = 0
end

--- 外部同步一次角度
function S_UnitBase:TrySyncRot()
    self.m_pre_rotation = self.m_rotation
end

--- 获取当前最新的位置数据
function S_UnitBase:GetLatestPosData()
    return { self.m_position, self.m_dir, self.m_spd, self.m_dt }
end

--- 获取当前最新的角度数据
function S_UnitBase:GetLatestRotData()
    return { self.m_rotation }
end

--- 获取当前物体选中的玩家
function S_UnitBase:GetOwner()
    return self.m_owner
end

--- 获取当前所归属的堆叠
function S_UnitBase:GetStack()
    return self.m_stack
end

--- 获取类型
function S_UnitBase:GetType()
    return self.m_type
end

--- 获取在哪个玩家手牌区
function S_UnitBase:GetHandPlayer()
    return self.handPlayer
end

--- 返回是否在一个玩家的手牌区中
function S_UnitBase:CheckInHandArea()
    
end

--- 获取是否在操作区域内
function S_UnitBase:CheckInRange(_pos)
    return _pos.x < self.rec_range[1] and _pos.x > self.rec_range[2] and _pos.z < self.rec_range[3] and _pos.z > self.rec_range[4]
end

--- 销毁
function S_UnitBase:Destroy()
    table.cleartable(self)
end

return S_UnitBase