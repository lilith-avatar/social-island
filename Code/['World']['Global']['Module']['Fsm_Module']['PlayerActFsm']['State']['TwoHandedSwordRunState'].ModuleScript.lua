local TwoHandedSwordRun = class("TwoHandedSwordRun", PlayerActState)

function TwoHandedSwordRun:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer.Avatar:PlayAnimation("TwoHandedSwordRun", 2, 1, 0.1, true, true, 1)
    --localPlayer.Avatar:PlayAnimation("TwoHandedSwordRun", 3, 1, 0.1, true, true, 1)
end

function TwoHandedSwordRun:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle","SwimIdle", "TwoHandedSwordAttack1","TwoHandedSwordHit", "BowIdle"})
    self:IdleMonitor("TwoHandedSword")
    self:WalkMonitor("TwoHandedSword")
    self:JumpMonitor("TwoHandedSword")
end

function TwoHandedSwordRun:OnLeave()
    PlayerActState.OnLeave(self)
end

return TwoHandedSwordRun
