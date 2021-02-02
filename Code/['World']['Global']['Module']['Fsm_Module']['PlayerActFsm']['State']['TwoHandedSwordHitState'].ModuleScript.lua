local TwoHandedSwordHitState = class("TwoHandedSwordHitState", PlayerActState)

function TwoHandedSwordHitState:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer.Avatar:PlayAnimation("HitForward", 2, 1, 0.1, true, true, 1)
end

function TwoHandedSwordHitState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"SwimIdle"})
end
function TwoHandedSwordHitState:OnLeave()
    PlayerActState.OnLeave(self)
end

return TwoHandedSwordHitState
