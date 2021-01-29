local OneHandedSwordAttack2 = class("OneHandedSwordAttack2", PlayerActState)

function OneHandedSwordAttack2:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer:MoveTowards(Vector2.Zero)
    localPlayer.Avatar:PlayAnimation("OneHandedSwordAttack2", 2, 1, 0.1, true, false, 1)
    --localPlayer.Avatar:PlayAnimation("OneHandedSwordAttack2", 3, 1, 0.1, true, false, 1)
end

function OneHandedSwordAttack2:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    localPlayer:MoveTowards(Vector2.Zero)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle", "SwimIdle"})
end

function OneHandedSwordAttack2:OnLeave()
    PlayerActState.OnLeave(self)
end

return OneHandedSwordAttack2
