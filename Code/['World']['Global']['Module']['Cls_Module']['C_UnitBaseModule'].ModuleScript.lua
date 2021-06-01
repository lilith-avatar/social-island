--- @module C_UnitBase 客户端实体控制
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local C_UnitBase = class('C_UnitBase')

--- 初始化
function C_UnitBase:initialize(_uuid, _id, _pos, _parent, _adsorb, _gameId)
    self.obj_parent = _parent
    ---@type number 这个道具的id
    self.num_id = _id
    self.config = Config.Unit[_id]
    ---描边配置
    self.config_outline = Config.Game[_gameId] and Config.Game[_gameId].OutLine or {}
    ---射线检测起始的Y值
    self.ray_y = Config.Game[_gameId].Focus.y + _parent.Position.y + 1
    ---对象移动的范围 x上限 x下限 z上限 z下限
    self.rec_range = {
        Config.Game[_gameId].Focus.x + Config.Game[_gameId].Area[1] * 0.5,
        Config.Game[_gameId].Focus.x - Config.Game[_gameId].Area[1] * 0.5,
        Config.Game[_gameId].Focus.z + Config.Game[_gameId].Area[2] * 0.5,
        Config.Game[_gameId].Focus.z - Config.Game[_gameId].Area[2] * 0.5,
    }
    ---@type string 游戏中唯一ID,多端一致
    self.str_uuid = _uuid
    ---@type Object 实体的模型
    self.obj_model = world:CreateInstance(self.config.Archetype, self.config.Name, _parent, _pos, self.config.DefaultRot)
    if(self.config.Texture ~= '') then
		self.obj_model.Texture = ResourceManager.GetTexture(self.config.Texture)
	end
	self.obj_uuid = world:CreateObject('StringValueObject', 'UUID', self.obj_model)
    self.obj_uuid.Value = _uuid
    ---@type Object 实体选中后下方的影子
    self.obj_modelT = world:CreateInstance(self.config.TArchetype, 'T'..self.config.Name, _parent['Shadow'], _pos, _rot)
    if self.config.Texture ~= '' then
        self.obj_modelT.Texture = ResourceManager.GetTexture(self.config.Texture)
    end
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
function C_UnitBase:Update(_dt, _tt)

end

--- 更新是否在吸附范围
function C_UnitBase:UpdateRange()
    if self.player_selected == localPlayer.UserId then
        local pos = self:CheckAdsorb()
        if pos then
            ---当前在吸附范围内
            if not self.bool_inRange then
                ---进入吸附范围
                self:SetShadow(true)
                self.bool_inRange = true
            end
            self:UpdateShadow(Vector2(pos.x, pos.z))
            --print(self.obj_modelT.Position)
        else
            ---当前不在吸附范围内
            if self.bool_inRange then
                ---离开吸附范围
                self:SetShadow(false)
                self.bool_inRange = false
            end
        end
    end
end

--- FixUpdate函数
--- @param _dt number delta time 每帧时间
function C_UnitBase:FixUpdate(_dt)
    ---角度按照差值更新为目标
    self.obj_model.Rotation = self.obj_model.Rotation:Lerp(self.euler_target, _dt * 10)
    if self.bool_isSync then
        ---取队列中前两个
        local info1, info2 = self.queue_position:GetValue(1), self.queue_position:GetValue(2)
        local pos = CubicSplines(info1, info2, self.float_syncTime / info1.Time)
        self.obj_model.Position = pos
        if self.player_selected then
            self.obj_model.Position = self.obj_model.Position + GlobalData.SelectHigh * Vector3.Up
        end
        --print(pos, info1.Time)
        self.float_syncTime = self.float_syncTime + _dt
        if self.float_syncTime >= info1.Time then
            ---此帧数据同步完毕,队列移除一个
            self.float_syncTime = self.float_syncTime - info1.Time
            --print('此帧数据同步完毕,队列移除一个', self.float_syncTime)
            self.queue_position:Dequeue()
            if self.queue_position:Size() == 1 then
                ---当前队列中所有帧全部同步完毕,将物体位置设置为最后一帧的位置
                self.bool_isSync = false
                self.obj_model.Position = self.queue_position:GetValue(1).Pos2
                if self.player_selected then
                    self.obj_model.Position = self.obj_model.Position + GlobalData.SelectHigh * Vector3.Up
                end
                print('当前队列中所有帧全部同步完毕,将物体位置设置为最后一帧的位置', self.obj_model.Position)
            end
        end
    end
    UpdateModel(self)
end

---本地操作更新位置
---@param _dir Vector3 移动的方向
---@param _spd number 移动的速度
---@param _dt number 移动的时长
function C_UnitBase:UpdatePosition(_dir, _spd, _dt)
    if self.player_selected ~= localPlayer.UserId then
        return false
    end
    self.obj_model.Position = self.obj_model.Position + _dir.Normalized * _spd * _dt
    return true
