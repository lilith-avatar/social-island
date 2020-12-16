--- 蜗牛菠菜交互模块
--- @module Snail Module
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local Snail, this = ModuleUtil.New("Snail", ServerBase)

--- 变量声明
-- 蜗牛对象池
local snailObjPool = {}

-- 起点
local startPoints = {}

-- 终点
local endPoints = {}

-- 蜗牛运动状态枚举
local snailActState = {
    READY = 1,
    MOVE = 2,
    FINISH = 3
}

-- 游戏状态枚举
local snailGameState = {
    WAIT = 1,
    CD = 2,
    RACE = 3
}

-- 游戏状态
local gameState = 1

--- 初始化
function Snail:Init()
    print("Snail:Init")
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--- 节点引用
function Snail:NodeRef()
    for i = 1, 4 do
        snailObjPool[i] = {
            obj = world.MiniGames.Game_08_Snail.Snail["Snail" .. i],
            index = i,
            state = 1,
            moveData = {},
            moveStep = 0,
            betPlayer = {},
            ranking = 0
        }
        startPoints[i] = world.MiniGames.Game_08_Snail.Track["Start" .. i]
        endPoints[i] = world.MiniGames.Game_08_Snail.Track["End" .. i]
    end
end

--- 数据变量初始化
function Snail:DataInit()
end

--- 节点事件绑定
function Snail:EventBind()
    for k, v in pairs(snailObjPool) do
        v.obj.OnCollisionBegin:Connect(
            function(_hitObject)
                if _hitObject == endPoints[v.index] then
                    this:SnailFinish(v)
                end
            end
        )
    end
end

--- 节点事件绑定
function Snail:EnterMiniGameEventHandler(_player, _gameId)
    if _gameId == 8 then
        this:StartSnailRace()
    end
end

--- 投注
function Snail:SnailBetEventHandler(_player, _index, _money)
    snailObjPool[_index].betPlayer[#snailObjPool[_index].betPlayer + 1] = {
        player = _player,
        money = _money
    }
end

--- 检查是否开始
function Snail:IsStartRace()
    if gameState == snailGameState.WAIT then
        for k, v in pairs(snailObjPool) do
            if #v.betPlayer > 0 then
                return true
            end
        end
    end
    return false
end

--- 开始比赛
function Snail:StartSnailRace()
    for k, v in pairs(snailObjPool) do
        this:InitMoveData(v)

        v.moveStep = 1
        v.obj.LinearVelocityController.TargetLinearVelocity = Vector3(0, 0, v.moveData[v.moveStep].speed)
        v.state = snailActState.MOVE
    end
    this.gameState = snailGameState.RACE
end

--- 生成移动数据
function Snail:InitMoveData(_snailObjPool)
    local disTable = {}
    local add = 0
    for i = 1, 4 do
        disTable[i] = math.random(0, math.floor(10 * (8 - add))) / 10
        add = add + disTable[i]
        if add > 7.6 or i == 4 then
            disTable[i + 1] = 8 - add
            break
        end
    end
    local tempTime = 0
    for i = 1, #disTable do
        tempTime = 20 + math.random(-150, 150) / 10
        _snailObjPool.moveData[i] = {
            time = tempTime,
            speed = disTable[i] / tempTime
        }
    end
    --print(table.dump(_snailObjPool.moveData))
end

--- 蜗牛移动
function Snail:SnailMove(dt)
    for k, v in pairs(snailObjPool) do
        if v.state == snailActState.MOVE then
            if v.moveData[v.moveStep].time <= 0 then
                v.moveStep = v.moveStep + 1
                if v.moveStep > #v.moveData then
                    this:SnailFinish(v)
                else
                    --print(v.obj, "改变速度", v.moveData[v.moveStep].speed)
                    v.obj.LinearVelocityController.TargetLinearVelocity = Vector3(0, 0, v.moveData[v.moveStep].speed)
                end
            else
                v.moveData[v.moveStep].time = v.moveData[v.moveStep].time - dt
            end
        end
    end
end

--- 蜗牛到达终点
function Snail:SnailFinish(_snailObjPool)
    if _snailObjPool.state == snailActState.MOVE then
        print(_snailObjPool.obj, "到达终点")
        _snailObjPool.state = snailActState.FINISH
        _snailObjPool.obj.LinearVelocityController.TargetLinearVelocity = Vector3.Zero
        _snailObjPool.ranking = 1
        for k, v in pairs(snailObjPool) do
            if v.state == snailActState.FINISH then
                _snailObjPool.ranking = _snailObjPool.ranking + 1
            end
        end
        if this:IsResetRace() then
            invoke(
                function()
                    this:ResetSnailRace()
                end,
                2
            )
        end
    end
    --_snailObjPool.obj.Position = startPoints[_snailObjPool.index].Position
end

--- 检查是否重置
function Snail:IsResetRace()
    local bool = true
    for k, v in pairs(snailObjPool) do
        if v.state ~= snailActState.FINISH then
            bool = false
            break
        end
    end
    return bool
end

--- 重置游戏
function Snail:ResetSnailRace()
    for k, v in pairs(snailObjPool) do
        v.ranking = 0
        v.state = snailActState.READY
        v.moveStep = 0
        v.moveData = {}
        v.betPlayer = {}
        v.obj.Position = startPoints[v.index].Position
    end
end

function Snail:Update(dt)
    if this.gameState == snailGameState.RACE then
        this:SnailMove(dt)
    end
end

return Snail
