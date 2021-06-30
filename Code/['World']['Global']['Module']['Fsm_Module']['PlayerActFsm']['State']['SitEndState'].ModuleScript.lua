local SitState = class('SitState', PlayerActState)

function SitState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('anim_human_sit_end', 1, _stateName)
end
function SitState:InitData()
    self:AddTransition('ToIdleState', self.controller.states['IdleState'], 1)
end

function SitState:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer.FollowTarget = nil
    localPlayer.Rotation = EulerDegree(0, localPlayer.Rotation.y, 0)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.2, 0.2, true, false, 1)
end

function SitState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function SitState:OnLeave()
    PlayerActState.OnLeave(self)
end

return SitState