end

---本地操作更新旋转,直接更改对象旋转角度
function C_UnitBase:UpdateRotation(_rot)
    if self.player_selected ~= localPlayer.UserId then
        return
    end
    self.euler_target = self.euler_target + _rot
    return true
end

---更新影子的位置
---@param _pos Vector2
function C_UnitBase:UpdateShadow(_pos)
    self.obj_modelT.Position = Vector3(_pos.x, self.obj_model.Position.y - GlobalData.SelectHigh, _pos.y)
end

---开关影子
function C_UnitBase:SetShadow(_active)
    self.obj_modelT:SetActive(_active)
end

---获取位置
function C_UnitBase:GetPosition()
    return self.obj_model.Position
end

---停止更新旋转,进行一次吸附
function C_UnitBase:StopRotate()
    if self.player_selected ~= localPlayer.UserId then
        return
    end
    local y = self.euler_target.y
    local mod = y % self.num_adsorbAngle
    if mod > self.num_adsorbAngle * 0.5 then
        self.euler_target.y = y + self.num_adsorbAngle - mod
    else
        self.euler_target.y = y - mod
    end
end

---获取目标旋转角度
function C_UnitBase:GetRotation()
    return self.euler_target
end

---获取此物体是否有玩家选中了
function C_UnitBase:GetOwner()
    return self.player_selected
end

---获取当前是否正在接受外部同步
function C_UnitBase:GetIsSync()
    return self.bool_isSync
end

---获取当前的类型
function C_UnitBase:GetType()
    return self.enum_type
end

--- 检查当前是否已经超出边界
function C_UnitBase:CheckInRange(_dir)
    local pos = _dir + self.obj_model.LocalPosition
    return pos.x < self.rec_range[1] and pos.x > self.rec_range[2] and pos.z < self.rec_range[3] and pos.z > self.rec_range[4]
end

--非本地玩家直接调用
---外部同步位置
function C_UnitBase:SyncPosition(_new, _newDir, _newSpd, _dt, _forced)
    ---不接受自己移动的同步信息
    if self.player_selected == localPlayer.UserId and not _forced then
        return
    end
    local info = {
        Pos1 = _new - _newSpd * _newDir * _dt * 0.2,
        Pos2 = _new,
        Pos3 = _new + _newSpd * _newDir * _dt * 0.2,
        Time = _dt,
    }
    self.queue_position:Enqueue(info)
    if self.queue_position:Size() > 1 then
        ---插入后队列长度大于1,开始进行渲染更新
        self.bool_isSync = true
    end
end

---外部同步旋转
function C_UnitBase:SyncRotation(_new)
    ---不接受自己旋转的同步信息
    if self.player_selected == localPlayer then
        return
    end
    self.euler_target = _new
end

---选中
function C_UnitBase:Select(_player)
    print('C_UnitBase:Select', _player, self.player_selected)
    if not self.player_selected then
        self.obj_model.Position = self.obj_model.Position + Vector3.Up * GlobalData.SelectHigh
    end
    self.player_selected = _player.UserId
    ShowOutLine(self, _player.UserId)
end

---取消选中
function C_UnitBase:CancelSelect(_playerUid, _pos)
    if self.player_selected then
        print('取消选中', self.obj_model, _pos)
        self.obj_model.Position = self.obj_model.Position - Vector3.Up * GlobalData.SelectHigh
    end
    if _pos and self.player_selected ~= localPlayer.UserId then
        _pos = Vector3(_pos.x, self.obj_model.Position.y, _pos.y)
        local dir = _pos - self.obj_model.Position
        self:SyncPosition(_pos, dir.Normalized, 0.01, 0.1, true)
        --self.obj_model.Position = Vector3(_pos.x, self.obj_model.Position.y, _pos.y)
    elseif _pos then
        self.obj_model.Position = Vector3(_pos.x, self.obj_model.Position.y, _pos.y)
    end
    self.bool_inRange = false
    self:SetShadow(false)
    self.player_selected = nil
    HideOutLine(self)
end

---对象删除
function C_UnitBase:Destroy()
    if self.obj_model and not self.obj_model:IsNull() then
        self.obj_model:Destroy()
    end
    if self.obj_modelT and not self.obj_modelT:IsNull() then
        self.obj_modelT:Destroy()
    end
    table.cleartable(self)
end

---对象进入堆叠
function C_UnitBase:JoinStack(_stack, _player)
    self.ins_stack = _stack
    if _player then
        self.player_selected = _player.UserId
    end
end

---对象进入玩家的手牌区
function C_UnitBase:InHand(_player)
    print('对象进入玩家的手牌区', _player)
    self.player_hand = _player
    if localPlayer ~= _player then
        ---需要在本地将这个对象的贴图更改为问号
        HideTexture(self)
    end
