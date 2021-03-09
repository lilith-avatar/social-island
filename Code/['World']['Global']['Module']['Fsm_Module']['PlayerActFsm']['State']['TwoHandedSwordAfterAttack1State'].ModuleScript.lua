local TwoHandedSwordAfterAttack1 = class("TwoHandedSwordAfterAttack1", PlayerActState)

function TwoHandedSwordAfterAttack1:OnEnter()
    PlayerActState.OnEnter(self)
    
end

function TwoHandedSwordAfterAttack1:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle","SwimIdle", "TwoHandedSwordAttack2","TwoHandedSwordHit"})
    --self:MoveMonitor("TwoHandedSword")
    --self:JumpMonitor("TwoHandedSword")
end

function TwoHandedSwordAfterAttack1:OnLeave()
    PlayerActState.OnLeave(self)
end

return TwoHandedSwordAfterAttack1
