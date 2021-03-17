local BubleGunIdle = class('BubleGunIdle',PlayerActState)

function BubleGunIdle:OnEnter()
    PlayerActState.OnEnter(self)
    --PlayerCam:SetCurCamEventHandler(PlayerCam.tpsCam)
    localPlayer:MoveTowards(Vector2.Zero)
    localPlayer.Avatar:PlayAnimation("PistolIdle", 2, 1, 0.1, true, true, 1)
end

function BubleGunIdle:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    localPlayer:MoveTowards(Vector2.Zero)
    FsmMgr.playerActFsm:TriggerMonitor(
        {"Idle", "SwimIdle", "OneHandedSwordIdle",'BubleGunVertigo'}
    )
    self:MoveMonitor('BubleGun')
    self:JumpMonitor('BubleGun')
end

function BubleGunIdle:OnLeave()
    PlayerActState.OnLeave(self)
end

return BubleGunIdle