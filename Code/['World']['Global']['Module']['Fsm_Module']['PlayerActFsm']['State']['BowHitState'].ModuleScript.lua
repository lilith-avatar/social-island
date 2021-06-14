local BowHitState = class('BowHitState', PlayerActState)

function BowHitState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('HitForward', 1, _stateName)
end

function BowHitState:InitData()
    self:AddTransition('ToBowIdleState', self.controller.states['BowIdleState'], 0.5)
end

function BowHitState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.2, 0.2, true, true, 1)
end

function BowHitState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end
function BowHitState:OnLeave()
    PlayerActState.OnLeave(self)
end

return BowHitState
