local BowIdle = class("BowIdle", PlayerActState)

function BowIdle:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerCam:SetCurCamEventHandler(PlayerCam.tpsCam)
    invoke(
        function()
            localPlayer.Local.ControlGui:SetActive(true)
        end,
        0.5
    )
    NetUtil.Fire_C("SetDefUIEvent", localPlayer, false, {"Menu"})
    NetUtil.Fire_C("SetDefUIEvent", localPlayer, false, {"UseBtn"}, localPlayer.Local.ControlGui.Ctrl)
    localPlayer.Local.HuntGUI:SetActive(true)
    localPlayer:MoveTowards(Vector2.Zero)
    --localPlayer.Avatar:PlayAnimation("BowChargeIdle", 2, 1, 0.1, true, true, 1)
    localPlayer.Avatar:PlayAnimation("BowChargeIdle", 2, 1, 0.1, true, true, 1)
end

function BowIdle:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    localPlayer:MoveTowards(Vector2.Zero)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle", "SwimIdle", "BowAttack"})
    self:MoveMonitor("Bow")
    self:JumpMonitor("Bow")
end

function BowIdle:OnLeave()
    PlayerActState.OnLeave(self)
end

return BowIdle
