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

--- 开始倒计时
local startCD = 10

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
    print("[Snail] Init()")
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
        if this:IsBetable(_player) then
            NetUtil.Fire_C("InteractCEvent", _player, 8)
        else
            NetUtil.Fire_C("InsertInfoEvent", _player, "你不能多次投注或在比赛进行中投注", 3, true)
        end
    end
end

--- 检查是否可以投注
function Snail:IsBetable(_player)
    if gameState ~= snailGameState.WAIT then
        return false
    end
    for k1, v2 in pairs(snailObjPool) do
        for k2, v2 in pairs(v1.betPlayer) do
            if v2.player == _player then
                return false
            end
        end
    end
    return true
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

--- 开始倒计时
function Snail:StartRaceCD(dt)
    print(gameState)
    if this:IsStartRace() then
        if startCD <= 0 then
            startCD = 10
            this:StartSnailRace()
        else
            if startCD == 10 then
                NetUtil.Broadcast("InsertInfoEvent", "蜗牛赛跑竞猜10秒后就要开始啦，快来下注吧", 3)
            end
            startCD = startCD - dt
        end
    end
end

--- 开始比赛
function Snail:StartSnailRace()
    NetUtil.Broadcast("InsertInfoEvent", "蜗牛赛跑竞猜开始啦", 3)
    for k, v in pairs(snailObjPool) do
        this:InitMoveData(v)

        v.moveStep = 1
        v.obj.LinearVelocityController.TargetLinearVelocity = Vector3(0, 0, v.moveData[v.moveStep].speed)
        v.state = snailActState.MOVE
    end
    gameState = snailGameState.RACE
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
        print("[Snail]", _snailObjPool.obj, "到达终点")
        _snailObjPool.state = snailActState.FINISH
        _snailObjPool.obj.LinearVelocityController.TargetLinearVelocity = Vector3.Zero
        _snailObjPool.ranking = 0
        for k, v in pairs(snailObjPool) do
            if v.state == snailActState.FINISH then
                _snailObjPool.ranking = _snailObjPool.ranking + 1
            end
        end
        this:ShowRank(_snailObjPool)
        this:GiveReward(_snailObjPool)
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

--- 显示名次
function Snail:ShowRank(_snailObjPool)
    _snailObjPool.obj.SurfaceGUI:SetActive(true)
    _snailObjPool.obj.SurfaceGUI.Panel.RankText.Text = _snailObjPool.ranking
end

--- 发奖励
function Snail:GiveReward(_snailObjPool)
    local reward = 0
    if _snailObjPool.ranking == 2 then
        reward = 2
    elseif _snailObjPool.ranking == 1 then
        reward = 3
    end
    for k, v in pairs(_snailObjPool.betPlayer) do
        NetUtil.Fire_C("UpdateCoinEvent", v.player, v.money * reward)
        if _snailObjPool.ranking < 3 then
            NetUtil.Fire_C(
                "InsertInfoEvent",
                v.player,
                "你投注的蜗牛获得了第" .. _snailObjPool.ranking .. "名,为你赢得了" .. v.money * reward .. "金币",
                3,
                false
            )
        else
            NetUtil.Fire_C("InsertInfoEvent", v.player, "你投注的蜗牛获得了第" .. _snailObjPool.ranking .. "名,并没有奖励", 3, false)
        end

        --NetUtil.Fire_C("GetItemEvent", v, 5011)
    end
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
        v.obj.SurfaceGUI:SetActive(false)
    end
    gameState = snailGameState.WAIT
end

function Snail:Update(dt)
    this:StartRaceCD(dt)
    if gameState == snailGameState.RACE then
        this:SnailMove(dt)
    end
end

return Snail
