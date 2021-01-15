local OneHandedSwordAfterAttack1 = class("OneHandedSwordAfterAttack1", PlayerActState)

function OneHandedSwordAfterAttack1:OnEnter()
    PlayerActState.OnEnter(self)
    
end

function OneHandedSwordAfterAttack1:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle","SwimIdle", "OneHandedSwordAttack2"})
    --self:MoveMonitor("OneHandedSword")
    --self:JumpMonitor("OneHandedSword")
end

function OneHandedSwordAfterAttack1:OnLeave()
    PlayerActState.OnLeave(self)
end

return OneHandedSwordAfterAttack1
