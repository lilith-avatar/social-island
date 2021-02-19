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

-- ***** 特殊动作实现 *****
local function AroundTheWorld(_obj)
end

-- 特殊动作枚举
local SpecialMovement = {
    function(_obj)
        AroundTheWorld(_obj)
    end,
    -- function(_obj)
    -- end
}

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
    self.model.LinearVelocity = Vector3.Zero
    self.model.IsStatic = false
    self.normalShakeRatio = 1
    --判断是否开始QTE
    if self.type == TypeEnum.QTE then
        self:Fly()
        self.state = StateEnum.flying
    else
        self:StartShake()
    end
end

function ChairClass:Stand()
    self.sitter = nil
    self.state = StateEnum.free
    self.model.Seat:SetActive(false)
    self.model.CollisionArea:SetActive(true)
    self.model.IsStatic = true
    self.qteDir = nil
    self.normalShakeRatio = -1
    --判断是否结束QTE
    if self.type == TypeEnum.QTE then
        --self.model:Rotate(EulerDegree(-30, 0, 0))
        self:Return()
        self.state = StateEnum.returning
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
    self.model.LinearVelocity = (self.model.Forward + self.model.Up) * Config.ChairGlobalConfig.FlyingSpeed.Value
    if self.timer >= Config.ChairGlobalConfig.FlyingTime.Value then
        self.model.LinearVelocity = Vector3.Zero
        self.tweener:Pause()
        self.tweener:Destroy()
        self.tweener = nil
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
    self.model.IsStatic = false
    -- TODO: 开始返程
    self.model.LinearVelocity = (self.freshcoo - self.model.Position).Normalized * 5
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
    end
    if self.state == StateEnum.returning then
        if (self.model.Position - Config.ChairInfo[self.id].Position).Magnitude <= 3 then
            self.model.IsStatic, self.model.LinearVelocity,self.model.Position, self.model.Rotation =
                true,
                Vector3.Zero,
                Config.ChairInfo[self.id].Position,
                Config.ChairInfo[self.id].Rotation
            self.state = StateEnum.free
        end
    end
end

--********************* 普通摇摇椅 *************************
function ChairClass:StartShake()
    self.model.AngularVelocity = Config.ChairGlobalConfig.NormalAngularVelocity.Value
end

function ChairClass:NormalShake()
    -- 读Config数据
    if self.model.LocalRotation.x >= Config.ChairGlobalConfig.NormalMaxAngle.Value then
        self.normalShakeRatio = -1
    end
    if self.model.LocalRotation.x <= Config.ChairGlobalConfig.NormalMinAngle.Value then
        self.normalShakeRatio = 1
    end
    self.model.AngularVelocity = Config.ChairGlobalConfig.NormalAngularVelocity.Value * self.normalShakeRatio
end

function ChairClass:ResetRotation(dt)
    self.model.LocalRotation = EulerDegree.Lerp(self.model.LocalRotation, EulerDegree(0,0,0), 1 * dt)
end

function ChairClass:ChairSpecialShake()
    self.model.AngularVelocity = Vector3.Zero
    self.normalShakeRatio = 0
    --SpecialMovement[math.random(1, #SpecialMovement)]()
end

function ChairClass:ChairSpeedUp()
    self.model.AngularVelocity = Config.ChairGlobalConfig.BoostAngularVelocity.Value * self.normalShakeRatio
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
