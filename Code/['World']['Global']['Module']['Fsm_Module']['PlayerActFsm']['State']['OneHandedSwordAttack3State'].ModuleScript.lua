local OneHandedSwordAttack3 = class("OneHandedSwordAttack3", PlayerActState)

function OneHandedSwordAttack3:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer:MoveTowards(Vector2.Zero)
    localPlayer.Avatar:PlayAnimation("OneHandedSwordAttack3", 2, 1, 0.1, true, false, 1)
    --localPlayer.Avatar:PlayAnimation("OneHandedSwordAttack3", 3, 1, 0.1, true, false, 1)
end

function OneHandedSwordAttack3:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    localPlayer:MoveTowards(Vector2.Zero)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle","SwimIdle"})
end

function OneHandedSwordAttack3:OnLeave()
    PlayerActState.OnLeave(self)
end

return OneHandedSwordAttack3
