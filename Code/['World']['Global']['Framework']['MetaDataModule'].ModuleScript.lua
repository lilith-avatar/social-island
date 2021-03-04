--- 游戏同步数据基类
--- @module Sync Data Base, Both-side
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local MetaData = {}

-- Localize global vars
local FrameworkConfig = FrameworkConfig

-- Debug
local debugMode = false

-- enum
MetaData.Enum = {}
-- 数据所属：客户端 or 服务器
MetaData.Enum.UNDEFINED = 0
MetaData.Enum.SERVER = 1
MetaData.Enum.CLIENT = 2
-- 数据类型：全局 or 玩家
MetaData.Enum.GLOBAL = 3
MetaData.Enum.PLAYER = 4

-- 数据, 1是服务器, 2是客户端
MetaData.Host = MetaData.Enum.UNDEFINED

-- 是否进行同步，数据初始化之后在开启同步
MetaData.Sync = false

-- 说明：两种双向同步机制
-- 1. GlobalData
--  a. 客户端和服务器持有相同的GlobalData数据类型
--  b. C=>S，客户端更新，自动发送给服务器，服务器更新
--  c. S=>C，服务器更新，广播给所有客户端，客户端各自更新
-- 2. PlayerData
--  a. 客户端只持有自己的PlayerData，服务器持有全部玩家的PlayerData
--  b. C=>S，客户端更新，自动发送给服务器，服务器更新对应玩家数据
--  c. S=>C，服务器更新，自动发送给对应客户端，客户端更新玩家数据

-- metatable
local sgraw = {_name = '[GlobalData][Server]'} -- server global raw data
local cgraw = {_name = '[GlobalData][Client]'} -- client global raw data
local spraw = {_name = '[PlayerData][Server]'} -- server player raw data
local cpraw = {_name = '[PlayerData][Client]'} -- client player raw data

MetaData.sgraw = sgraw
MetaData.cgraw = cgraw

--- 打印数据同步日志
local PrintLog = FrameworkConfig.DebugMode and debugMode and function(...)
        print('[MetaData]', ...)
    end or function()
    end

--! 私有方法

-- 服务器GlobalData数据元表
local function SetServerGlobalData(_t, _k, _v)
    MetaData.SetServerGlobalDataRaw(_t._mid, _k, _v, true)
end

-- 客户端GlobalData数据元表
local function SetClientGlobalData(_t, _k, _v)
    MetaData.SetClientGlobalDataRaw(_t._mid, _k, _v, true)
end

-- 服务器PlayerData数据元表
local function SetServerPlayerData(_uid)
    local uid = _uid
    return function(_t, _k, _v)
        MetaData.SetServerPlayerDataRaw(_uid, _t._mid, _k, _v, true)
    end
end

-- 客户端PlayerData数据元表
local function SetClientPlayerData(_t, _k, _v)
    MetaData.SetClientPlayerDataRaw(_t._mid, _k, _v, true)
end

-- 数据校验
local function DataValidation(_raw, _mid, _k, _v)
    assert(_raw, '[MetaData] 原始数据丢失 _raw')
    assert(_k, string.format('[MetaData]%s 数据key为空', _raw._name))
    -- assert(_v ~= nil, string.format('[MetaData]%s 数据value为空', _raw._name))
    assert(_raw[_mid], string.format('[MetaData]%s metaId对应数据不存在, mid = %s', _raw._name, _mid))
    -- assert(
    --     _raw[_mid][_k] ~= nil,
    --     string.format('[MetaData]%s metaId不存在key的数据, mid = %s, key = %s', _raw._name, _mid, _k)
    -- )
end

-- 生成Scheme的辅助函数
local function GenSchemeAux(_scheme, _new, _uid, _mid)
    if type(_scheme) == 'table' then
        local meta, submid = {}
        for k, v in pairs(_scheme) do
            submid = string.format('%s_%s', _mid, k)
            meta[k] = GenSchemeAux(v, _new, _uid, submid)
        end
        return _new(meta, _mid, _uid)
    end
    return _scheme
end

--! 外部接口

