local FallState = class('FallState', PlayerActState)

function FallState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    local animsM = {
        {'anim_man_jump_falldownloop_01', 0.0, 1.0},
        {'anim_man_jumpforward_falldownloop_02', 0.5, 1.0}
    }
    local animsW = {
        {'anim_woman_jump_falldownloop_01', 0.0, 1.0},
        {'anim_woman_jumpforward_falldownloop_02', 0.5, 1.0}
    }
    PlayerAnimMgr:Create1DClipNode(animsM, 'speedXZ', _stateName, 1)
    PlayerAnimMgr:Create1DClipNode(animsM, 'speedXZ', _stateName, 2)
end
function FallState:InitData()
    self:AddTransition(
        'ToLandState',
        self.controller.states['LandState'],
        -1,
        function()
            return localPlayer.IsOnGround
        end
    )
end

function FallState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.1, 0.1, true, true, 1)
end

function FallState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    self:Move()
    self:SpeedMonitor()
end

function FallState:OnLeave()
    PlayerActState.OnLeave(self)
end

return FallState
