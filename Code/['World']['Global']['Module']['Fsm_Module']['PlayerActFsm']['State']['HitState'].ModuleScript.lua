local HitState = class("HitState", PlayerActState)

function HitState:OnEnter()
    PlayerActState.OnEnter(self)
    --localPlayer.Avatar:PlayAnimation("HitFront", 2, 1, 0.1, true, true, 1)
    localPlayer.Avatar:PlayAnimation("HitForward", 2, 1, 0.1, true, true, 1)
end

function HitState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"SwimIdle"})
end
function HitState:OnLeave()
    PlayerActState.OnLeave(self)
end

return HitState
