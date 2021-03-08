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
    returning = "Returning", --返程中
    trojan = "Trojan"
}

---椅子的构造函数
---@param _type string
---@param _pos Vector3
--- @param _rot EulerDegree
function ChairClass:initialize(_archetype, _name, _parent, _pos, _rot)
    --- @type MeshObject
    self.model = world:CreateInstance(_archetype, _name, _parent, _pos, _rot)
    self:DataInit(_name, _pos, _rot)
    self:DataReset()
    self:CollisionBind()
end

function ChairClass:DataInit(_id, _pos, _rot)
    self.id = _id
    -- * 记录原始位置和角度
    self.oriPos = _pos
    self.oriRot = _rot
end

function ChairClass:DataReset()
    self.state = StateEnum.free --当前状态
    ---@type PlayerInstance
    self.owner = nil --所属者
    -- * 计时
    self.timer = 0
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
    self.model.Seat:Sit(_player)
    self.owner.Avatar:PlayAnimation("SitIdle", 2, 1, 0, true, true, 1)
    self.model.Seat:SetActive(true)
    self.owner.CollisionGroup = 15
    _player.Position = self.model.Seat.Position
    -- 开始喷射
    self:Fly()
end

function ChairClass:Stand()
    if self.owner then
        self.model.Seat:Leave(self.owner)
        self.owner.CollisionGroup = 1
        NetUtil.Fire_C("FsmTriggerEvent", self.owner, "Jump")
    end
    self.model.Seat:SetActive(false)
    self:Return()
end

function ChairClass:Fly()
    self.state = StateEnum.flying
    self.model.IsStatic = false
    self.model.Chair.Effect:SetActive(true)
    self.model.LinearVelocity =
        (self.model.Up + self.model.Forward).Normalized * Config.ChairGlobalConfig.FlyingVelocity.Value
    NetUtil.Fire_C('PlayEffectEvent',self.owner,59,self.owner.Position)
end

function ChairClass:Return()
    self.state = StateEnum.returning
    self.model.Block = false
    self.model.AngularVelocity = Vector3.Zero
end

function ChairClass:Update(dt)
    if not self.owner and self.state and self.state ~= StateEnum.free then
        self:Stand()
        return
    end
    if self.state then
        self[self.state .. "Update"](self, dt)
    end
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
        NetUtil.Fire_C("StartJetEvent", self.owner)
    end
end

local randomLv = {x = 0, y = 0, z = 0}
function ChairClass:ChangeLine()
    randomLv.x, randomLv.y, randomLv.z =
        Config.ChairGlobalConfig.BaseLinearVelocity.Value.x * world.MiniGames.Game_10_Chair.Balance.Value * 2,
        Config.ChairGlobalConfig.BaseLinearVelocity.Value.y * world.MiniGames.Game_10_Chair.Balance.Value * 2,
        Config.ChairGlobalConfig.BaseLinearVelocity.Value.z * world.MiniGames.Game_10_Chair.Balance.Value * 2
    self.model.LinearVelocity = Vector3(randomLv.x, randomLv.y, randomLv.z)
end

local randomAv = {x = 0, y = 0, z = 0}
function ChairClass:ChangAngular()
    randomAv.x, randomAv.y, randomAv.z =
        Config.ChairGlobalConfig.BaseAngularVelocity.Value.x * world.MiniGames.Game_10_Chair.Balance.Value * 2,
        Config.ChairGlobalConfig.BaseAngularVelocity.Value.y * world.MiniGames.Game_10_Chair.Balance.Value * 2,
        Config.ChairGlobalConfig.BaseAngularVelocity.Value.z * world.MiniGames.Game_10_Chair.Balance.Value * 2
    self.model.AngularVelocity = Vector3(randomAv.x, randomAv.y, randomAv.z)
end

function ChairClass:JetingUpdate(dt)
    local randomFunc = math.random(1, 2) == 1 and self:ChangeLine() or self:ChangAngular()
end

function ChairClass:ReturningUpdate(dt)
    self.model.LinearVelocity =
        (self.oriPos - self.model.Position).Normalized * Config.ChairGlobalConfig.ReturningVelocity.Value
    if (self.model.Position - self.oriPos).Magnitude <= 1 then
        self.model.Block = true
        self.model.Position, self.model.Rotation = self.oriPos, self.oriRot
        self.model.LinearVelocity = Vector3.Zero
        self.model.AngularVelocity = Vector3.Zero
        self:DataReset()
        self.model.IsStatic = true
        self.model.Chair.Effect:SetActive(false)
        self.state = StateEnum.free
    end
end

--***** 木马Update函数 *****
function ChairClass:TrojanUpdate(dt)
    
end

return ChairClass
