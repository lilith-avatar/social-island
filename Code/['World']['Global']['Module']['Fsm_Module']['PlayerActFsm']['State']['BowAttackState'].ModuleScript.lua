local BowAttack = class("BowAttack", PlayerActState)

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
            localPlayer.Avatar:PlayAnimation("WalkingFront", 9, 1, 0.1, true, true, 1)
        elseif _dir == dirStateEnum.Right then
            localPlayer.Avatar:PlayAnimation("WalkingRight", 9, 1, 0.1, true, true, 1)
        elseif _dir == dirStateEnum.Left then
            localPlayer.Avatar:PlayAnimation("WalkingLeft", 9, 1, 0.1, true, true, 1)
        elseif _dir == dirStateEnum.Back then
            localPlayer.Avatar:PlayAnimation("WalkingBack", 9, 1, 0.1, true, true, 1)
        end
    end
end

function BowAttack:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer.Avatar:PlayAnimation("BowAttack", 2, 1, 0.1, true, false, 1)
    localPlayer.Avatar.Bone_R_Hand.BowReleaseEffect:SetActive(true)
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

function BowAttack:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle", "SwimIdle", "BowHit"})
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
        localPlayer:MoveTowards(Vector2(dir.x, dir.z) * 0.4)
    else
        localPlayer:MoveTowards(Vector2.Zero)
        localPlayer.Avatar:StopAnimation("WalkingFront", 9)
        localPlayer.Avatar:StopAnimation("WalkingRight", 9)
        localPlayer.Avatar:StopAnimation("WalkingLeft", 9)
        localPlayer.Avatar:StopAnimation("WalkingBack", 9)
    end
end

function BowAttack:OnLeave()
    PlayerActState.OnLeave(self)
    localPlayer.Avatar.Bone_R_Hand.BowReleaseEffect:SetActive(false)
    localPlayer.Avatar:StopAnimation("WalkingFront", 9)
    localPlayer.Avatar:StopAnimation("WalkingRight", 9)
    localPlayer.Avatar:StopAnimation("WalkingLeft", 9)
    localPlayer.Avatar:StopAnimation("WalkingBack", 9)
end

return BowAttack
