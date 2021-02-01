local TwoHandedSwordJump = class("TwoHandedSwordJump", PlayerActState)

function TwoHandedSwordJump:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer:Jump()
    localPlayer.Avatar:PlayAnimation("TwoHandedSwordJump", 2, 1, 0, true, false, 1)
    --localPlayer.Avatar:PlayAnimation("TwoHandedSwordJump", 3, 1, 0, true, false, 1)
end

function TwoHandedSwordJump:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle","SwimIdle"})
end

function TwoHandedSwordJump:TwoHandedSwordJumpOnLeaveFunc()
    PlayerActState.OnLeave(self)
end

return TwoHandedSwordJump
