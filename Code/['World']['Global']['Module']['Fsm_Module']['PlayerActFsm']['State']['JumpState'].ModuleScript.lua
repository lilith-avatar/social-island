local JumpState = class("JumpState", PlayerActState)

function JumpState:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer:Jump()
    --localPlayer.Avatar:PlayAnimation("Jump01_Boy", 2, 1, 0, true, false, 1)
    localPlayer.Avatar:PlayAnimation("Jump01_Boy", 4, 1, 0, true, false, 1)
end

function JumpState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"SwimIdle"})
end

function JumpState:JumpStateOnLeaveFunc()
    PlayerActState.OnLeave(self)
end

return JumpState
