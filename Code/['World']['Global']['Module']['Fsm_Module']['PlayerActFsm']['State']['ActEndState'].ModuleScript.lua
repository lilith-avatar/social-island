local ActEndState = class('ActEndState', PlayerActState)

local isNext = false
function ActEndState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
end
function ActEndState:InitData()
end

function ActEndState:AddActNextTransition(_dur, _func)
    local nextStateName = Config.PlayerActMode[self.controller.actAnimMode].ActNextState
    if nextStateName ~= '' then
        self:AddTransition('To' .. nextStateName, self.controller.states[nextStateName], _dur, _func)
    end
end

function ActEndState:OnEnter()
    PlayerActState.OnEnter(self)
    if self.controller.actInfo.anim[3] ~= 'nil' then
        isNext = false
        local node = PlayerAnimMgr:CreateSingleClipNode(self.controller.actInfo.anim[3], 1, self.stateName)
        node.OnCompelete:Connect(
            function()
                isNext = true
            end
        )
        PlayerAnimMgr:Play(self.stateName, self.controller.actInfo.layer, 1, 0.2, 0.2, true, false, 1)
        if self.controller.actInfo.dur[3] == 0 then
            self:AddActNextTransition(
                -1,
                function()
                    return isNext
                end
            )
        else
            self:AddActNextTransition(self.controller.actInfo.dur[3])
        end
    else
        self:AddActNextTransition(0.01)
    end
end

function ActEndState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end

function ActEndState:OnLeave()
    PlayerActState.OnLeave(self)
    self.transitions = {}
end

return ActEndState
