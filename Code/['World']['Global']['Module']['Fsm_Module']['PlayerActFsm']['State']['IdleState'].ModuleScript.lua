local IdleState = class("IdleState", PlayerActState)

function IdleState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerCam:SetCurCamEventHandler()
    localPlayer.Local.BowAimGUI:SetActive(false)
    localPlayer:MoveTowards(Vector2.Zero)
    localPlayer.GravityScale = 2
    localPlayer.Avatar.Position = localPlayer.Position
    --localPlayer.Avatar:PlayAnimation("Idle", 2, 1, 0.1, true, true, 1)
    localPlayer.Avatar:PlayAnimation("Idle", 2, 1, 0.1, true, true, 1)
end

function IdleState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor(
        {"SwimIdle", "Fly", "Hit", "BowIdle", "TwoHandedSwordIdle", "OneHandedSwordIdle", "MazeIdle"}
    )
    self:MoveMonitor()
    self:JumpMonitor()
end

function IdleState:OnLeave()
    PlayerActState.OnLeave(self)
end

return IdleState
