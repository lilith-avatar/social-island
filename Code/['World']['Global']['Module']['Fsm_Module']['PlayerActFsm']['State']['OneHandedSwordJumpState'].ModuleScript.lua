local OneHandedSwordJump = class("OneHandedSwordJump", PlayerActState)

function OneHandedSwordJump:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer:Jump()
    localPlayer.Avatar:PlayAnimation("OneHandedSwordJump", 2, 1, 0, true, false, 1)
    --localPlayer.Avatar:PlayAnimation("OneHandedSwordJump", 3, 1, 0, true, false, 1)
end

function OneHandedSwordJump:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle","SwimIdle"})
end

function OneHandedSwordJump:OneHandedSwordJumpOnLeaveFunc()
    PlayerActState.OnLeave(self)
end

return OneHandedSwordJump
