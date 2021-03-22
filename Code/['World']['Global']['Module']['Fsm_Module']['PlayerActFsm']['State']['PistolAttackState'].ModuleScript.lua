local PistolIdle = class("PistolIdle", PlayerActState)

function PistolIdle:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer:MoveTowards(Vector2.Zero)
    localPlayer.Avatar:PlayAnimation("PistolAttack", 8, 1, 0.1, true, false, 1)
    NetUtil.Fire_S('CreateBubleEvent',localPlayer)
end

function PistolIdle:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    localPlayer:MoveTowards(Vector2.Zero)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle", "SwimIdle", "PistolHit", "Vertigo"})
end

function PistolIdle:OnLeave()
    PlayerActState.OnLeave(self)
end

return PistolIdle
