local HitState = class('HitState', PlayerActState)

function HitState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('HitForward', 1, _stateName)
end

function HitState:InitData()
    self:AddTransition('ToIdleState', self.controller.states['IdleState'], 0.5)
    self:AddAnyState(
        'ToHitState',
        -1,
        function()
            return self.controller.triggers['HitState']
        end
    )
end

function HitState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.2, 0.2, true, true, 1)
end

function HitState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end
function HitState:OnLeave()
    PlayerActState.OnLeave(self)
end

return HitState
