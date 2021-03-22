local PistolJump = class("PistolJump", PlayerActState)

function PistolJump:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer:Jump()
    localPlayer.Avatar:PlayAnimation("Jump", 2, 1, 0.1, true, false, 1)
end

function PistolJump:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"SwimIdle"})
    self:IdleMonitor()
end

function PistolJump:IdleMonitor()
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

function PistolJump:OnLeave()
    PlayerActState.OnLeave(self)
end

return PistolJump