-- 生成GlobalData数据
function MetaData.NewGlobalData(_t, _mid)
    -- ref https://www.jianshu.com/p/f556441bcf00
    local proxy, mt = {}, {}
    _mid = _mid or 'g'
    _t._mid = _mid
    mt.__index = _t
    mt.__pairs = MetaData.Pairs(_t)
    if MetaData.Host == MetaData.Enum.SERVER then
        -- 生成服务器Data.Global
        sgraw[_mid] = _t
        mt.__newindex = SetServerGlobalData
        PrintLog(string.format('%s mid = %s, %s', sgraw._name, _mid, table.dump(_t)))
    elseif MetaData.Host == MetaData.Enum.CLIENT then
        -- 生成客户端Data.Global
        assert(localPlayer, string.format('[MetaData]%s 未找到localPlayer', cgraw._name))
        local uid = localPlayer.UserId
        assert(not string.isnilorempty(uid), string.format('[MetaData]%s uid不存在, uid = %s', cgraw._name, uid))
        cgraw[_mid] = _t
        mt.__newindex = SetClientGlobalData
        PrintLog(string.format('%s mid = %s, %s', cgraw._name, _mid, table.dump(_t)))
    else
        error('[MetaData] NewGlobalData() 数据为定义所属，请先定义MetaData.Host，1是服务器, 2是客户端')
    end
    setmetatable(proxy, mt)
    return proxy
end

--- 生成PlayerData数据

function MetaData.NewPlayerData(_t, _mid, _uid)
    assert(not string.isnilorempty(_uid), '[MetaData] uid不存在')
    local proxy, mt, mid = {}, {}
    _mid = _mid or 'p_' .. _uid
    _t._mid = _mid
    mt.__index = _t
    mt.__pairs = MetaData.Pairs(_t)
    if MetaData.Host == MetaData.Enum.SERVER then
        -- 生成服务器Data.Players[_uid]
        spraw[_uid] = spraw[_uid] or {_name = spraw._name}
        spraw[_uid][_mid] = _t
        mt.__newindex = SetServerPlayerData(_uid) -- 返回一个函数
        PrintLog(string.format('%s uid = %s, _mid = %s, %s', spraw._name, _uid, _mid, table.dump(_t)))
    elseif MetaData.Host == MetaData.Enum.CLIENT then
        -- 生成客户端Data.Player
        cpraw[_mid] = _t
        mt.__newindex = SetClientPlayerData
        PrintLog(string.format('%s uid = %s, _mid = %s, %s', cpraw._name, _uid, _mid, table.dump(_t)))
    else
        error('[MetaData] NewPlayerData() 数据为定义所属，请先定义MetaData.Host，1是服务器, 2是客户端')
    end
    setmetatable(proxy, mt)
    return proxy
end

--- 重载MetaData的pairs()方法
-- @param _rt 原始表格 raw table
function MetaData.Pairs(_rt)
    return function()
        return function(_t, _k)
            local v
            repeat
                _k, v = next(_t, _k)
            until _k == nil or _k ~= '_mid'
            return _k, v
        end, _rt, nil
    end
end

-- 直接修改GlobalData：服务器
function MetaData.SetServerGlobalDataRaw(_mid, _t, _k, _v, _sync)
    print('sssssssssssssssssssssssssssssssssssssssss')
    print(_mid, _k, table.dump(_v), _sync)
    DataValidation(sgraw, _mid, _k, _v)
    if _v == nil then
        --* 删除raw数据
        sgraw[_mid][_k] = nil
        -- 删除多余的mid
        local submid = string.format('%s_%s', _mid, _k)
        for mid, v in pairs(sgraw) do
            if string.startswith(mid, submid) then
                sgraw[mid] = nil
            end
        end
    elseif sgraw[_mid][_k] == nil then
        -- -- TODO: table类型，特殊处理
        -- if type(_v) == 'table' then
        --     local submid = string.format('%s_%s', _mid, _k)
        -- -- MetaData.CreateDataTable(_v, sgraw[_mid][_k], MetaData.NewGlobalData, nil, submid)
        -- end
        --* 新数值
        -- 原有mid添加数值
        sgraw[_mid][_k] = GenSchemeAux(_v, MetaData.GlobalData, nil, _mid)
    else
        --* 更新
        if type(_v) == 'table' then
            -- TODO: table类型，特殊处理
        else
            -- 一般数据类型，直接更新
            sgraw[_mid][_k] = _v
        end
    end
    -- if type(_v) == 'table' then
    --     -- table数据类型，内部遍历
    --     local submid
    --     for k, v in pairs(_v) do
    --         print('kv', k, v, _mid, sgraw[_mid])
    --         if type(v) == 'table' then
    --             -- table嵌套
    --             submid = string.format('%s_%s', _mid, _k)
    --             print('submid', submid)
    --             if sgraw[submid] then
    --                 -- 已存在
    --                 MetaData.SetServerGlobalDataRaw(submid, k, v, _sync)
    --             else
    --                 -- 未存在，创建新的MetaData
    --                 print('111111')
    --                 sgraw[submid] = {}
    --                 local meta = GenSchemeAux(_scheme, MetaData.NewGlobalData, nil, _mid)
    --                 local mt = {
    --                     __index = meta,
    --                     __newindex = meta,
    --                     __pairs = MetaData.Pairs(getmetatable(meta).__index)
    --                 }
    --                 setmetatable(sgraw[submid], mt)
    --             end
    --         else
    --             -- sgraw[_mid][k] = {}
    --             -- MetaData.CreateDataTable(v, sgraw[_mid][k], MetaData.NewGlobalData)
    --             print('22222')
    --             sgraw[_mid][k] = v
    --             MetaData.SetServerGlobalDataRaw(_mid, _k, _v, _sync)
    --         end
    --     end
    -- else
    --     sgraw[_mid][_k] = _v
    -- end

    if _sync and MetaData.Sync then
        NetUtil.Broadcast('DataSyncS2CEvent', MetaData.Enum.GLOBAL, _mid, _k, _v)
        PrintLog(string.format('%s S => C, mid = %s, key = %s, data = %s', sgraw._name, _mid, _k, table.dump(_v)))
    end
