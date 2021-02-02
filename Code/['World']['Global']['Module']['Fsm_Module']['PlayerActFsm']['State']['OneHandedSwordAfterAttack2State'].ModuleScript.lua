local OneHandedSwordAfterAttack2 = class("OneHandedSwordAfterAttack2", PlayerActState)

function OneHandedSwordAfterAttack2:OnEnter()
    PlayerActState.OnEnter(self)
    
end

function OneHandedSwordAfterAttack2:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle","SwimIdle","OneHandedSwordHit", "OneHandedSwordAttack3"})
    --self:MoveMonitor("OneHandedSword")
    --self:JumpMonitor("OneHandedSword")
end

function OneHandedSwordAfterAttack2:OnLeave()
    PlayerActState.OnLeave(self)
end

return OneHandedSwordAfterAttack2
