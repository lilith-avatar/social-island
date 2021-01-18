local TwoHandedSwordAfterAttack3 = class("TwoHandedSwordAfterAttack3", PlayerActState)

function TwoHandedSwordAfterAttack3:OnEnter()
    PlayerActState.OnEnter(self)
    
end

function TwoHandedSwordAfterAttack3:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle","SwimIdle"})
    --self:MoveMonitor("TwoHandedSword")
    --self:JumpMonitor("TwoHandedSword")
end

function TwoHandedSwordAfterAttack3:OnLeave()
    PlayerActState.OnLeave(self)
end

return TwoHandedSwordAfterAttack3
