local JumpState = class("JumpState", PlayerActState)

function JumpState:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer.Position = localPlayer.Position + Vector3(0, 0.5, 0)
    localPlayer.LinearVelocity = localPlayer.LinearVelocity + Vector3(0, localPlayer.JumpUpVelocity, 0)
    localPlayer.Avatar:PlayAnimation("Jump01_Boy", 2, 1, 0, true, false, 1)
    localPlayer.Avatar:PlayAnimation("Jump01_Boy", 3, 1, 0, true, false, 1)
end

function JumpState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle", "SwimIdle"})
    self:OnGroundMonitor()
end

function JumpState:JumpStateOnLeaveFunc()
    PlayerActState.OnLeave(self)
end

return JumpState
