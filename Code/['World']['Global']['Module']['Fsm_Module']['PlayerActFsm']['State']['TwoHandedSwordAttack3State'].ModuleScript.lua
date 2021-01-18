local TwoHandedSwordAttack3 = class("TwoHandedSwordAttack3", PlayerActState)

function TwoHandedSwordAttack3:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer:MoveTowards(Vector2.Zero)
    localPlayer.Avatar:PlayAnimation("TwoHandedSwordAttack3", 4, 1, 0.1, true, false, 1)
    --localPlayer.Avatar:PlayAnimation("TwoHandedSwordAttack3", 3, 1, 0.1, true, false, 1)
end

function TwoHandedSwordAttack3:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    localPlayer:MoveTowards(Vector2.Zero)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle","SwimIdle"})
end

function TwoHandedSwordAttack3:OnLeave()
    PlayerActState.OnLeave(self)
end

return TwoHandedSwordAttack3
