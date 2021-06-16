local BowJumpHighestState = class('BowJumpHighestState', PlayerActState)

function BowJumpHighestState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    local animsM = {
        {'anim_man_jumpforward_highest_01', 0.0, 1.0},
        {'anim_man_jumpforward_highest_02', 0.3, 1.0}
    }
    local animsW = {
        {'anim_woman_jumpforward_highest_01', 0.0, 1.0},
        {'anim_woman_jumpforward_highest_02', 0.3, 1.0}
    }
    PlayerAnimMgr:Create1DClipNode(animsM, 'speedXZ', _stateName, 1)
    PlayerAnimMgr:Create1DClipNode(animsW, 'speedXZ', _stateName, 2)
end
function BowJumpHighestState:InitData()
    self:AddTransition(
        'ToIdleState',
        self.controller.states['IdleState'],
        -1,
        function()
            return self.controller.triggers['IdleState']
        end
    )
    self:AddTransition('ToBowFallState', self.controller.states['BowFallState'], 0.5)
end

function BowJumpHighestState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.1, 0.1, true, false, 1)
end

function BowJumpHighestState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    self:Move()
    self:SpeedMonitor()
end

function BowJumpHighestState:OnLeave()
    PlayerActState.OnLeave(self)
end

return BowJumpHighestState
