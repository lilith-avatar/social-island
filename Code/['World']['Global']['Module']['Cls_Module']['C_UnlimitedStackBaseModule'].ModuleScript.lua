--- @module C_UnlimitedStackBase:C_UnitBase 客户端无限堆叠实体控制
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local C_UnlimitedStackBase = class('C_UnlimitedStackBase', C_UnitBase)

--- 初始化
function C_UnlimitedStackBase:initialize(_uuid, _id, _pos, _parent, _adsorb, _gameId)
    self.obj_parent = _parent
    ---@type number 这个道具的id
    self.num_id = _id
    self.config = Config.Unit[_id]
    ---描边配置
    self.config_outline = Config.Game[_gameId] and Config.Game[_gameId].OutLine or {}
    ---@type string 游戏中唯一ID,多端一致
    self.str_uuid = _uuid
    ---@type Object 实体的模型
    self.obj_model = world:CreateInstance(self.config.Archetype, self.config.Name, _parent, _pos, self.config.DefaultRot)
    if(self.config.Texture ~= '') then
        self.obj_model.Texture = ResourceManager.GetTexture(self.config.Texture)
    end
    self.obj_uuid = world:CreateObject('StringValueObject', 'UUID', self.obj_model)
    self.obj_uuid.Value = _uuid
    --[[---@type Object 实体选中后下方的影子
    self.obj_modelT = world:CreateInstance(self.config.TArchetype, 'T'..self.config.Name, _parent['Shadow'], _pos, _rot)
    if self.config.Texture ~= '' then
        self.obj_modelT.Texture = ResourceManager.GetTexture(self.config.Texture)
    end--]]
    self:SetShadow(false)
    ---这个东西选中的玩家
    self.player_selected = nil
    ---目标角度
    self.euler_target = self.config.DefaultRot
    ---@type Queue 目标移动的数据队列,需要超过两个数据才可进行差值
    self.queue_position = Queue:New()
    ---@type boolean 物体是否开始进行同步更新
    self.bool_isSync = false
    ---@type number 位置同步的当前帧时间,每次渲染后自增渲染时间
    self.float_syncTime = 0
    self.num_adsorbAngle = GlobalData.AdsorbAngle
    self.num_high = GlobalData.SelectHigh
    ---@type C_StackBase 此对象所在的堆叠,没有则为空
    self.ins_stack = nil
    ---元素类型,暂时默认为扑克
    self.enum_type = self.config.Type
    ---对象的高度
    self.num_height = self.config.Height
    ---对象在哪个玩家的手牌区
    self.player_hand = nil

    ---对象的吸附点
    self.arr_adsorbPos = _adsorb
    ---吸附距离
    self.num_adsorbDis = 0.2
    ---选中对象当前是否在吸附范围内
    self.bool_inRange = false
end

--- Update函数
--- @param _dt number delta time 每帧时间
function C_UnlimitedStackBase:Update(_dt, _tt)

end

--- 更新是否在吸附范围
function C_UnlimitedStackBase:UpdateRange()

end

--- FixUpdate函数
--- @param _dt number delta time 每帧时间
function C_UnlimitedStackBase:FixUpdate(_dt)

end

---本地操作更新位置
---@param _dir Vector3 移动的方向
---@param _spd number 移动的速度
---@param _dt number 移动的时长
function C_UnlimitedStackBase:UpdatePosition(_dir, _spd, _dt)

end

---本地操作更新旋转,直接更改对象旋转角度
function C_UnlimitedStackBase:UpdateRotation(_rot)

end

---更新影子的位置
---@param _pos Vector2
function C_UnlimitedStackBase:UpdateShadow(_pos)

end

---开关影子
function C_UnlimitedStackBase:SetShadow(_active)

end

---获取位置
function C_UnlimitedStackBase:GetPosition()
    return self.obj_model.Position
end

---停止更新旋转,进行一次吸附
function C_UnlimitedStackBase:StopRotate()

end

---获取目标旋转角度
function C_UnlimitedStackBase:GetRotation()
    return self.euler_target
end

---获取此物体是否有玩家选中了
function C_UnlimitedStackBase:GetOwner()
    return self.player_selected
end

---获取当前是否正在接受外部同步
function C_UnlimitedStackBase:GetIsSync()
    return self.bool_isSync
end

---获取当前的类型
function C_UnlimitedStackBase:GetType()
    return self.enum_type
end

--非本地玩家直接调用
---外部同步位置
function C_UnlimitedStackBase:SyncPosition(_new, _newDir, _newSpd, _dt, _forced)

end

---外部同步旋转
function C_UnlimitedStackBase:SyncRotation(_new)

end

---选中
function C_UnlimitedStackBase:Select(_player)

end

---取消选中
function C_UnlimitedStackBase:CancelSelect(_player, _pos)

end

---对象进入堆叠
function C_UnlimitedStackBase:JoinStack(_stack, _player)

end

function C_UnlimitedStackBase:InHand(_player)

end

function C_UnlimitedStackBase:OutHand()

end

---对象从堆叠移出
function C_UnlimitedStackBase:OutStack()
    self.ins_stack = nil
end

return C_UnlimitedStackBase