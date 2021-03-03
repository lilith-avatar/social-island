local SwimIdle = class("SwimIdle", PlayerActState)

function SwimIdle:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer:MoveTowards(Vector2.Zero)
    localPlayer.GravityScale = 0
    localPlayer.LinearVelocity = Vector3(0, 0.01, 0)
    --localPlayer.Avatar:PlayAnimation("SwimIdle", 2, 1, 0.1, true, true, 1)
    localPlayer.Avatar:PlayAnimation("SwimIdle", 2, 1, 0.1, true, true, 1)
    localPlayer.Avatar.Position = localPlayer.Position + Vector3(0, 0.8, 0)
end

function SwimIdle:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle"})
    self:MoveMonitor()
    self:JumpMonitor()
end

function SwimIdle:OnLeave()
    PlayerActState.OnLeave(self)
end

---监听移动
function SwimIdle:MoveMonitor()
    local dir = PlayerCtrl.finalDir
    dir.y = 0
    if dir.Magnitude > 0 then
        FsmMgr.playerActFsm:Switch("Swimming")
    end
end

function SwimIdle:JumpMonitor()
    if FsmMgr.playerActFsm.stateTrigger.Jump then
        if localPlayer.Position.y > -15.7 then
            FsmMgr.playerActFsm:Switch("Jump")
        end
    end
end

return SwimIdle
