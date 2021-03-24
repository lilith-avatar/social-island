local RunState = class("RunState", PlayerActState)

function RunState:OnEnter()
    PlayerActState.OnEnter(self)
    --localPlayer.Avatar:PlayAnimation("RunFront", 2, 1, 0.1, true, true, 1)
    localPlayer.Avatar:PlayAnimation("RunFront", 2, 1, 0.1, true, true, 1)
    if ItemMgr.curEquipmentID == 0 then
        localPlayer.Avatar:PlayAnimation("RunFront", 2, 1, 0.1, true, true, 1)
    elseif Config.Item[ItemMgr.curEquipmentID].Type == 1 then
        localPlayer.Avatar:PlayAnimation("OneHandedSwordRun", 2, 1, 0.1, true, true, 1)
    elseif Config.Item[ItemMgr.curEquipmentID].Type == 4 then
        localPlayer.Avatar:PlayAnimation("Jogging", 2, 1, 0.1, true, true, 1)
    end
end

function RunState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor(
        {
            "Idle",
            "Hit",
            "SwimIdle",
            "Fly",
            "Vertigo",
            "TakeOutItem",
            "UseItem"
        }
    )
    self:IdleMonitor()
    self:WalkMonitor()
    self:JumpMonitor()
end
function RunState:OnLeave()
    PlayerActState.OnLeave(self)
end

return RunState
