local TwoHandedSwordAfterAttack2 = class("TwoHandedSwordAfterAttack2", PlayerActState)

function TwoHandedSwordAfterAttack2:OnEnter()
    PlayerActState.OnEnter(self)
    
end

function TwoHandedSwordAfterAttack2:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle","SwimIdle", "TwoHandedSwordAttack3"})
    --self:MoveMonitor("TwoHandedSword")
    --self:JumpMonitor("TwoHandedSword")
end

function TwoHandedSwordAfterAttack2:OnLeave()
    PlayerActState.OnLeave(self)
end

return TwoHandedSwordAfterAttack2
