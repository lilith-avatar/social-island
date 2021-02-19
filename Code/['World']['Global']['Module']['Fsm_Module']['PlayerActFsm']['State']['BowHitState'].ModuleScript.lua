local BowHitState = class("BowHitState", PlayerActState)

function BowHitState:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer.Avatar:PlayAnimation("HitForward", 2, 1, 0.1, true, true, 1)
end

function BowHitState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"SwimIdle"})
end
function BowHitState:OnLeave()
    PlayerActState.OnLeave(self)
end

return BowHitState
