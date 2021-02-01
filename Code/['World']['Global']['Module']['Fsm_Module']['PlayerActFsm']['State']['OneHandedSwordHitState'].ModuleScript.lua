local OneHandedSwordHitState = class("OneHandedSwordHitState", PlayerActState)

function OneHandedSwordHitState:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer.Avatar:PlayAnimation("HitForward", 2, 1, 0.1, true, true, 1)
end

function OneHandedSwordHitState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"SwimIdle"})
end
function OneHandedSwordHitState:OnLeave()
    PlayerActState.OnLeave(self)
end

return OneHandedSwordHitState
