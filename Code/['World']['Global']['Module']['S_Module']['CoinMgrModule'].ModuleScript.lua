--- 金币管理模块
--- @module CoinMgr Module
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local CoinMgr, this = ModuleUtil.New('CoinMgr', ServerBase)

---* 常量声明
-- 对象池默认容量
local DEFAUL_POOL_SIZE = 40

---* 变量声明
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
    --* 开关：Debug模式，开启后会打印日志
    this.debug = true
    this:Log('Init()')

    this:DataInit()
end

--- 数据变量初始化
function CoinMgr:DataInit()
    CoinMgr:InitCoinPool(DEFAUL_POOL_SIZE)
end

--- 初始化对象池
function CoinMgr:InitCoinPool(_size)
    coinPool.N1 = ObjPoolUtil.Newpool(world.Coin, 'Coin1_N', _size)
    coinPool.P1 = ObjPoolUtil.Newpool(world.Coin, 'Coin1_P', _size)
    coinPool.N10 = ObjPoolUtil.Newpool(world.Coin, 'Coin10_N', _size)
    coinPool.P10 = ObjPoolUtil.Newpool(world.Coin, 'Coin10_P', _size)
    coinPool.N100 = ObjPoolUtil.Newpool(world.Coin, 'Coin100_N', _size)
    coinPool.P100 = ObjPoolUtil.Newpool(world.Coin, 'Coin100_P', _size)
    coinPool.N1000 = ObjPoolUtil.Newpool(world.Coin, 'Coin1000_N', _size)
    coinPool.P1000 = ObjPoolUtil.Newpool(world.Coin, 'Coin1000_P', _size)
end

--- 刷新一个金币
function CoinMgr:SpawnCoin(_pool, _pos)
    -- 参数校验
    assert(coinPool[_pool], string.format('[CoinMgr] 不存在此类金币对象池，请检查type，type = %s', _pool))
    assert(_pos and type(_pos) == 'userdata', string.format('[CoinMgr] pos有误，pos = %s', _pos))

    -- Spawn金币
    local coinObj = coinPool[_pool]:Spawn(_pos)
    if string.sub(_pool, 1, 1) == 'P' then
        coinObj.LinearVelocity = Vector3(math.random(-5, 5), 5, math.random(-5, 5))
        coinObj.Rotation = EulerDegree(90, math.random(0, 180), 0)
    end

    -- 绑定事件
    coinObj.GetCoinEvent:Connect(
        function()
            this:GetCoin(_pool, coinObj)
        end
    )
    return coinObj
end

--- 获得金币
function CoinMgr:GetCoin(_pool, _coinObj)
    _coinObj.Block = false
    local uid = _coinObj.CoinUID.Value
    NetUtil.Fire_C('UpdateCoinEvent', world:GetPlayerByUserId(uid), _coinObj.CoinNum.Value)
    invoke(
        function()
            _coinObj.LinearVelocity =
                (world:GetPlayerByUserId(uid).Position + Vector3.Up - _coinObj.Position).Normalized * 10
            wait(0.12)
            if string.sub(_pool, 1, 1) == 'P' then
                _coinObj.Block = true
            end
            coinPool[_pool]:Despawn(_coinObj)
            _coinObj.CoinUID.Value = ''
            _coinObj.GetCoinEvent:Clear()
        end
    )
end

--- 刷新一堆金币
function CoinMgr:SpawnCoinEventHandler(_type, _pos, _num)
    this:Log('刷新一堆金币', _num)
    for i = 1, tonumber(string.sub(tostring(_num), #tostring(_num), #tostring(_num))) do
        this:SpawnCoin(_type .. '1', _pos)
    end
    if #tostring(_num) > 1 then
        for i = 1, tonumber(string.sub(tostring(_num), #tostring(_num) - 1, #tostring(_num) - 1)) do
            this:SpawnCoin(_type .. '10', _pos)
        end
    end
    if #tostring(_num) > 2 then
        for i = 1, tonumber(string.sub(tostring(_num), #tostring(_num) - 2, #tostring(_num) - 2)) do
            this:SpawnCoin(_type .. '100', _pos)
        end
    end
    if #tostring(_num) > 3 then
        for i = 1, tonumber(string.sub(tostring(_num), 1, #tostring(_num) - 3)) do
            this:SpawnCoin(_type .. '1000', _pos)
        end
    end
end

return CoinMgr
