local FlyState = class("FlyState", PlayerActState)

function FlyState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerCtrl:SetPlayerControllableEventHandler(false)
    --localPlayer.Avatar:PlayAnimation("Flying", 2, 1, 0.1, true, true, 2)
    localPlayer.Avatar:PlayAnimation("Flying", 2, 1, 0.1, true, true, 2)
end

function FlyState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle", "SwimIdle"})
    self:OnGroundMonitor()
end

function FlyState:OnLeave()
    PlayerActState.OnLeave(self)
    localPlayer.Rotation = EulerDegree(0, localPlayer.Rotation.y, 0)
    PlayerCtrl:SetPlayerControllableEventHandler(true)
end

return FlyState