end

-- 直接修改GlobalData：客户端
function MetaData.SetClientGlobalDataRaw(_mid, _k, _v, _sync)
    print('ccccccccccccccccccccccccc')
    print(_mid, _k, table.dump(_v), _sync)
    DataValidation(cgraw, _mid, _k, _v)
    cgraw[_mid][_k] = _v
    if _v == nil then
        --* 删除raw数据
        cgraw[_mid][_k] = nil
        -- 删除多余的metaId
        local submid = string.format('%s_%s', _mid, _k)
        for mid, v in pairs(cgraw) do
            if string.startswith(mid, submid) then
                cgraw[mid] = nil
            end
        end
    elseif cgraw[_mid][_k] == nil then
        --* 新数值
        -- 原有metaId添加数值
        cgraw[_mid][_k] = _v
        -- TODO: table类型，特殊处理
        if type(_v) == 'table' then
            local submid = string.format('%s_%s', _mid, _k)
        -- MetaData.CreateDataTable(_v, cgraw[_mid][_k], MetaData.NewGlobalData, nil, submid)
        end
    else
        --* 更新
        if type(_v) == 'table' then
            -- 表格特殊处理
        else
            -- 一般数据类型，直接更新
            cgraw[_mid][_k] = _v
        end
    end

    if _sync and MetaData.Sync then
        NetUtil.Fire_S('DataSyncC2SEvent', localPlayer, MetaData.Enum.GLOBAL, _mid, _k, _v)
        PrintLog(string.format('%s C => S, mid = %s, key = %s, data = %s', cgraw._name, _mid, _k, table.dump(_v)))
    end
end

-- 直接修改PlayerData：服务器
function MetaData.SetServerPlayerDataRaw(_uid, _mid, _k, _v, _sync)
    DataValidation(spraw[_uid], _mid, _k, _v)
    spraw[_uid][_mid][_k] = _v
    if _sync and MetaData.Sync then
        local player = world:GetPlayerByUserId(_uid)
        assert(player, string.format('[MetaData]%s 未找到player', cpraw._name))
        NetUtil.Fire_C('DataSyncS2CEvent', player, MetaData.Enum.PLAYER, _mid, _k, _v)
        PrintLog(
            string.format(
                '%s S => C, player = %s, mid = %s, key = %s, data = %s',
                sgraw._name,
                player,
                _mid,
                _k,
                table.dump(_v)
            )
        )
    end
end

-- 直接修改PlayerData：客户端
function MetaData.SetClientPlayerDataRaw(_mid, _k, _v, _sync)
    DataValidation(cpraw, _mid, _k, _v)
    cpraw[_mid][_k] = _v
    if _sync and MetaData.Sync then
        NetUtil.Fire_S('DataSyncC2SEvent', localPlayer, MetaData.Enum.PLAYER, _mid, _k, _v)
        PrintLog(
            string.format(
                '%s C => S, player = %s, mid = %s, key = %s, data = %s',
                cpraw._name,
                localPlayer,
                _mid,
                _k,
                table.dump(_v)
            )
        )
    end
end

-- 创建一个Data表
function MetaData.CreateDataTable(_scheme, _data, _new, _uid, _mid)
    -- PrintLog('CreateDataTable()', _scheme, _data, _new, _player)
    assert(_scheme, '[MetaData] CreateDataTable(), scheme为空')
    assert(_data, '[MetaData] CreateDataTable(), data为空')
    assert(_new and type(_new) == 'function', '[MetaData] CreateDataTable(), new为空')
    local meta = GenSchemeAux(_scheme, _new, _uid, _mid)
    local mt = {
        __index = meta,
        __newindex = meta,
        __pairs = MetaData.Pairs(getmetatable(meta).__index)
    }
    setmetatable(_data, mt)
