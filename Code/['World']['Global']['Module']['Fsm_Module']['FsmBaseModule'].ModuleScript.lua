--- 服务器端示例模块
-- @module Game Manager, Server-side
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
local FsmBase = class("FsmBase")

function FsmBase:initialize()
    print("FsmBase:initialize()")
    self.states = {}
    self.stateEnum = {}
    self.stateTrigger = {}
    self.lastState = nil
    self.curState = nil
end

--向状态机添加状态
function FsmBase:AddState(_state)
    self.states[_state.stateName] = _state
    self.stateEnum[string.upper(_state.stateName)] = _state.stateName
    self.stateTrigger[_state.stateName] = false
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
        v = false
    end
end

--- 监听触发器
function FsmBase:TriggerMonitor(_stateNameTable)
    for k, v in pairs(_stateNameTable) do
        if self.stateTrigger[v] then
            self:Switch(v)
        end
    end
end

--绑定所有状态function
function FsmBase:ConnectStateFunc(_statesT, _module)
    for k, v in pairs(_statesT) do
        if
            _module[v.Name .. "StateOnEnterFunc"] and _Fmodule[v.Name .. "StateOnUpdateFunc"] and
                _module[v.Name .. "StateOnLeaveFunc"]
         then
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
            self:AddState(tempState)
        else
            print("not exit interface:" .. v.Name)
        end
    end
    --self:SetDefaultState(ConstDef.PlayerActStateEnum.Idle)
end

return FsmBase
