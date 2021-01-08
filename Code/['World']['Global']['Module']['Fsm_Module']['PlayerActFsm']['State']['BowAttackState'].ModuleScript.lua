local BowAttack = class("BowAttack", PlayerActState)

function BowAttack:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer.Avatar:PlayAnimation("BowAttack", 2, 1, 0.1, true, false, 1)
    PlayerCtrl:PlayerArchery()
end

function BowAttack:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function BowAttack:OnLeave()
    PlayerActState.OnLeave(self)
end

return BowAttack
