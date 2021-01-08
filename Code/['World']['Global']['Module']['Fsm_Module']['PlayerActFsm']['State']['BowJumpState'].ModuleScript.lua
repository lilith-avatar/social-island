local BowJump = class("BowJump", PlayerActState)

function BowJump:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer.Avatar:PlayAnimation("BowJump", 3, 1, 0.1, true, false, 1)
end

function BowJump:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"BowIdle", "SwimIdle"})
    self:OnGroundMonitor("Bow")
end

function BowJump:OnLeave()
    PlayerActState.OnLeave(self)
end

return BowJump
