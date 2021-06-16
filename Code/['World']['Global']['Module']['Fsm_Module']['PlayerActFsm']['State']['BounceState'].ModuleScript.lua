local BounceState = class('BounceState', PlayerActState)

function BounceState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('anim_man_doublejump_01', 1, _stateName, 1)
    PlayerAnimMgr:CreateSingleClipNode('anim_woman_doublejump_01', 1, _stateName, 2)
end
function BounceState:InitData()
    self:AddAnyState(
        'ToBounceState',
        -1,
        function()
            return self.controller.triggers['BounceState']
        end
    )
    self:AddTransition(
        'ToFallState',
        self.controller.states['FallState'],
        -1,
        function()
            return self.controller.triggers['FallState']
        end
    )
    self:AddTransition(
        'ToBowFallState',
        self.controller.states['BowFallState'],
        -1,
        function()
            return self.controller.triggers['BowFallState']
        end
    )
    self:AddTransition('ToIdleState', self.controller.states['IdleState'], 2)
end

function BounceState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.1, 0.1, true, false, 1)
end

function BounceState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    if not self:FloorMonitor(0.5) and localPlayer.Velocity.y < 0.5 then
        self.controller:CallTrigger('FallState')
        self.controller:CallTrigger('BowFallState')
    end
end

function BounceState:OnLeave()
    PlayerActState.OnLeave(self)
end

return BounceState
