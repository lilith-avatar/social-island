local BowLandState = class('BowLandState', PlayerActState)

function BowLandState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('anim_man_jumptoidle_01', 1, _stateName .. 1, 1)
    PlayerAnimMgr:CreateSingleClipNode('anim_woman_jumptoidle_01', 1, _stateName .. 1, 2)
    PlayerAnimMgr:CreateSingleClipNode('anim_man_jumpforwardtorun_01', 1, _stateName .. 2, 1)
    PlayerAnimMgr:CreateSingleClipNode('anim_woman_jumpforwardtorun_01', 1, _stateName .. 2, 2)
end
function BowLandState:InitData()
    self:AddTransition(
        'ToIdleState',
        self.controller.states['IdleState'],
        -1,
        function()
            return self.controller.triggers['IdleState']
        end
    )
    self:AddTransition(
        'ToBowJumpBeginState',
        self.controller.states['BowJumpBeginState'],
        -1,
        function()
            return self.controller.triggers['BowJumpBeginState']
        end
    )
end

function BowLandState:OnEnter()
    PlayerActState.OnEnter(self)
    local dir = PlayerCtrl.finalDir
    dir.y = 0
    if dir.Magnitude > 0 then
        self:AddTransition('ToBowMoveState', self.controller.states['BowMoveState'], 0.4)
        PlayerAnimMgr:Play(self.stateName .. 2, 0, 1, 0.1, 0.1, true, false, 0.8)
    else
        self:AddTransition('ToBowIdleState', self.controller.states['BowIdleState'], 0.3)
        self:AddTransition(
            'ToBowMoveState',
            self.controller.states['BowMoveState'],
            -1,
            function()
                return self:MoveMonitor()
            end
        )
        PlayerAnimMgr:Play(self.stateName .. 1, 0, 1, 0.1, 0.1, true, false, 1)
    end
end

function BowLandState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    self:Move()
end

function BowLandState:OnLeave()
    PlayerActState.OnLeave(self)
    self.transitions = {}
end

return BowLandState
