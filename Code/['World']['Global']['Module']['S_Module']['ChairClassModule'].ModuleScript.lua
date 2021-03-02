---@module ChairClass
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local ChairClass = class("ChairClass")
local Config = Config

-- 状态枚举
local StateEnum = {
    Free = 1, --空闲
    Flying = 2, --喷射过程
    Jeting = 3, --游戏过程中
    Returning = 4 --返程中
}

---椅子的构造函数
---@param _type string
---@param _pos Vector3
--- @param _rot EulerDegree
function ChairClass:initialize(_archetype, _name, _parent, _pos, _rot)
    --- @type MeshObject
    self.model = world:CreateInstance(_archetype, _name, _parent, _pos, _rot)
    self:DataReset()
end

function ChairClass:DataReset()
    self.state = StateEnum.free --当前状态
    ---@type PlayerInstance
    self.owner = nil --所属者
    -- * 计时
    self.timer = 0
    -- * 记录原始位置和角度
    self.oriPos = self.model.Position
    self.oriRot = self.model.Rotation
end

---玩家坐下
---@param _player PlayerInstance
function ChairClass:Sit(_player)
    self.owner = _player
    -- 开始喷射
    self:Fly()
end

function ChairClass:Stand()
    self:DataReset()
end

function ChairClass:Fly()
    self.state = StateEnum.flying
    self.model.LinearVelocity = Vector3.Zero
end

function ChairClass:Return()
    self.state = StateEnum.Returning
    self.model.LinearVelocity = Vector3.Zero
    self.model.AngularVelocity = Vector3.Zero
end

function ChairClass:Update(dt)
    if not self.owner and self.state ~= StateEnum.free then
        self:Stand()
    end
    self[self.state .. "Update"](self, dt)
end

--***** 各状态update函数 *****
function ChairClass:FreeUpdate(dt)
end

function ChairClass:FlyingUpdate(dt)
    self.timer = self.timer + dt
    if self.timer >= Config.ChairGlobalConfig.FlyingTime.Value then
        self.timer = 0
        self.state = StateEnum.Jeting
    end
end

function ChairClass:JetingUpdate(dt)
    self.timer = self.timer + dt
    if self.timer >= Config.ChairGlobalConfig.JetingDuration.Value then
        self.timer = 0
        self.model.AngularVelocity = Vector3()
    end
end

function ChairClass:ReturningUpdate(dt)
    if (self.model.Position - self.oriPos).Magnitude <= 3 then
        self.model.Position, self.model.Rotation = self.oriPos, self.oriRot
        self.model.LinearVelocity = Vector3.Zero
        self.model.AngularVelocity = Vector3.Zero
        self.model.IsStatic = true
        self.state = StateEnum.Free
    end
end

return ChairClass
