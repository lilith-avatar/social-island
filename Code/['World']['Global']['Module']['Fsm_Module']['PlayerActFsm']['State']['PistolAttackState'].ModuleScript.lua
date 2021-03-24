local PistolIdle = class("PistolIdle", PlayerActState)

function PistolIdle:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer:MoveTowards(Vector2.Zero)
end

function PistolIdle:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    localPlayer:MoveTowards(Vector2.Zero)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle", "PistolIdle", "SwimIdle", "PistolHit", "Vertigo"})
end

function PistolIdle:OnLeave()
    PlayerActState.OnLeave(self)
end

return PistolIdle
