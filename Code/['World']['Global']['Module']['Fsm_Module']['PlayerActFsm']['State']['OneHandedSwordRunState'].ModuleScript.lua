local OneHandedSwordRun = class("OneHandedSwordRun", PlayerActState)

function OneHandedSwordRun:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer.Avatar:PlayAnimation("OneHandedSwordRun", 2, 1, 0.1, true, true, 1)
    --localPlayer.Avatar:PlayAnimation("OneHandedSwordRun", 3, 1, 0.1, true, true, 1)
end

function OneHandedSwordRun:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle","SwimIdle", "OneHandedSwordAttack1", "BowIdle"})
    self:IdleMonitor("OneHandedSword")
    self:WalkMonitor("OneHandedSword")
    self:JumpMonitor("OneHandedSword")
end

function OneHandedSwordRun:OnLeave()
    PlayerActState.OnLeave(self)
end

return OneHandedSwordRun
