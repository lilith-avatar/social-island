local SwimEndState = class('SwimEndState', PlayerActState)

function SwimEndState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('anim_human_sit_swim_goashore', 1, _stateName)
end

function SwimEndState:InitData()
    self:AddTransition('ToIdleState', self.controller.states['IdleState'], 0.8)
end

function SwimEndState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.2, 0.2, true, false, 1)
    local effect = world:CreateInstance('LandWater', 'LandWater', world, localPlayer.Position + Vector3(0, 1, 0))
    invoke(
        function()
            localPlayer:StopMovementImmediately()
            wait(0.5)
            effect:Destroy()
        end,
        0.3
    )
end

function SwimEndState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function SwimEndState:OnLeave()
    PlayerActState.OnLeave(self)
    localPlayer:SetSwimming(false)
    NetUtil.Fire_C('RemoveBuffEvent', localPlayer, 5)
end

return SwimEndState
