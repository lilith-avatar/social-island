local BubleGunJump = class("BubleGunJump", PlayerActState)

function BubleGunJump:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer:Jump()
    localPlayer.Avatar:PlayAnimation("Jump", 2, 1, 0.1, true, false, 1)
end

function BubleGunJump:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"SwimIdle"})
    self:IdleMonitor()
end

function BubleGunJump:IdleMonitor()
    local dir = PlayerCtrl.finalDir
    dir.y = 0
    if dir.Magnitude > 0 then
        if PlayerCam:IsFreeMode() then
            localPlayer:FaceToDir(dir, 4 * math.pi)
        end
        localPlayer:MoveTowards(Vector2(dir.x, dir.z).Normalized)
    else
        localPlayer:MoveTowards(Vector2.Zero)
    end
end

function BubleGunJump:OnLeave()
    PlayerActState.OnLeave(self)
end

return BubleGunJump
