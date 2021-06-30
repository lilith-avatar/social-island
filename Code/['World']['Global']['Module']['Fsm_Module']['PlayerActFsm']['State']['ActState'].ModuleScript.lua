local ActState = class('ActState', PlayerActState)

local isNext = false

function ActState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
end
function ActState:InitData()
end

function ActState:OnEnter()
    PlayerActState.OnEnter(self)
    if self.controller.actInfo.anim[2] ~= 'nil' then
        isNext = false
        local node =
            PlayerAnimMgr:CreateSingleClipNode(
            self.controller.actInfo.anim[2],
            self.controller.actInfo.speed,
            self.stateName
        )
        node.OnCompelete:Connect(
            function()
                isNext = true
            end
        )
        PlayerAnimMgr:Play(
            self.stateName,
            self.controller.actInfo.layer,
            1,
            self.controller.actInfo.transIn,
            self.controller.actInfo.transOut,
            self.controller.actInfo.isInterrupt,
            self.controller.actInfo.isLoop,
            self.controller.actInfo.speedScale
        )

        if self.controller.actInfo.dur[2] == 0 then
            self:AddTransition(
                'ToActEndState',
                self.controller.states['ActEndState'],
                -1,
                function()
                    return isNext or self:MoveMonitor() or self.controller.triggers['JumpBeginState']
                end
            )
        else
            self:AddTransition(
                'ToActEndState',
                self.controller.states['ActEndState'],
                self.controller.actInfo.dur[2],
                function()
                    return self:MoveMonitor() or self.controller.triggers['JumpBeginState']
                end
            )
        end
    else
        self:AddTransition('ToActEndState', self.controller.states['ActEndState'], 0.01)
    end
end

function ActState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function ActState:OnLeave()
    PlayerActState.OnLeave(self)
    self.transitions = {}
end

return ActState
