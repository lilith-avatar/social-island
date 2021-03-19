local BubleGunVertigo = class("BubleGunVertigo", PlayerActState)

function BubleGunVertigo:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer:MoveTowards(Vector2.Zero)
    localPlayer.Avatar:PlayAnimation("ElectricShock", 2, 1, 0.1, true, true, 1)
end

function BubleGunVertigo:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"Jump"})
    localPlayer:MoveTowards(Vector2.Zero)
end

function BubleGunVertigo:OnLeave()
    PlayerActState.OnLeave(self)
end

return BubleGunVertigo
