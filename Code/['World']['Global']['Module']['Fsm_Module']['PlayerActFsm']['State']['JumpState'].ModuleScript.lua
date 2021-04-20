local JumpState = class("JumpState", PlayerActState)

function JumpState:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer:Jump()
	localPlayer.GravityScale = 2
    --localPlayer.Avatar:PlayAnimation("Jump01_Boy", 2, 1, 0, true, false, 1)
    localPlayer.Avatar:PlayAnimation("Jump01_Boy", 2, 1, 0, true, false, 1)
end

function JumpState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"Fly"})
    self:IdleMonitor()
end

function JumpState:IdleMonitor()
    local dir = PlayerCtrl.finalDir
    dir.y = 0
    if dir.Magnitude > 0 then
        if PlayerCam:IsFreeMode() then
            localPlayer:FaceToDir(dir, 4 * math.pi)
        end
        localPlayer:MoveTowards(Vector2(dir.x, dir.z))
    else
        localPlayer:MoveTowards(Vector2.Zero)
    end
end

function JumpState:JumpStateOnLeaveFunc()
    PlayerActState.OnLeave(self)
end

return JumpState