end

---对象离开玩家的手牌区
function C_UnitBase:OutHand()
    self.player_hand = nil
    ShowTexture(self)
end

---对象从堆叠移出
function C_UnitBase:OutStack()
    self.ins_stack = nil
end

---三次样条插值处理
---@return Vector3 差值后的位置
function CubicSplines(_info1, _info2, _time)
    local pos1 = _info1.Pos2
    local pos2 = _info1.Pos3
    local pos3 = _info2.Pos1
    local pos4 = _info2.Pos2
    local x0, y0, z0 = pos1.x, pos1.y, pos1.z
    local x1, y1, z1 = pos2.x, pos2.y, pos2.z
    local x2, y2, z2 = pos3.x, pos3.y, pos3.z
    local x3, y3, z3 = pos4.x, pos4.y, pos4.z
    local A = x3 - 3 * x2 + 3 * x1 - x0
    local B = 3 * x2 - 6 * x1 + 3 * x0
    local C = 3 * x1 - 3 * x0
    local D = x0
    local E = y3 - 3 * y2 + 3 * y1 - y0
    local F = 3 * y2 - 6 * y1 + 3 * y0
    local G = 3 * y1 - 3 * y0
    local H = y0
    local I = z3 - 3 * z2 + 3 * z1 - z0
    local J = 3 * z2 - 6 * z1 + 3 * z0
    local K = 3 * z1 - 3 * z0
    local L = z0
    local x = A * _time ^ 3 + B * _time ^ 2 + C * _time + D
    local y = E * _time ^ 3 + F * _time ^ 2 + G * _time + H
    local z = I * _time ^ 3 + J * _time ^ 2 + K * _time + L
    return Vector3(x, y, z)
end

---更新实体下方半透的位置,并更新对象的Y值
---@param _self C_UnitBase
function UpdateModel(_self)
    if _self.player_selected ~= localPlayer.UserId then
        return
    end
    _self.obj_modelT.Rotation = _self.obj_model.Rotation
    ---y值取射线检测到的点
    local startPos = Vector3(_self.obj_model.Position.x, _self.ray_y, _self.obj_model.Position.z)
    local hitRes = Physics:RaycastAll(startPos, _self.obj_model.Position + Vector3.Up * -100, false)
    for i, v in pairs(hitRes.HitObjectAll) do
        local uuid
        if v.UUID then
            uuid = v.UUID.Value
        end
        if v.Parent and v.Parent.UUID then
            uuid = v.Parent.UUID.Value
        end
        if uuid then
            local unit = LocalRooms:GetUnitByUUID(uuid)
            if unit and unit:GetOwner() then
                goto Continue
            end
        end
        if (v.Parent and v.Parent ~= _self.obj_parent.Shadow) then
            local index = GetIndexInStack(_self)
            index = index == 0 and 0 or index - 1
            _self.obj_model.Position = hitRes.HitPointAll[i] + Vector3.Up * (_self.num_high + index * _self.num_height)
            break
        end
        ::Continue::
    end
end

---获取此对象在堆叠中的序号(若在堆叠中)
---@param _self C_UnitBase
function GetIndexInStack(_self)
    if _self.ins_stack then
        return _self.ins_stack:GetIndex(_self)
    end
    return 0
end

---检查当前是否在一个吸附点上
function C_UnitBase:CheckAdsorb()
    if GetIndexInStack(self) ~= 0 then
        ---在堆叠中,走堆叠更新逻辑
        return
    end
    if self:GetOwner() ~= localPlayer.UserId then
        ---当前未选中或者选中的不是自己,不进行吸附的更新
        return
    end
    local dis2, index = math.huge, 0
    for i, pos in ipairs(self.arr_adsorbPos) do
        local x = self.obj_model.Position.x - pos.x
        local z = self.obj_model.Position.z - pos.z
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

---更改对象贴图为问号
---@param _self C_UnitBase
function HideTexture(_self)
    _self.obj_model.Texture = ResourceManager.GetTexture(_self.config.HideTexture)
end

---展示原本贴图
---@param _self C_UnitBase
function ShowTexture(_self)
    _self.obj_model.Texture = ResourceManager.GetTexture(_self.config.Texture)
end

---显示描边
---@param _self C_UnitBase
function ShowOutLine(_self, _uid)
    local seatIndex = LocalRooms:GetPlayerSeat(_uid)
    if not seatIndex then
        return
    end
    local config = _self.config_outline[seatIndex]
    if not config then
        return
    end
    _self.obj_model:ShowOutline(config.Color, config.Width, false)
end

---关闭描边
---@param _self C_UnitBase
function HideOutLine(_self)
    _self.obj_model:HideOutline(true)
end

return C_UnitBase