end

-- 删除一个Data表
function MetaData.DeleleServerPlayerData(_uid)
    spraw[_uid] = nil
end

_G.TestData = {}
_G.TestData2 = {}

function MetaData.InitServerData()
    InitServerDataGlobal()
    -- InitServerDataPlayer()
end

function InitServerDataGlobal()
    _G.Test = NewData(TestData, 'Test')
    _G.Test2 = NewData(TestData2, 'Test2')
end

--- 新建一个MetaData的proxy，用于数据同步
-- @param _data 真实数据
-- @param _path 当前节点索引路径
-- @return proxy 代理table，没有data，元表内包含方法和path
function NewData(_data, _path)
    local proxy = {}
    local mt = {
        _path = _path,
        __index = function(_t, _k)
            local mt = getmetatable(_t)
            local newpath = mt._path .. '.' .. _k
            print('__index,', '_k =', _k, ', _path = ', mt._path, ', newpath = ', newpath)
            return _data[newpath]
        end,
        __newindex = function(_t, _k, _v)
            local mt = getmetatable(_t)

            local newpath = mt._path .. '.' .. _k
            print('__newindex,', '_k =', _k, ', _v =', _v, ', _path = ', mt._path, ', newpath = ', newpath)
            SetData(_data, newpath, _v)
        end,
        __pairs = function()
            -- pairs()需要返回三个参数：next, _t, nil
            -- https://www.lua.org/pil/7.3.html
            -- 得到rd(raw data)，从rd中进行遍历
            local rd = GetData(_data, _path)
            return next, rd, nil
        end
    }
    setmetatable(proxy, mt)
    return proxy
end

--- 获得原始数据
-- @param _data 真实数据的存储位置
-- @param _path 当前节点索引路径
-- @return rawData 纯数据table，不包含元表
function GetData(_data, _path)
    local rawData, key, i = {}
    for k, v in pairs(_data) do
        i = string.find(k, _path .. '.')
        -- 筛选出当前直接层级的path，剪裁后作为rawData的key
        if i == 1 and #_path < #k then
            key = string.sub(k, #_path + 2, #k)
            if not string.find(key, '%.') then
                key = tonumber(key) or key
                rawData[key] = v
            end
        end
    end
    return rawData
end

--- 设置原始数据
-- @param _data 真实数据的存储位置
-- @param _path 当前节点索引路径
-- @param _value 传入的数据
function SetData(_data, _path, _value)
    --* 检查现有数据
    if type(_data[_path]) == 'table' then
        -- 如果现有数据是个table,删除所有子数据
        for k, _ in pairs(_data[_path]) do
            _data[_path][k] = nil
        end
    end

    --* 检查新数据
    if type(_value) == 'table' then
        -- 若新数据是table，建立一个mt
        _data[_path] = NewData(_data, _path)
        for k, v in pairs(_value) do
            _data[_path][k] = v
        end
    else
        -- 一般数据，直接赋值
        _data[_path] = _value
    end

    -- TODO: 赋值的时候只要同步一次就可以的，存下newpath和_v，对方收到后赋值即可
end

MetaData.SetData = SetData

--[[
    ! Test ONLY
    print('=====================================')
    Test.a = 12 Test.b = 33 Test.c = {12, 34, 5} Test.d = {m = 333, n = 444}
    print('=====================================')
    for k, v in pairs(Test) do print(k, v) end
    print('=====================================')
    for k, v in pairs(Test.c) do print(k, v) end
    print('=====================================')
    print(table.dump(Test)) print(table.dump(TestData)) 
    print('=====================================')
    TestData['Test.q'] = 234
    TestData['Test.p'] = {} TestData['Test.p.p1'] = 12 
    print('=====================================')
    MetaData.SetData(TestData2, 'Test2', {a = 11, b = {c = 22, d = 33}, e = {'e1', 'e2'}})
    print('=====================================')
    print(table.dump(Test2)) print(table.dump(TestData2)) 
    print('=====================================')
]]
function NewServerGlobal(_t, _k, _v)
    print(_t, _k, _v)
end

function UpdateData(_raw)
    if type(_raw) == 'table' then
        local metadata = {}
        for k, v in pairs(_raw) do
            metadata[k] = RawDataAux(v)
        end
        return metadata
    end
    return _raw
end

function NewServerGlobal()
end

return MetaData
