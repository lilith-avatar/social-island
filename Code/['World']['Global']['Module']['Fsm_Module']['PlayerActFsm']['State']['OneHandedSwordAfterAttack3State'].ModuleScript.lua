local OneHandedSwordAfterAttack3 = class("OneHandedSwordAfterAttack3", PlayerActState)

function OneHandedSwordAfterAttack3:OnEnter()
    PlayerActState.OnEnter(self)
    
end

function OneHandedSwordAfterAttack3:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle","SwimIdle"})
    --self:MoveMonitor("OneHandedSword")
    --self:JumpMonitor("OneHandedSword")
end

function OneHandedSwordAfterAttack3:OnLeave()
    PlayerActState.OnLeave(self)
end

return OneHandedSwordAfterAttack3
