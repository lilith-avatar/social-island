local TwoHandedSwordAttack1 = class("TwoHandedSwordAttack1", PlayerActState)

function TwoHandedSwordAttack1:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer:MoveTowards(Vector2.Zero)
    localPlayer.Avatar:PlayAnimation("TwoHandedSwordAttack1", 4, 1, 0.1, true, false, 1)
    --localPlayer.Avatar:PlayAnimation("TwoHandedSwordAttack1", 3, 1, 0.1, true, false, 1)
end

function TwoHandedSwordAttack1:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    localPlayer:MoveTowards(Vector2.Zero)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle","SwimIdle"})
end

function TwoHandedSwordAttack1:OnLeave()
    PlayerActState.OnLeave(self)
end

return TwoHandedSwordAttack1
