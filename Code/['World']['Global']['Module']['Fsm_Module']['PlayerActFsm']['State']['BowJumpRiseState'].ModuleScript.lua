local BowJumpRiseState = class('BowJumpRiseState', PlayerActState)

function BowJumpRiseState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    local animsM = {
        {'anim_man_jump_riseuploop_01', 0.0, 1.0},
        {'anim_man_jumpforward_riseuploop_02', 0.5, 1.0}
    }
    local animsW = {
        {'anim_woman_jump_riseuploop_01', 0.0, 1.0},
        {'anim_woman_jumpforward_riseuploop_02', 0.5, 1.0}
    }
    PlayerAnimMgr:Create1DClipNode(animsM, 'speedXZ', _stateName, 1)
    PlayerAnimMgr:Create1DClipNode(animsW, 'speedXZ', _stateName, 2)
end

function BowJumpRiseState:InitData()
    self:AddTransition(
        'ToIdleState',
        self.controller.states['IdleState'],
        -1,
        function()
            return self.controller.triggers['IdleState']
        end
    )
    self:AddTransition('ToBowJumpHighestState', self.controller.states['BowJumpHighestState'], 0.2)
end

function BowJumpRiseState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.1, 0.1, true, true, 1)
end

function BowJumpRiseState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    self:FallMonitor()
    self:Move()
    self:SpeedMonitor()
end

---移动
function BowJumpRiseState:Move()
    local dir = PlayerCtrl.finalDir
    dir.y = 0
    if dir.Magnitude > 0 then
        localPlayer:AddMovementInput(dir, 0.5)
    end
end

function BowJumpRiseState:OnLeave()
    PlayerActState.OnLeave(self)
end

return BowJumpRiseState
