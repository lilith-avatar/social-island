--- 金币管理模块
--- @module CoinMgr Module
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local CoinMgr, this = ModuleUtil.New('CoinMgr', ServerBase)

---* 常量声明
-- 对象池默认容量
local DEFAUL_POOL_SIZE = 120
local COIN_DESPAWN_DELAY = 0.12

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
    --coinPool.N100:PreSpawn(Vector3.Zero)
    coinPool.P100 = ObjPoolUtil.Newpool(world.Coin, 'Coin100_P', _size)
    --coinPool.P100:PreSpawn(Vector3.Zero)
    coinPool.N1000 = ObjPoolUtil.Newpool(world.Coin, 'Coin1000_N', _size)
    coinPool.P1000 = ObjPoolUtil.Newpool(world.Coin, 'Coin1000_P', _size)
end

--- 刷新一个金币
function CoinMgr:SpawnCoin(_pool, _pos, _dur)
    -- 参数校验
    assert(coinPool[_pool], string.format('[CoinMgr] 不存在此类金币对象池，请检查type，type = %s', _pool))
    assert(_pos and type(_pos) == 'userdata', string.format('[CoinMgr] pos有误，pos = %s', _pos))

    -- Spawn金币
    local coinObj = coinPool[_pool]:Spawn(_pos)
    if string.sub(_pool, 1, 1) == 'P' then
        coinObj.LinearVelocity = Vector3(math.random(-5, 5), 5, math.random(-5, 5))
        coinObj.Rotation = EulerDegree(0, math.random(0, 180), 0)
    end
    coinObj.CoinUID.Value = ''
    coinObj.CoinUID.OnValueChanged:Connect(
        function(_oldVal, _newVal)
            print(coinObj, 'CoinUID.OnValueChanged', _oldVal, _newVal)
            this:GetCoin(_pool, coinObj, _oldVal, _newVal)
        end
    )

    -- 存在时间
    if _dur and _dur > 0 then
        coinObj.TimerId.Value =
            TimeUtil.SetTimeout(
            function()
                -- 在没有玩家吃的情况下消失
                if coinObj and coinObj.ActiveSelf and string.isnilorempty(coinObj.CoinUID.Value) then
                    this:DespawnCoin(_pool, coinObj)
                end
            end,
            _dur
        )
    end

    return coinObj
end

--- 回收一个金币
function CoinMgr:DespawnCoin(_pool, _coinObj)
    _coinObj.CoinUID.OnValueChanged:Clear()
    _coinObj.CoinUID.Value = ''
    if _coinObj.TimerId.Value > 0 then
        TimeUtil.ClearTimeout(_coinObj.TimerId.Value)
        _coinObj.TimerId.Value = -1
    end
    _coinObj.LinearVelocity = Vector3(0, 0, 0)
    coinPool[_pool]:Despawn(_coinObj)
    local despawnEffect = world:CreateInstance('CoinDespawnEffect', 'CoinDespawnEffect', world, _coinObj.Position)
    invoke(
        function()
            despawnEffect:Destroy()
        end,
        1
    )
end

--- 获得金币
function CoinMgr:GetCoin(_pool, _coinObj, _oldVal, _newVal)
    _coinObj.Block = false
    local uid = _coinObj.CoinUID.Value
    assert(not string.isnilorempty(uid), string.format('[CoinMgr] uid为空, pool = %s, coinObj = %s', _pool, _coinObj))
    NetUtil.Fire_C('UpdateCoinEvent', world:GetPlayerByUserId(uid), _coinObj.CoinNum.Value, false, _coinObj.Position)
    invoke(
        function()
            -- _coinObj.LinearVelocity =
            --     (world:GetPlayerByUserId(uid).Position + Vector3.Up - _coinObj.Position).Normalized * 10
            -- wait(COIN_DESPAWN_DELAY)
            if string.sub(_pool, 1, 1) == 'P' then
                _coinObj.Block = true
            end
            this:DespawnCoin(_pool, _coinObj)
        end
    )
end

--- 刷新一堆金币，按照个十百千每一位单独刷
-- @param _type 金币类型，P:有物理，N:无物理
-- @param _pos 金币生成时的Position
-- @param _num 金币数量
-- @param _dur 金币生命周期（秒），_dur <= 0 or _dur == nil 则为永久
function CoinMgr:SpawnCoinEventHandler(_type, _pos, _num, _dur)
    this:Log('刷新一堆金币', _num)
    for i = 1, _num % 10 do
        this:SpawnCoin(_type .. '1', _pos, _dur)
    end
    for i = 1, (math.floor(_num / 10) % 10) do
        this:SpawnCoin(_type .. '10', _pos, _dur)
    end
    for i = 1, (math.floor(_num / 100) % 10) do
        this:SpawnCoin(_type .. '100', _pos, _dur)
    end
    for i = 1, (math.floor(_num / 1000)) do
        this:SpawnCoin(_type .. '1000', _pos, _dur)
    end
end

return CoinMgr
