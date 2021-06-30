local ActBeginState = class('ActBeginState', PlayerActState)

local isNext = false

function ActBeginState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
end
function ActBeginState:InitData()
    self:AddAnyState(
        'ToActBeginState',
        -1,
        function()
            return self.controller.triggers['ActBeginState']
        end
    )
end

function ActBeginState:OnEnter()
    PlayerActState.OnEnter(self)
    if self.controller.actInfo.anim[1] ~= 'nil' then
        isNext = false
        local node = PlayerAnimMgr:CreateSingleClipNode(self.controller.actInfo.anim[1], 1, self.stateName)
        node.OnCompelete:Connect(
            function()
                isNext = true
            end
        )
        PlayerAnimMgr:Play(self.stateName, self.controller.actInfo.layer, 1, 0.2, 0.2, true, false, 1)
        if self.controller.actInfo.dur[1] == 0 then
            self:AddTransition(
                'ToActState',
                self.controller.states['ActState'],
                -1,
                function()
                    return isNext
                end
            )
        else
            self:AddTransition('ToActState', self.controller.states['ActState'], self.controller.actInfo.dur[1])
        end
    else
        self:AddTransition('ToActState', self.controller.states['ActState'], 0.01)
    end
end

function ActBeginState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function ActBeginState:OnLeave()
    PlayerActState.OnLeave(self)
    self.transitions = {}
end

return ActBeginState
