local BowChargeIdle = class("BowChargeIdle", PlayerActState)

function BowChargeIdle:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer:MoveTowards(Vector2.Zero)
    localPlayer.Avatar:PlayAnimation("BowChargeIdle", 2, 1, 0.1, true, true, 1)
end

function BowChargeIdle:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    localPlayer:MoveTowards(Vector2.Zero)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle", "BowHit", "SwimIdle", "BowAttack"})
end

function BowChargeIdle:OnLeave()
    PlayerActState.OnLeave(self)
end

return BowChargeIdle
