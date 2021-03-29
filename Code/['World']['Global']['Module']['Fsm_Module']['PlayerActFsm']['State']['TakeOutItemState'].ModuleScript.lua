local TakeOutItemState = class("TakeOutItemState", PlayerActState)

function TakeOutItemState:OnEnter()
    PlayerActState.OnEnter(self)
end

function TakeOutItemState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor(
        {
            "Idle",
            "TakeOutItem",
            "UseItem",
            "BowIdle",
            "PistolIdle",
        }
    )
end
function TakeOutItemState:OnLeave()
    PlayerActState.OnLeave(self)
end

return TakeOutItemState
