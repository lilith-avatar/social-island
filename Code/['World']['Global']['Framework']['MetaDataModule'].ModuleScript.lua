--- 游戏同步数据基类
--- @module Sync Data Base, Both-side
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local MetaData = {}

-- Localize global vars
local FrameworkConfig = FrameworkConfig

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

-- Default
SERVER_ID = 'SERVER_ID'

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

-- 计数器，用于生成 metadata id (_metaId)
local cnts = {}

--- 打印数据同步日志
local PrintLog = FrameworkConfig.DebugMode and function(...)
        print('[MetaData]', ...)
    end or function()
    end

--! 私有方法

-- 服务器GlobalData数据元表
local function SetServerGlobalData(_t, _k, _v)
    MetaData.SetServerGlobalData(_t._metaId, _k, _v, true)
end

-- 客户端GlobalData数据元表
local function SetClientGlobalData(_t, _k, _v)
    MetaData.SetClientGlobalData(_t._metaId, _k, _v, true)
end

-- 服务器PlayerData数据元表
local function SetServerGlobalData(_t, _k, _v)
    MetaData.SetServerGlobalData(_t._metaId, _k, _v, true)
end

-- 客户端PlayerData数据元表
local function SetClientGlobalData(_t, _k, _v)
    MetaData.SetClientGlobalData(_t._metaId, _k, _v, true)
end

-- 生成ID
local function GenDataId(_uid)
    cnts[_uid] = cnts[_uid] or 0
    cnts[_uid] = cnts[_uid] + 1
    return cnts[_uid]
end

-- 数据校验
local function DataValidation(_raw, _metaId, _k, _v)
    assert(_k, string.format('[MetaData]%s 数据key为空', _raw._name))
    assert(_v, string.format('[MetaData]%s 数据value为空', _raw._name))
    assert(_raw[_metaId], string.format('[MetaData]%s metaId对应数据不存在, metaId = %s', _raw._name, _metaId))
    assert(
        _raw[_metaId][_k],
        string.format('[MetaData]%s metaId不存在key的数据, metaId = %s, key = %s', _raw._name, _metaId, _k)
    )
end

--! 外部接口

-- 生成GlobalData数据
function MetaData.NewGlobalData(_t)
    -- ref https://www.jianshu.com/p/f556441bcf00
    local proxy, mt, metaId = {}, {}
    mt.__index = _t
    mt.__pairs = MetaData.Pairs(_t)
    if MetaData.Host == MetaData.Enum.SERVER then
        metaId = GenDataId(SERVER_ID)
        _t._metaId = metaId
        sgraw[metaId] = _t
        mt.__newindex = SetServerGlobalData
        PrintLog(string.format('[MetaData]%s _metaId = %s, %s', sgraw._name, metaId, table.dump(_t)))
    elseif MetaData.Host == MetaData.Enum.CLIENT then
        assert(localPlayer, string.format('[MetaData]%s 未找到localPlayer', cgraw._name))
        metaId = GenDataId(localPlayer.UserId)
        _t._metaId = metaId
        cgraw[metaId] = _t
        mt.__newindex = SetClientGlobalData
        PrintLog(string.format('[MetaData]%s _metaId = %s, %s', cgraw._name, metaId, table.dump(_t)))
    else
        error('[MetaData] NewGlobalData() 数据为定义所属，请先定义MetaData.Host，1是服务器, 2是客户端')
    end
    setmetatable(proxy, mt)
    return proxy
end

-- 生成PlayerData数据
function MetaData.NewPlayerData(_t)
    local proxy = {}
    local mt = {}
    local metaId = GenDataId()
    _t._metaId = metaId
    mt.__indxe = _t
    mt.__pairs = MetaData.Pairs(_t)
    if MetaData.Host == MetaData.Enum.SERVER then
        -- TODO: 检查长期存储；若有：用长期存储生成表发给客户端；若无：生成默认的发给客户端
        -- metaId = GenDataId()
    elseif MetaData.Host == MetaData.Enum.CLIENT then
        -- 生成默认的客户端
        assert(localPlayer, string.format('[MetaData]%s 未找到localPlayer', cpraw._name))
        metaId = GenDataId(localPlayer.UserId)
        _t._metaId = metaId
        cpraw[metaId] = _t
        mt.__newindex = SetClientGlobalData
    else
        error('[MetaData] NewPlayerData() 数据为定义所属，请先定义MetaData.Host，1是服务器, 2是客户端')
    end
    setmetatable(proxy, mt)
    return proxy
end

-- 重载MetaData的pairs()方法
function MetaData.Pairs(_mt)
    return function()
        return function(_t, _k)
            local v
            repeat
                _k, v = next(_t, _k)
            until _k == nil or _k ~= '_metaId'
            return _k, v
        end, _mt, nil
    end
end

-- 直接修改GlobalData：服务器
function MetaData.SetServerGlobalData(_metaId, _k, _v, _sync)
    DataValidation(sgraw, _metaId, _k, _v)
    sgraw[_metaId][_k] = _v
    if _sync then
        NetUtil.Broadcast('DataSyncS2CEvent', MetaData.Enum.GLOBAL, _metaId, _k, _v)
        PrintLog(
            string.format(
                '[MetaData]%s S => C metaId = %s, key = %s, data = %s',
                sgraw._name,
                _metaId,
                _k,
                table.dump(_v)
            )
        )
    end
end

-- 直接修改GlobalData：客户端
function MetaData.SetClientGlobalData(_metaId, _k, _v, _sync)
    DataValidation(cgraw, _metaId, _k, _v)
    cgraw[_metaId][_k] = _v
    if _sync then
        NetUtil.Fire_S('DataSyncC2SEvent', localPlayer, MetaData.Enum.GLOBAL, _metaId, _k, _v)
        PrintLog(
            string.format(
                '[MetaData]%s C => S metaId = %s, key = %s, data = %s',
                cgraw._name,
                _metaId,
                _k,
                table.dump(_v)
            )
        )
    end
end

-- 直接修改PlayerData：服务器
function MetaData.SetServerPlayerData(_player, _metaId, _k, _v, _sync)
    assert(localPlayer, string.format('[MetaData]%s 未找到player', cpraw._name))
    local uid = _player.UserId
    DataValidation(spraw[uid], _metaId, _k, _v)
    spraw[uid][_metaId][_k] = _v
    if _sync then
        NetUtil.Fire_C('DataSyncS2CEvent', _player, MetaData.Enum.PLAYER, _metaId, _k, _v)
        PrintLog(
            string.format(
                '[MetaData]%s S => C metaId = %s, key = %s, data = %s',
                sgraw._name,
                _metaId,
                _k,
                table.dump(_v)
            )
        )
    end
end

-- 直接修改PlayerData：客户端
function MetaData.SetClientPlayerData(_metaId, _k, _v, _sync)
    DataValidation(cpraw, _metaId, _k, _v)
    cpraw[_metaId][_k] = _v
    if _sync then
        NetUtil.Fire_S('DataSyncC2SEvent', localPlayer, MetaData.Enum.PLAYER, _metaId, _k, _v)
        PrintLog(
            string.format(
                '[MetaData]%s C => S metaId = %s, key = %s, data = %s',
                cpraw._name,
                _metaId,
                _k,
                table.dump(_v)
            )
        )
    end
end

return MetaData
