--- 玩家动作状态
-- @module  PlayerActState
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
local PlayerActState = class('PlayerActState', StateBase)

--水体
local waterData = {}

function PlayerActState:initialize(_controller, _stateName)
    print('ControllerBase:initialize()')
    StateBase.initialize(self, _controller, _stateName)
    waterData = {
        rangeMin = world.Water.DeepWaterCol.Position -
            Vector3(
                world.Water.DeepWaterCol.Size.x / 2,
                world.Water.DeepWaterCol.Size.y / 2,
                world.Water.DeepWaterCol.Size.z / 2
            ),
        rangeMax = world.Water.DeepWaterCol.Position +
            Vector3(
                world.Water.DeepWaterCol.Size.x / 2,
                world.Water.DeepWaterCol.Size.y / 2,
                world.Water.DeepWaterCol.Size.z / 2
            )
    }
end

---移动
function PlayerActState:Move(_isSprint)
    _isSprint = _isSprint or false
    local dir = PlayerCtrl.finalDir
    dir.y = 0
    if _isSprint then
        if PlayerCtrl.isSprint then
            localPlayer:AddMovementInput(dir, 1)
        else
            localPlayer:AddMovementInput(dir, 0.5)
        end
    else
        localPlayer:AddMovementInput(dir, 0.5)
    end
end

---游泳
function PlayerActState:Swim(_multiple)
    local lvY = self:MoveMonitor() and math.clamp((PlayerCam.playerGameCam.Forward.y + 0.2), -1, 1) or 0
    if self:IsWaterSuface() and lvY > 0 then
        lvY = 0
        localPlayer.Velocity.y = 0
    end
    if self:FloorMonitor(3) and lvY < 0 then
        lvY = 0
    end
    local dir = Vector3(PlayerCtrl.finalDir.x, lvY, PlayerCtrl.finalDir.z)
    --print(dir)
    localPlayer:AddMovementInput(dir, _multiple or 1)
end

---监听移动
function PlayerActState:MoveMonitor()
    local dir = PlayerCtrl.finalDir
    dir.y = 0
    if dir.Magnitude > 0 then
        return true
    else
        return false
    end
end

--监听是否在地面上
function PlayerActState:FloorMonitor(_dis)
    local startPos = localPlayer.Position
    local endPos = localPlayer.Position + Vector3.Down * (_dis or 0.03)
    local hitResult = Physics:RaycastAll(startPos, endPos, true)
    for i, v in pairs(hitResult.HitObjectAll) do
        if v.Block and v ~= localPlayer then
            return true
        end
    end
    return false
end

---监听游泳
function PlayerActState:SwimMonitor()
    if
        localPlayer.Position.x > waterData.rangeMin.x and localPlayer.Position.x < waterData.rangeMax.x and
            localPlayer.Position.y > waterData.rangeMin.y and
            localPlayer.Position.y < waterData.rangeMax.y and
            localPlayer.Position.z > waterData.rangeMin.z and
            localPlayer.Position.z < waterData.rangeMax.z
     then
        if self:FloorMonitor(0.05) and localPlayer.Position.y > waterData.rangeMax.y - 0.2 then
            return false
        end
        return true
    else
        return false
    end
end

---监听速度
function PlayerActState:SpeedMonitor(_maxSpeed)
    local velocity = localPlayer.Velocity
    localPlayer.Avatar:SetParamValue('speedY', math.clamp((velocity.y / 10), -1, 1))
    velocity.y = 0
    localPlayer.Avatar:SetParamValue(
        'speedXZ',
        math.clamp((velocity.Magnitude / (_maxSpeed or localPlayer.MaxWalkSpeed)), 0, 1)
    )
    --print(math.clamp((velocity.Magnitude / (_maxSpeed or 9)), 0, 1))
    local vX = math.cos(math.rad(Vector3.Angle(velocity, localPlayer.Left))) * velocity.Magnitude
    localPlayer.Avatar:SetParamValue('speedX', math.clamp((vX / (_maxSpeed or localPlayer.MaxWalkSpeed)), -1, 1))
    local vZ = math.cos(math.rad(Vector3.Angle(velocity, localPlayer.Forward))) * velocity.Magnitude
    localPlayer.Avatar:SetParamValue('speedZ', math.clamp((vZ / (_maxSpeed or localPlayer.MaxWalkSpeed)), -1, 1))
end

---监听下落状态
function PlayerActState:FallMonitor()
    if not self:FloorMonitor(0.5) and localPlayer.Velocity.y < 0.5 then
        self.controller:CallTrigger('JumpHighestState')
        self.controller:CallTrigger('BowJumpHighestState')
    end
end

---是否在水面
function PlayerActState:IsWaterSuface()
    if localPlayer.Position.y > waterData.rangeMax.y - 1 then
        return true
    else
        return false
    end
end

---镜头更新
function PlayerActState:CamUpdate()
    local maxFov = 0
    local changeSpeed = localPlayer.Velocity.Magnitude
    if changeSpeed > 20 then
        maxFov = 90
    elseif changeSpeed > 10 then
        maxFov = 75
    elseif changeSpeed > 5 then
        maxFov = 70
    elseif changeSpeed > 1 then
        maxFov = 65
    else
        maxFov = 60
        changeSpeed = -50
    end
    changeSpeed = changeSpeed / 100
    PlayerCam:CameraFOVZoom(changeSpeed, maxFov)
end

function PlayerActState:OnUpdate()
    StateBase.OnUpdate(self)
    --self:CamUpdate()
end

return PlayerActState
