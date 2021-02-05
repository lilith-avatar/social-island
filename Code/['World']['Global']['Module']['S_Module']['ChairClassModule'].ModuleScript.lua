---@module ChairClass
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local ChairClass = class("ChairClass")
local Config = Config

-- 状态枚举
local StateEnum = {
    free = 1,
    used = 2,
    flying = 3,
    qteing = 4,
    returning = 5
}

-- 类型枚举
local TypeEnum = {
    Normal = 1,
    QTE = 2
}

-- 特殊动作枚举
local SpecialMovement = {}

---方向函数

---椅子的构造函数
---@param _type string
---@param _pos Vector3
--- @param _rot EulerDegree
function ChairClass:initialize(_type, _id, _arch, _parent, _pos, _rot)
    if not _id then
        return
    end
    self.type = TypeEnum[_type]
    self:CommonDataInit(_arch, _parent, _pos, _rot, _id)
end

function ChairClass:CommonDataInit(_arch, _parent, _pos, _rot, _id)
    self.model = world:CreateInstance(_arch, _arch, _parent, _pos, _rot)
    self.state = StateEnum.free
    self.sitter = nil
    self.startUpdate = false
    self.freshcoo = _pos
    self.freshRot = _rot
    self.qteDir = nil
    self.timer = 0
    self.id = _id
end

function ChairClass:Sit(_player)
    if self.sitter or self.state ~= StateEnum.free then
        return
    end
    self.sitter = _player
    self.state = StateEnum.used
    self.startUpdate = true
    self.model.Seat:SetActive(true)
    self.model.CollisionArea:SetActive(false)
    --判断是否开始QTE
    if self.type == TypeEnum.QTE then
        self:Fly()
        self.state = StateEnum.flying
    end
end

function ChairClass:Stand()
    self.sitter = nil
    self.state = StateEnum.free
    self.model.Seat:SetActive(false)
    self.model.CollisionArea:SetActive(true)
    self.qteDir = nil
    --判断是否结束QTE
    if self.type == TypeEnum.QTE then
        self.model:Rotate(EulerDegree(-30, 0, 0))
        self.state = StateEnum.returning
        self:Return()
    end
end

--********************* qte摇摇椅 *************************
function ChairClass:Fly()
    --喷射
    self.tweener = Tween:ShakeProperty(self.model, {"Rotation"}, Config.ChairGlobalConfig.FlyingTime.Value, 0.5)
    self.tweener:Play()
end

function ChairClass:Flying(dt)
    -- 一段时间后停下
    self.timer = self.timer + dt
    self.model.LinearVelocity = (self.model.Forward + self.model.Up) * 30
    if self.timer >= Config.ChairGlobalConfig.FlyingTime.Value then
        self.model.LinearVelocity = Vector3.Zero
        self.state = StateEnum.qteing
        self.timer = 0
    end
end

function ChairClass:SetSpeed(_dir, _speed)
    print(_dir)
    self.qteDir = self.model[_dir]
    self.model.LinearVelocity = self.model[_dir] * _speed
end

function ChairClass:Return()
    -- TODO: 开始返程
    self.model.LinearVelocity = 10 * (self.model.Position - self.freshcoo) --! 10 is a temp data!!!
end

function ChairClass:QteUpdate(dt)
    if self.type == TypeEnum.Normal or not self.startUpdate then
        return
    end
    if self.state == StateEnum.flying then
        self:Flying(dt)
    end
    if self.state == StateEnum.qteing and self.qteDir then
        self.model.Forward = Vector3.Slerp(self.model.Forward, self.qteDir, 0.8 * dt)
        self.tweener:Pause()
        self.tweener = nil
    end
    if self.state == StateEnum.returning then
        if (self.model.Position - Config.ChairInfo[self.id].Position).Magnitude <= 3 then
            self.model.IsStatic, self.model.LinearVelocitymself.model.Position, self.model.Rotation =
                true,
                Config.ChairInfo[self.id].Position,
                Config.ChairInfo[self.id].Rotation
            self.state = StateEnum.free
        end
    end
end

--********************* 普通摇摇椅 *************************
function ChairClass:NormalShake()
    -- TODO: 读Config数据
    if self.model.LocalRotation.Rotation >= Config.ChairGlobalConfig.NormalMaxAngle.Value then
        self.model.AngularVelocity = Config.ChairGlobalConfig.NormaAngularVelocity.Value
    end
    if self.model.LocalRotation.Rotation <= Config.ChairGlobalConfig.NormalMinAngle.Value then
        self.model.AngularVelocity = Vector3.Zero
    end
end

function ChairClass:ResetRotation(dt)
    self.model.Rotation = EulerDegree.Lerp(self.model.Rotation, self.freshRot, 1 * dt)
end

function ChairClass:ChairSpecialShake()
    self.model.AngularVelocity = Vector3.Zero
    SpecialMovement[math.random(1, #SpecialMovement)]()
end

function ChairClass:ChairSpeedUp()
end

function ChairClass:ResetAngularVelocity()
    -- TODO: 读Config数据
    self.model.AngularVelocity = nil
end

--普通摇摇椅update函数
function ChairClass:NormalUpdate(dt)
    if self.state == StateEnum.used then
        self:NormalShake()
    end
    if self.state == StateEnum.free and self.model.Rotation ~= self.freshRot then
        self:ResetRotation(dt)
    end
end

return ChairClass
