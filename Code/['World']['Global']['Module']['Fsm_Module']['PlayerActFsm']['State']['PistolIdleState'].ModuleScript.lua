local PistolIdle = class("PistolIdle", PlayerActState)

function PistolIdle:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerCam:SetCurCamEventHandler(PlayerCam.tpsCam)
    localPlayer:MoveTowards(Vector2.Zero)
    localPlayer.Avatar:PlayAnimation("PistolIdle", 2, 1, 0.1, true, true, 1)
end

function PistolIdle:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    localPlayer:MoveTowards(Vector2.Zero)
    FsmMgr.playerActFsm:TriggerMonitor(
        {"Idle", "SwimIdle", "OneHandedSwordIdle", "PistolAttack", "PistolHit", "Vertigo"}
    )
    self:MoveMonitor("Pistol")
    self:JumpMonitor("Pistol")
end

function PistolIdle:OnLeave()
    PlayerActState.OnLeave(self)
end

return PistolIdle
