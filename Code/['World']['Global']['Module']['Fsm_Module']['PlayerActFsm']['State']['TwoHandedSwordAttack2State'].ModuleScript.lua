local TwoHandedSwordAttack2 = class("TwoHandedSwordAttack2", PlayerActState)

function TwoHandedSwordAttack2:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer:MoveTowards(Vector2.Zero)
    localPlayer.Avatar:PlayAnimation("TwoHandedSwordAttack2", 2, 1, 0.1, true, false, 1)
    --localPlayer.Avatar:PlayAnimation("TwoHandedSwordAttack2", 3, 1, 0.1, true, false, 1)
end

function TwoHandedSwordAttack2:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    localPlayer:MoveTowards(Vector2.Zero)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle", "SwimIdle"})
end

function TwoHandedSwordAttack2:OnLeave()
    PlayerActState.OnLeave(self)
end

return TwoHandedSwordAttack2
