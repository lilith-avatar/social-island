--- 服务器端示例模块
-- @module Game Manager, Server-side
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
local StateBase = class("StateBase")

function StateBase:initialize(_stateName, _nextStateName, _time)
    self.stateName = _stateName
    self.nextState = _nextStateName
    self.stateTime = _time or 0
    self.curTime = 0
end

--时间运行
function StateBase:TimeRunning(dt)
    if self.stateTime ~= 0 then ---有限时间状态
        if self.curTime < self.stateTime then
            self.curTime = self.curTime + dt
            return true ---状态时间未结束返回true
        else
            self.curTime = 0
            return false ---状态时间结束返回false
        end
    else ---无限时间状态
        return true
    end
end

--进入状态
function StateBase:OnEnter()
    print("进入" .. self.stateName)
end

--更新状态
function StateBase:OnUpdate(dt)
    print("更新" .. self.stateName)
end

--离开状态
function StateBase:OnLeave()
    print("离开" .. self.stateName)
end

return StateBase
