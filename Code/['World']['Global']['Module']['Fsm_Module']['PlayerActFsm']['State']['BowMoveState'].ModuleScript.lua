local BowMoveState = class('BowMoveState', PlayerActState)

local speedScale = 1
local curSpeedScale = 1

function BowMoveState:initialize(_controller, _stateName)
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
    PlayerAnimMgr:Create1DClipNode(animsM, 'speedXZ', _stateName, 1)
    PlayerAnimMgr:Create1DClipNode(animsW, 'speedXZ', _stateName, 2)
end

function BowMoveState:InitData()
    self:AddTransition(
        'ToIdleState',
        self.controller.states['IdleState'],
        -1,
        function()
            return self.controller.triggers['IdleState']
        end
    )
    self:AddTransition(
        'ToBowIdleState',
        self.controller.states['BowIdleState'],
        -1,
        function()
            return not self:MoveMonitor()
        end
    )
    self:AddTransition(
        'ToBowChargeState',
        self.controller.states['BowChargeState'],
        -1,
        function()
            return self.controller.triggers['BowChargeState']
        end
    )
    --[[self:AddTransition(
        'ToBowHitState',
        self.controller.states['BowHitState'],
        -1,
        function()
            return self.controller.triggers['BowHitState']
        end
    )]]
    self:AddTransition(
        'ToBowJumpBeginState',
        self.controller.states['BowJumpBeginState'],
        -1,
        function()
            return self.controller.triggers['BowJumpBeginState']
        end
    )
end

function BowMoveState:OnEnter()
    PlayerActState.OnEnter(self)
    curSpeedScale = localPlayer.MaxWalkSpeed / 12
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.2, 0.2, true, true, curSpeedScale)
end

function BowMoveState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    self:SpeedMonitor()
    self:Move()
    self:FallMonitor()
    speedScale = localPlayer.MaxWalkSpeed / 12
    if curSpeedScale ~= speedScale then
        curSpeedScale = speedScale
        PlayerAnimMgr:Play(self.stateName, 0, 1, 0.2, 0.2, true, true, curSpeedScale)
    end
end

function BowMoveState:OnLeave()
    PlayerActState.OnLeave(self)
end

return BowMoveState
