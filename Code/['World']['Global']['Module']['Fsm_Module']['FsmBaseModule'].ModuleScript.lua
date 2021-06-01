--- 状态机基类
-- @module FsmBase
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
local FsmBase = class("FsmBase")

function FsmBase:initialize()
    --print("FsmBase:initialize()")
    self.states = {}
    self.stateEnum = {}
    self.stateTrigger = {}
    self.stateTriggerFunc = {}
    self.lastState = nil
    self.curState = nil
end

function FsmBase:DebugLog()
    --print("DebugLog()")
end

--向状态机添加状态
function FsmBase:AddState(_state)
    self.states[_state.stateName] = _state
    self.stateEnum[string.upper(_state.stateName)] = _state.stateName
    self.stateTrigger[_state.stateName] = false
    self.stateTriggerFunc[_state.stateName] = function()
        if self.stateTrigger[_state.stateName] then
            self:Switch(_state.stateName)
        end
    end
end

--初始化默认状态
function FsmBase:SetDefaultState(_stateName)
    self.curState = self.states[_stateName]
end

--更新当前状态
function FsmBase:Update(dt)
    if self.curState then
        if self.curState:TimeRunning(dt) then
            self.curState:OnUpdate(dt)
        else
            self:Switch(self.curState.nextState)
        end
    end
end

--切换状态
function FsmBase:Switch(_stateName)
    self.curState:OnLeave()
    self.lastState = self.curState
    self.curState = self.states[_stateName]
    self.curState:OnEnter()
end

--- 触发触发器
function FsmBase:ContactTrigger(_stateName)
    if self.curState.stateName ~= _stateName then
        self.stateTrigger[_stateName] = true
    end
end

--- 重置触发器
function FsmBase:ResetTrigger()
    for k, v in pairs(self.stateTrigger) do
        self.stateTrigger[k] = false
        --v = false
    end
end

--- 监听触发器
function FsmBase:TriggerMonitor(_stateNameTable)
    for k, v in pairs(_stateNameTable) do
        self.stateTriggerFunc[v]()
    end
end

--绑定所有状态function
function FsmBase:ConnectStateFunc(_statesT, _stateModuleFolder)
    for _, state in pairs(_statesT) do
        for _, module in pairs(_stateModuleFolder:GetChildren()) do
            if state.Name .. "State" == module.Name then
                local tempStateClass = require(module)
                local tempState = tempStateClass:new(state.Name, state.NextName, state.Dur)
                self:AddState(tempState)
                --print("绑定失败:" .. state.Name)
            end
        end
        --[[if
            _module[v.Name .. "StateOnEnterFunc"] and _module[v.Name .. "StateOnUpdateFunc"] and
                _module[v.Name .. "StateOnLeaveFunc"]
         then
            ----print("绑定成功:" .. v.Name)
            local tempState = StateBase:new(v.Name, v.NextName, v.Dur)
            tempState.OnEnter = function()
                self:ResetTrigger()
                _module[v.Name .. "StateOnEnterFunc"]()
            end
            tempState.OnUpdate = function(dt)
                _module[v.Name .. "StateOnUpdateFunc"](dt)
            end
            tempState.OnLeave = function()
                _module[v.Name .. "StateOnLeaveFunc"]()
            end
            self:AddState(tempState)]]
    end
    --self:SetDefaultState(ConstDef.PlayerActStateEnum.Idle)
end

return FsmBase
