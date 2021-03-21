local PistolRun = class("PistolRun", PlayerActState)

local dirStateEnum = {
    Forward = 1,
    Back = 2,
    Right = 3,
    Left = 4
}

local curDirState = 0

local function Turn(_dir)
    if _dir ~= curDirState then
        curDirState = _dir
        if _dir == dirStateEnum.Forward then
            localPlayer.Avatar:PlayAnimation("WalkFront", 9, 1, 0.1, true, true, 1)
        elseif _dir == dirStateEnum.Right then
            localPlayer.Avatar:PlayAnimation("WalkRight", 9, 1, 0.1, true, true, 1)
        elseif _dir == dirStateEnum.Left then
            localPlayer.Avatar:PlayAnimation("WalkLeft", 9, 1, 0.1, true, true, 1)
        elseif _dir == dirStateEnum.Back then
            localPlayer.Avatar:PlayAnimation("WalkBack", 9, 1, 0.1, true, true, 1)
        end
    end
end

function PistolRun:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer.Avatar:SetBlendSubtree(Enum.BodyPart.LowerBody, 9)
    local dir = PlayerCtrl.finalDir
    curDirState = 0
    if Vector3.Angle(dir, localPlayer.Forward) < 30 then
        Turn(dirStateEnum.Forward)
    elseif Vector3.Angle(dir, localPlayer.Right) < 75 then
        Turn(dirStateEnum.Right)
    elseif Vector3.Angle(dir, localPlayer.Left) < 75 then
        Turn(dirStateEnum.Left)
    else
        Turn(dirStateEnum.Back)
    end
end

function PistolRun:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    localPlayer:MoveTowards(Vector2.Zero)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle", "SwimIdle", "OneHandedSwordIdle", "PistolHit", "Vertigo"})
    self:IdleMonitor()
    self:MoveMonitor("Pistol")
    self:JumpMonitor("Pistol")
end

function PistolRun:OnLeave()
    PlayerActState.OnLeave(self)
end

---监听静止
function PistolRun:IdleMonitor()
    local dir = PlayerCtrl.finalDir
    dir.y = 0
    if dir.Magnitude > 0 then
        if localPlayer.LinearVelocity.Magnitude > 0 then
            if Vector3.Angle(dir, localPlayer.Forward) < 30 then
                Turn(dirStateEnum.Forward)
            elseif Vector3.Angle(dir, localPlayer.Right) < 75 then
                Turn(dirStateEnum.Right)
            elseif Vector3.Angle(dir, localPlayer.Left) < 75 then
                Turn(dirStateEnum.Left)
            else
                Turn(dirStateEnum.Back)
            end
        end
        localPlayer:MoveTowards(Vector2(dir.x, dir.z))
    else
        FsmMgr.playerActFsm:Switch("PistolIdle")
    end
end

return PistolRun
