local Vertigo = class("Vertigo", PlayerActState)

function Vertigo:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer:MoveTowards(Vector2.Zero)
    localPlayer.Avatar:PlayAnimation("ElectricShock", 2, 1, 0.1, true, true, 1)
end

function Vertigo:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"Jump"})
    localPlayer:MoveTowards(Vector2.Zero)
end

function Vertigo:OnLeave()
    PlayerActState.OnLeave(self)
end

return Vertigo
