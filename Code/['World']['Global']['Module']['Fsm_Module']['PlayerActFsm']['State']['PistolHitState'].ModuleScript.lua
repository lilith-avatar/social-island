local PistolHitState = class("PistolHitState", PlayerActState)

function PistolHitState:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer.Avatar:PlayAnimation("HitForward", 2, 1, 0.1, true, true, 1)
end

function PistolHitState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"SwimIdle"})
end
function PistolHitState:OnLeave()
    PlayerActState.OnLeave(self)
end

return PistolHitState
