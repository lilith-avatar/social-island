--- @module S_UnlimitedStackBase:S_UnitBase 服务端无限堆叠控制
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local S_UnlimitedStackBase = class('S_UnlimitedStackBase', S_UnitBase)

--- Update函数
--- @param _dt number delta time 每帧时间
function S_UnlimitedStackBase:Update(_dt, _tt)
    
end

---玩家选择此物体,世界下生成指定ID的对象,并通知此玩家选中
---@param _room GameRoomBase 哪个房间中的对象选中的
function S_UnlimitedStackBase:Select(_player, _room)
    local uuid = _room:TryCreateElement(self.config.StackUnit, self.m_position + Vector3.Up * self.m_height)
    _room:TrySelect(_player, uuid)
    return true
end

---玩家取消选择
function S_UnlimitedStackBase:CancelSelect(_player, _pos)

end

--- 更新实体的位置
function S_UnlimitedStackBase:UpdatePosition(_player, _pos, _dir, _spd, _dt)

end

--- 更新实体的旋转
function S_UnlimitedStackBase:UpdateRotation(_player, _rot)

end

--- 数据是否变化
---@return boolean,boolean 位置是否变化,角度是否变化
function S_UnlimitedStackBase:IsChanged()
    return false, false
end

---进入堆叠
function S_UnlimitedStackBase:JoinStack(_stack)

end

---从堆叠中离开
function S_UnlimitedStackBase:OutStack()

end

--- 外部同步一次位置
function S_UnlimitedStackBase:TrySyncPos()

end

--- 外部同步一次角度
function S_UnlimitedStackBase:TrySyncRot()

end

--- 获取当前物体选中的玩家
function S_UnlimitedStackBase:GetOwner()
    return self.m_owner
end

--- 获取当前所归属的堆叠
function S_UnlimitedStackBase:GetStack()
    return self.m_stack
end

--- 获取类型
function S_UnlimitedStackBase:GetType()
    return self.m_type
end

--- 销毁
function S_UnlimitedStackBase:Destroy()
    table.cleartable(self)
end

return S_UnlimitedStackBase