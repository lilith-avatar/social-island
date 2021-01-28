local HammerAttack = class("HammerAttack", PlayerActState)

function HammerAttack:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerCtrl:SetPlayerControllableEventHandler(false)
    -- Todo:播放动作
end

function HammerAttack:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function HammerAttack:OnLeave()
    PlayerActState.OnLeave(self)
    PlayerCtrl:SetPlayerControllableEventHandler(true)
end

return HammerAttack