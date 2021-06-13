local BowIdleState = class('BowIdleState', PlayerActState)

function BowIdleState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    local animsM = {
        {'anim_man_idle_01', 0.0, 1.0},
        {'anim_man_walkfront_01', 0.25, 1.0},
        {'anim_man_runfront_01', 0.5, 1.0},
        {'anim_man_sprint_01', 1, 1.0}
    }

    local animsW = {
        {'anim_woman_idle_01', 0.0, 1.0},
        {'anim_woman_walkfront_01', 0.25, 1.0},
        {'anim_woman_runfront_01', 0.5, 1.0},
        {'anim_woman_sprint_01', 1, 1.0}
    }
    PlayerAnimMgr:Create1DClipNode(animsM, 'speedXZ', _stateName .. 'LowerBody', 1)
    PlayerAnimMgr:Create1DClipNode(animsW, 'speedXZ', _stateName .. 'LowerBody', 2)
    PlayerAnimMgr:CreateSingleClipNode('BowChargeIdle', 1, _stateName .. 'UpperBody')
end

function BowIdleState:InitData()
    self:AddTransition(
        'ToIdleState',
        self.controller.states['IdleState'],
        -1,
        function()
            return self.controller.triggers['IdleState']
        end
    )
    self:AddTransition(
        'ToBowHitState',
        self.controller.states['BowHitState'],
        -1,
        function()
            return self.controller.triggers['BowHitState']
        end
    )
    self:AddTransition(
        'ToBowAttackState',
        self.controller.states['BowAttackState'],
        -1,
        function()
            return self.controller.triggers['BowAttackState']
        end
    )
end

function BowIdleState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName .. 'UpperBody', 1, 1, 0.2, 0.2, true, true, 1)
    PlayerAnimMgr:Play(self.stateName .. 'LowerBody', 2, 1, 0.2, 0.2, true, true, 1)
end

function BowIdleState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    self:SpeedMonitor()
    self:Move()
    self:FallMonitor()
end

function BowIdleState:OnLeave()
    PlayerActState.OnLeave(self)
end

return BowIdleState
