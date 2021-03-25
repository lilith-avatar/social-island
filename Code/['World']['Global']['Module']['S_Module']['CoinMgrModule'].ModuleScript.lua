--- 金币管理模块
--- @module CoinMgr Module
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local CoinMgr, this = ModuleUtil.New("CoinMgr", ServerBase)

--- 变量声明
--金币对象池
local coinPool = {
    N1 = {},
    P1 = {},
    N10 = {},
    P10 = {},
    N100 = {},
    P100 = {},
    N1000 = {},
    P1000 = {}
}

--- 初始化
function CoinMgr:Init()
    print("[CoinMgr] Init()")
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--- 节点引用
function CoinMgr:NodeRef()
end

--- 数据变量初始化
function CoinMgr:DataInit()
    CoinMgr:InitCoinPool(40)
end

--- 节点事件绑定
function CoinMgr:EventBind()
end

--- 初始化对象池
function CoinMgr:InitCoinPool(_amount)
    coinPool.N1 = ObjPoolUtil.Newpool(world.Coin, "Coin1_N", _amount)
    coinPool.P1 = ObjPoolUtil.Newpool(world.Coin, "Coin1_P", _amount)
    coinPool.N10 = ObjPoolUtil.Newpool(world.Coin, "Coin10_N", _amount)
    coinPool.P10 = ObjPoolUtil.Newpool(world.Coin, "Coin10_P", _amount)
    coinPool.N100 = ObjPoolUtil.Newpool(world.Coin, "Coin100_N", _amount)
    coinPool.P100 = ObjPoolUtil.Newpool(world.Coin, "Coin100_P", _amount)
    coinPool.N1000 = ObjPoolUtil.Newpool(world.Coin, "Coin1000_N", _amount)
    coinPool.P1000 = ObjPoolUtil.Newpool(world.Coin, "Coin1000_P", _amount)
end

--- 刷新一个金币
function CoinMgr:SpawnCoin(_pool, _pos)
    local coinOBJ = coinPool[_pool]:Spawn(_pos)
    if string.sub(_pool, 1, 1) == "P" then
        coinOBJ.LinearVelocity = Vector3(math.random(-5, 5), 5, math.random(-5, 5))
        coinOBJ.Rotation = EulerDegree(90, math.random(0, 180), 0)
    end
    coinOBJ.GetCoinEvent:Connect(
        function()
            this:GetCoin(_pool, coinOBJ)
        end
    )
    return coinOBJ
end

--- 获得金币
function CoinMgr:GetCoin(_pool, _coinOBJ)
    _coinOBJ.Block = false
    --NetUtil.Fire_C("PlayEffectEvent", localPlayer, 4)
    NetUtil.Fire_C("UpdateCoinEvent", world:GetPlayerByUserId(_coinOBJ.CoinUID.Value), _coinOBJ.CoinNum.Value)
    invoke(
        function()
            _coinOBJ.LinearVelocity =
                (world:GetPlayerByUserId(_coinOBJ.CoinUID.Value).Position + Vector3(0, 1, 0) - _coinOBJ.Position).Normalized *
                10
            wait(0.12)
            if string.sub(_pool, 1, 1) == "P" then
                _coinOBJ.Block = true
            end
            coinPool[_pool]:Despawn(_coinOBJ)
            _coinOBJ.CoinUID.Value = ""
            _coinOBJ.GetCoinEvent:Clear()
        end
    )
end

--- 刷新一堆金币
function CoinMgr:SpawnCoinEventHandler(_type, _pos, _num)
    print("刷新一堆金币", _num)
    for i = 1, tonumber(string.sub(tostring(_num), #tostring(_num), #tostring(_num))) do
        this:SpawnCoin(_type .. "1", _pos)
    end
    if #tostring(_num) > 1 then
        for i = 1, tonumber(string.sub(tostring(_num), #tostring(_num) - 1, #tostring(_num) - 1)) do
            this:SpawnCoin(_type .. "10", _pos)
        end
    end
    if #tostring(_num) > 2 then
        for i = 1, tonumber(string.sub(tostring(_num), #tostring(_num) - 2, #tostring(_num) - 2)) do
            this:SpawnCoin(_type .. "100", _pos)
        end
    end
    if #tostring(_num) > 3 then
        for i = 1, tonumber(string.sub(tostring(_num), 1, #tostring(_num) - 3)) do
            this:SpawnCoin(_type .. "1000", _pos)
        end
    end
end

function CoinMgr:Update(dt)
end

return CoinMgr
