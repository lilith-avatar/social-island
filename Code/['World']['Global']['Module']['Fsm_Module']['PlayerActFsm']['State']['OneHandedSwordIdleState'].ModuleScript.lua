local OneHandedSwordIdle = class("OneHandedSwordIdle", PlayerActState)

function OneHandedSwordIdle:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer:MoveTowards(Vector2.Zero)
    localPlayer.GravityScale = 2
    localPlayer.Avatar:PlayAnimation("OneHandedSwordIdle", 2, 1, 0.1, true, true, 1)
    --localPlayer.Avatar:PlayAnimation("OneHandedSwordIdle", 3, 1, 0.1, true, true, 1)
end

function OneHandedSwordIdle:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle", "SwimIdle", "OneHandedSwordAttack1", "BowIdle", "TwoHandedSwordIdle"})
    self:MoveMonitor("OneHandedSword")
    self:JumpMonitor("OneHandedSword")
end

function OneHandedSwordIdle:OnLeave()
    PlayerActState.OnLeave(self)
end

return OneHandedSwordIdle
