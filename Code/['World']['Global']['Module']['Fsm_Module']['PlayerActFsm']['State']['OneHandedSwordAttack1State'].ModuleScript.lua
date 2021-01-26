local OneHandedSwordAttack1 = class("OneHandedSwordAttack1", PlayerActState)

function OneHandedSwordAttack1:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer:MoveTowards(Vector2.Zero)
    localPlayer.Avatar:PlayAnimation("OneHandedSwordAttack1", 4, 1, 0.1, true, false, 1)
    --localPlayer.Avatar:PlayAnimation("OneHandedSwordAttack1", 3, 1, 0.1, true, false, 1)
end

function OneHandedSwordAttack1:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    localPlayer:MoveTowards(Vector2.Zero)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle","SwimIdle"})
end

function OneHandedSwordAttack1:OnLeave()
    PlayerActState.OnLeave(self)
end

return OneHandedSwordAttack1
