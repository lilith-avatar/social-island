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


--- ***** qte 旋转函数 ******
---@param _obj Object
local function MoveForward(_obj)
    _obj:Rotate()
end

local function MoveLeft(_obj)
    _obj:Rotate()
end

local function MoveBack(_obj)
    _obj:Rotate()
end

local function MoveRight(_obj)
    _obj:Rotate()
end

local DirFunction = {
    Forward = function(_obj)
        MoveForward(_obj)
    end,
    Left = function(_obj)
        MoveLeft(_obj)
    end,
    Back = function(_obj)
        MoveBack(_obj)
    end,
    Right = function(_obj)
        MoveRight(_obj)
    end
}

---方向函数

---椅子的构造函数
---@param _type string
---@param _pos Vector3
--- @param _rot EulerDegree
function ChairClass:initialize(_type, _id, _arch, _parent, _pos, _rot)
    self.type = TypeEnum[_type]
    self:CommonDataInit(_arch, _parent, _pos, _rot, _id)
end

function ChairClass:CommonDataInit(_arch, _parent, _pos, _rot, _id)
    self.model = world:CreateInstance(_arch, _arch, _parent, _pos, _rot)
    self.state = StateEnum.free
    self.sitter = nil
    self.startUpdate = false
    self.timer = 0
    self.id = _id
end

function ChairClass:Sit(_player)
    if not self.sitter or self.state ~= StateEnum.free then
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
    end
end

function ChairClass:Stand()
    self.sitter = nil
    self.state = StateEnum.free
    --判断是否结束QTE
    if self.type == TypeEnum.QTE then
        self.state = StateEnum.returning
    end
end

--********************* qte摇摇椅 *************************
function ChairClass:Fly()
    self.state = StateEnum.flying
    --喷射
    self.tweener = Tween:ShakeProperty(self.model, {Rotation.y}, 100, 0.2)
    self.tweener:Play()
end

function ChairClass:Flying(dt)
    -- 一段时间后停下
    self.timer = self.timer + dt
    if self.timer >= Config.ChairGlobalConfig[self.id].FlyingTime then
        self.state = StateEnum.qteing
        self.timer = 0
    end
end

function ChairClass:SetSpeed(_dir, _speed)
    DirFunction[_dir](self.model)
    self.model.LinearVelocity = self.model.Forward * _speed
end

function ChairClass:Update(dt)
    if self.type == TypeEnum.Normal or not self.startUpdate then
        return
    end
    if self.state == StateEnum.flying then
        self:Flying(dt)
    end
    if self.state == StateEnum.returning then
    end
end

return ChairClass
