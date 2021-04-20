local BowRun = class('BowRun', PlayerActState)

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
            localPlayer.Avatar:PlayAnimation('BowRun', 2, 1, 0.1, true, true, localPlayer.WalkSpeed / 6)
        elseif _dir == dirStateEnum.Right then
            localPlayer.Avatar:PlayAnimation('BowRunRight', 2, 1, 0.1, true, true, localPlayer.WalkSpeed / 6)
        elseif _dir == dirStateEnum.Left then
            localPlayer.Avatar:PlayAnimation('BowRunLeft', 2, 1, 0.1, true, true, localPlayer.WalkSpeed / 6)
        elseif _dir == dirStateEnum.Back then
            localPlayer.Avatar:PlayAnimation('BowRunBack', 2, 1, 0.1, true, true, localPlayer.WalkSpeed / 6)
        end
    end
end

function BowRun:OnEnter()
    PlayerActState.OnEnter(self)
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

function BowRun:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor(
        {
            'Idle',
            'BowHit',
            'SwimIdle',
            'BowChargeIdle',
            'TakeOutItem'
        }
    )
    self:IdleMonitor()
    self:WalkMonitor('Bow')
    self:JumpMonitor('Bow')
end

function BowRun:OnLeave()
    PlayerActState.OnLeave(self)
end

---监听静止
function BowRun:IdleMonitor()
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
        FsmMgr.playerActFsm:Switch('BowIdle')
    end
end

return BowRun
