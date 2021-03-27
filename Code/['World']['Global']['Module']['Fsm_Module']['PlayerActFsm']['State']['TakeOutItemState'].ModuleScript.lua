local TakeOutItemState = class("TakeOutItemState", PlayerActState)

function TakeOutItemState:OnEnter()
    PlayerActState.OnEnter(self)
end

function TakeOutItemState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor(
        {
            "Idle",
            "Walk",
            "Run",
            "Jump",
            "Vertigo",
            "Fly",
            "Hit",
            "SwimIdle",
            "Swimming",
            "TakeOutItem",
            "UseItem",
            "BowIdle",
            "BowWalk",
            "BowRun",
            "BowJump",
            "BowChargeIdle",
            "BowAttack",
            "BowHit",
            "PistolIdle",
            "PistolRun",
            "PistolWalk",
            "PistolJump",
            "PistolAttack",
            "PistolHit"
        }
    )
end
function TakeOutItemState:OnLeave()
    PlayerActState.OnLeave(self)
end

return TakeOutItemState
