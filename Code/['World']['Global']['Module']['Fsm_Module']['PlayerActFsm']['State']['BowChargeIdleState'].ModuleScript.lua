local BowChargeIdle = class("BowChargeIdle", PlayerActState)

function BowChargeIdle:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer:MoveTowards(Vector2.Zero)
    localPlayer.Avatar:PlayAnimation("BowChargeIdle", 2, 1, 0.1, true, true, 1)
end

function BowChargeIdle:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    localPlayer:MoveTowards(Vector2.Zero)
    if not GuiBowAim.gui.ActiveSelf then
        GuiBowAim.gui:SetActive(true)
    end
    if not localPlayer.Local.ControlGui.Joystick.ActiveSelf then
        localPlayer.Local.ControlGui.Joystick:SetActive(false)
    end
    FsmMgr.playerActFsm:TriggerMonitor({"Idle", "BowHit", "SwimIdle", "BowAttack"})
end

function BowChargeIdle:OnLeave()
    PlayerActState.OnLeave(self)
end

return BowChargeIdle
