local TwoHandedSwordIdle = class("TwoHandedSwordIdle", PlayerActState)

function TwoHandedSwordIdle:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer:MoveTowards(Vector2.Zero)
    localPlayer.GravityScale = 2
    localPlayer.Avatar:PlayAnimation("TwoHandedSwordIdle", 2, 1, 0.1, true, true, 1)
    --localPlayer.Avatar:PlayAnimation("TwoHandedSwordIdle", 3, 1, 0.1, true, true, 1)
end

function TwoHandedSwordIdle:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle", "SwimIdle", "TwoHandedSwordAttack1", "BowIdle"})
    self:MoveMonitor("TwoHandedSword")
    self:JumpMonitor("TwoHandedSword")
end

function TwoHandedSwordIdle:OnLeave()
    PlayerActState.OnLeave(self)
end

return TwoHandedSwordIdle
