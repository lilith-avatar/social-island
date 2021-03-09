local TwoHandedSwordWalk = class("TwoHandedSwordWalk", PlayerActState)

function TwoHandedSwordWalk:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer.Avatar:PlayAnimation("TwoHandedSwordWalk", 2, 1, 0.1, true, true, 1)
    --localPlayer.Avatar:PlayAnimation("TwoHandedSwordWalk", 3, 1, 0.1, true, true, 1)
end

function TwoHandedSwordWalk:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle","SwimIdle", "TwoHandedSwordAttack1","TwoHandedSwordHit", "BowIdle"})
    self:IdleMonitor("TwoHandedSword")
    self:RunMonitor("TwoHandedSword")
    self:JumpMonitor("TwoHandedSword")
end

function TwoHandedSwordWalk:OnLeave()
    PlayerActState.OnLeave(self)
end

return TwoHandedSwordWalk
