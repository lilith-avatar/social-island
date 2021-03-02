---@module ChairClass
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local ChairClass = class("ChairClass")
local Config = Config

-- 状态枚举
local StateEnum = {
    free = "Free", --空闲
    flying = "Flying", --喷射过程
    jeting = "Jeting", --游戏过程中
    returning = "Returning" --返程中
}

---椅子的构造函数
---@param _type string
---@param _pos Vector3
--- @param _rot EulerDegree
function ChairClass:initialize(_archetype, _name, _parent, _pos, _rot)
    --- @type MeshObject
    self.model = world:CreateInstance(_archetype, _name, _parent, _pos, _rot)
    self:DataInit(_name)
    self:DataReset(_pos, _rot)
    self:CollisionBind()
end

function ChairClass:DataInit(_id)
    self.id = _id
end

function ChairClass:DataReset(_pos, _rot)
    self.state = StateEnum.free --当前状态
    ---@type PlayerInstance
    self.owner = nil --所属者
    -- * 计时
    self.timer = 0
    -- * 记录原始位置和角度
    self.oriPos = _pos
    self.oriRot = _rot
end

function ChairClass:CollisionBind()
    self.model.CollisionArea.OnCollisionBegin:Connect(
        function(_hitObject)
            if _hitObject and _hitObject.ClassName == "PlayerInstance" and not self.owner then
                NetUtil.Fire_C("ChangeChairIdEvent", _hitObject, self.id)
                NetUtil.Fire_C("OpenDynamicEvent", _hitObject, "Interact", 10)
            end
        end
    )
    self.model.CollisionArea.OnCollisionEnd:Connect(
        function(_hitObject)
            if _hitObject and _hitObject.ClassName == "PlayerInstance" then
                NetUtil.Fire_C("ChangeMiniGameUIEvent", _hitObject)
            end
        end
    )
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
    self.model.IsStatic = false
    self.model.LinearVelocity =
        (self.model.Up + self.model.Forward).Normalized * Config.ChairGlobalConfig.FlyingVelocity.Value
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
        self.model.LinearVelocity = Vector3.Zero
        self.state = StateEnum.jeting
    end
end

local randomAv = {x = 0, y = 0, z = 0}
function ChairClass:JetingUpdate(dt)
    self.timer = self.timer + dt
    if self.timer >= Config.ChairGlobalConfig.JetingDuration.Value then
        randomAv.x, randomAv.y, randomAv.z =
            Config.ChairGlobalConfig.BaseAngularVelocity.Value.x *
                math.random(1, Config.ChairGlobalConfig.RatioRandomRange.Value) *
                0.1,
            Config.ChairGlobalConfig.BaseAngularVelocity.Value.y *
                math.random(1, Config.ChairGlobalConfig.RatioRandomRange.Value) *
                0.1,
            Config.ChairGlobalConfig.BaseAngularVelocity.Value.z *
                math.random(1, Config.ChairGlobalConfig.RatioRandomRange.Value) *
                0.1
        self.timer = 0
        self.model.AngularVelocity = Vector3(randomAv.x, randomAv.y, randomAv.z)
    end
end

function ChairClass:ReturningUpdate(dt)
    if (self.model.Position - self.oriPos).Magnitude <= 3 then
        self.model.Position, self.model.Rotation = self.oriPos, self.oriRot
        self.model.LinearVelocity = Vector3.Zero
        self.model.AngularVelocity = Vector3.Zero
        self.model.IsStatic = true
        self.state = StateEnum.free
    end
end

return ChairClass
