--- 热气球交互模块
--- @module Zeppelin Module
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local Zeppelin, this = ModuleUtil.New("Zeppelin", ServerBase)

--- 变量声明
-- 热气球对象池
local zeppelinObjPool = {}

-- 站台等待乘客表
local platformPassengerTable = {}

-- 入口区域
local entranceArea = nil

-- 站台区域
local platformArea = {}

-- 出口区域
local exitArea = nil

-- 移动路径表
local pathwayPointTable = {}

-- 出发间隔
local departureInterval = 5

-- 热气球移动速度
local zeppelinMoveSpeed = 5

-- 计时器
local timer = {}

-- 热气球状态枚举
local zeppelinStateEnum = {
    UNABLE = 0,
    READY = 1,
    MOVING = 2,
    RESET = 3
}

--- 初始化
function Zeppelin:Init()
    print("Zeppelin:Init")
    this:NodeRef()
    this:DataInit()
    this:EventBind()
    for i = 1, 3 do
        this:ZeppelinMoveAround(zeppelinObjPool[i])
    end
end

--- 节点引用
function Zeppelin:NodeRef()
    for i = 1, 3 do
        zeppelinObjPool[i] = {
            obj = world.Zeppelin.ZeppelinObj["Zeppelin_" .. i],
            passenger = {},
            state = zeppelinStateEnum.UNABLE,
            moveStep = 0
        }
        platformPassengerTable[i] = world.Zeppelin.Station["Platform_0" .. i]
    end
    entranceArea = world.Zeppelin.Station.Entrance
    exitArea = world.Zeppelin.Station.Exit
end

--- 数据变量初始化
function Zeppelin:DataInit()
    for i = 1, #world.Zeppelin.PathwayPoint:GetChildren() do
        pathwayPointTable[i] = world.Zeppelin.PathwayPoint["P" .. i].Position
    end

    zeppelinObjPool[1].state = zeppelinStateEnum.READY
    zeppelinObjPool[1].moveStep = #pathwayPointTable
    zeppelinObjPool[2].state = zeppelinStateEnum.RESET
    zeppelinObjPool[2].moveStep = #pathwayPointTable - 1
    zeppelinObjPool[3].state = zeppelinStateEnum.RESET
    zeppelinObjPool[3].moveStep = #pathwayPointTable - 2

    timer = {
        tick = 0,
        second = 0 -- 秒
    }
end

--- 节点事件绑定
function Zeppelin:EventBind()
    entranceArea.OnCollisionBegin:Connect(
        function(_hitObject)
            if _hitObject.ClassName == "PlayerInstance" then
                this:GetOnZeppelin(_hitObject)
            end
        end
    )
end

--- 进入热气球
function Zeppelin:GetOnZeppelin(_player)
    for k, v in pairs(zeppelinObjPool) do
        if v.state == zeppelinStateEnum.READY then
            v.passenger[_player.UserId] = _player
            _player.Position = v.obj.Seat.Position
        end
    end
end

--- 离开热气球
function Zeppelin:LeaveZeppelinEventHandler(_player)
    for k1, v1 in pairs(zeppelinObjPool) do
        for k2, v2 in pairs(v1.passenger) do
            if v2 == _player then
                v1.passenger[_player.UserId] = nil
                _player.Position = v1.obj.Position + Vector3(0, -2, 0)
            end
        end
    end
end

--- 在站台等待的玩家进入热气球
function Zeppelin:WaitingPassengerGetOn()
    for k, v in pairs(world:FindPlayers()) do
        if (v.Position - entranceArea.Position).Magnitude < 1.2 then
            this:GetOnZeppelin(v)
        end
    end
end

--- 丢弃全部乘客
function Zeppelin:ThrowAwayAllPassenger(_zeppelin)
    for k, v in pairs(_zeppelin.passenger) do
        this:LeaveZeppelinEventHandler(v)
    end
end

--- 热气球向一个点移动
function Zeppelin:ZeppelinMoveToPoint(_zeppelin, _dest)
    _zeppelin.obj.LinearVelocity = (_dest - _zeppelin.obj.Position).Normalized * zeppelinMoveSpeed
    return ((_dest - _zeppelin.obj.Position).Magnitude) / zeppelinMoveSpeed
end

--- 热气球移动环绕一周
function Zeppelin:ZeppelinMoveAround(_zeppelin)
    local moveTime = this:ZeppelinMoveToPoint(_zeppelin, pathwayPointTable[_zeppelin.moveStep % #pathwayPointTable + 1])
    invoke(
        function()
            _zeppelin.moveStep = _zeppelin.moveStep % #pathwayPointTable + 1
            this:ZeppelinSwitchState(_zeppelin)
            this:ZeppelinMoveAround(_zeppelin)
        end,
        moveTime
    )
end

--- 热气球状态切换
function Zeppelin:ZeppelinSwitchState(_zeppelin)
    if _zeppelin.state == zeppelinStateEnum.READY and _zeppelin.moveStep == 1 then
        _zeppelin.state = zeppelinStateEnum.MOVING
        return
    end
    if _zeppelin.state == zeppelinStateEnum.MOVING and _zeppelin.moveStep == 4 then
        _zeppelin.state = zeppelinStateEnum.RESET
        this:ThrowAwayAllPassenger(_zeppelin)
        _zeppelin.obj.LinearVelocity = Vector3.Zero
        wait(departureInterval)
        return
    end
    if _zeppelin.state == zeppelinStateEnum.RESET then
        if _zeppelin.moveStep == 6 then
            _zeppelin.state = zeppelinStateEnum.READY
            this:WaitingPassengerGetOn()
        end
        _zeppelin.obj.LinearVelocity = Vector3.Zero
        wait(departureInterval)
        return
    end
end

--- 计时器运行
function Zeppelin:timerRunning(dt)
    if timer.tick >= 1 then
        -- 每秒触发逻辑
        timer.tick = 0
        timer.second = timer.second + 1
    end
    timer.tick = timer.tick + dt
end

function Zeppelin:Update(dt)
    this:timerRunning(dt)
end

return Zeppelin
