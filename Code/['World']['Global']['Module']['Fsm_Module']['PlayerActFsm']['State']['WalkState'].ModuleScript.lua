local WalkState = class("WalkState", PlayerActState)

function WalkState:OnEnter()
    PlayerActState.OnEnter(self)
    --localPlayer.Avatar:PlayAnimation("WalkingFront", 2, 1, 0.1, true, true, 1)
    localPlayer.Avatar:PlayAnimation("WalkingFront", 2, 1, 0.1, true, true, 1)
end

function WalkState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle","SwimIdle", "Fly", "BowIdle"})
    self:IdleMonitor()
    self:RunMonitor()
    self:JumpMonitor()
end

function WalkState:OnLeave()
    PlayerActState.OnLeave(self)
end

return WalkState
