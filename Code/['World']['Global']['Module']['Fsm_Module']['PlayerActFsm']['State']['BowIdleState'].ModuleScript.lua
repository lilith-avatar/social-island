local BowIdle = class("BowIdle", PlayerActState)

function BowIdle:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer:MoveTowards(Vector2.Zero)
    localPlayer.Avatar:PlayAnimation("BowChargeIdle", 2, 1, 0.1, true, true, 1)
    localPlayer.Avatar:PlayAnimation("BowChargeIdle", 3, 1, 0.1, true, true, 1)
end

function BowIdle:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    localPlayer:MoveTowards(Vector2.Zero)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle", "SwimIdle", "BowWalk", "BowJump", "BowAttack"})
    self:MoveMonitor("Bow")
    self:JumpMonitor("Bow")
end

function BowIdle:OnLeave()
    PlayerActState.OnLeave(self)
end

return BowIdle
