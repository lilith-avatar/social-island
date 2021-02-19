local BowWalk = class("BowWalk", PlayerActState)

function BowWalk:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer.Avatar:PlayAnimation("WalkingFront", 2, 1, 0.1, true, true, 1)
end

function BowWalk:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle","BowHit", "SwimIdle", "BowAttack"})
    self:IdleMonitor("Bow")
    self:RunMonitor("Bow")
    self:JumpMonitor("Bow")
end

function BowWalk:OnLeave()
    PlayerActState.OnLeave(self)
end

return BowWalk
