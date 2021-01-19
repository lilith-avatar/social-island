local OneHandedSwordWalk = class("OneHandedSwordWalk", PlayerActState)

function OneHandedSwordWalk:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer.Avatar:PlayAnimation("OneHandedSwordWalk", 4, 1, 0.1, true, true, 1)
    --localPlayer.Avatar:PlayAnimation("OneHandedSwordWalk", 3, 1, 0.1, true, true, 1)
end

function OneHandedSwordWalk:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle","SwimIdle", "OneHandedSwordAttack1", "BowIdle"})
    self:IdleMonitor("OneHandedSword")
    self:RunMonitor("OneHandedSword")
    self:JumpMonitor("OneHandedSword")
end

function OneHandedSwordWalk:OnLeave()
    PlayerActState.OnLeave(self)
end

return OneHandedSwordWalk
