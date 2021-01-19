local BowRun = class("BowRun", PlayerActState)

function BowRun:OnEnter()
    PlayerActState.OnEnter(self)
    local dir = PlayerCtrl.finalDir
    if Vector3.Angle(dir, localPlayer.Forward) < 60 then
        localPlayer.Avatar:PlayAnimation("RunFront", 3, 1, 0.1, true, true, 1)
    elseif Vector3.Angle(dir, localPlayer.Right) < 30 then
        localPlayer.Avatar:PlayAnimation("RunRight", 3, 1, 0.1, true, true, 1)
    elseif Vector3.Angle(dir, localPlayer.Left) < 30 then
        localPlayer.Avatar:PlayAnimation("RunLeft", 3, 1, 0.1, true, true, 1)
    else
        localPlayer.Avatar:PlayAnimation("RunBack", 3, 1, 0.1, true, true, 1)
    end
end

function BowRun:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle", "SwimIdle", "BowAttack"})
    self:IdleMonitor()
    self:WalkMonitor("Bow")
    self:JumpMonitor("Bow")
end

function BowRun:OnLeave()
    PlayerActState.OnLeave(self)
end

---监听静止
function BowRun:IdleMonitor()
    local dir = PlayerCtrl.finalDir
    dir.y = 0
    if dir.Magnitude > 0 then
        if localPlayer.LinearVelocity.Magnitude > 0 and Vector3.Angle(dir, localPlayer.LinearVelocity) > 30 then
            if Vector3.Angle(dir, localPlayer.Forward) < 60 then
                localPlayer.Avatar:PlayAnimation("RunFront", 3, 1, 0.1, true, true, 1)
            elseif Vector3.Angle(dir, localPlayer.Right) < 30 then
                localPlayer.Avatar:PlayAnimation("RunRight", 3, 1, 0.1, true, true, 1)
            elseif Vector3.Angle(dir, localPlayer.Left) < 30 then
                localPlayer.Avatar:PlayAnimation("RunLeft", 3, 1, 0.1, true, true, 1)
            else
                localPlayer.Avatar:PlayAnimation("RunBack", 3, 1, 0.1, true, true, 1)
            end
        end
        localPlayer:MoveTowards(Vector2(dir.x, dir.z).Normalized)
    else
        NetUtil.Fire_C("FsmTriggerEvent", localPlayer, "BowIdle")
    end
end

return BowRun
