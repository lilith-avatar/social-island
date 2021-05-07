local IdleState = class("IdleState", PlayerActState)

function IdleState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerCam:SetCurCamEventHandler()
    localPlayer:MoveTowards(Vector2.Zero)
    localPlayer.GravityScale = 2
    localPlayer.Avatar.Position = localPlayer.Position
    --localPlayer.Avatar:PlayAnimation("Idle", 2, 1, 0.1, true, true, 1)
    if Data.Player.curEquipmentID == 0 then
        localPlayer.Avatar:PlayAnimation("Idle", 2, 1, 0.1, true, true, 1)
    elseif Config.Item[Data.Player.curEquipmentID].Type == 1 then
        localPlayer.Avatar:PlayAnimation("OneHandedSwordIdle", 2, 1, 0.1, true, true, 1)
    elseif Config.Item[Data.Player.curEquipmentID].Type == 4 then
        localPlayer.Avatar:PlayAnimation("ThrowIdle", 2, 1, 0.1, true, true, 1)
    end
end

function IdleState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor(
        {
            "SwimIdle",
            "Fly",
            "Vertigo",
            "Hit",
            "TakeOutItem",
            "UseItem",
            "BowIdle",
            "PistolIdle",
        }
    )
    self:MoveMonitor()
    self:JumpMonitor()
end

function IdleState:OnLeave()
    PlayerActState.OnLeave(self)
end

return IdleState
