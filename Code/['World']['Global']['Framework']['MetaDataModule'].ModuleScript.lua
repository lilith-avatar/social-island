--- 游戏同步数据基类
--- @module Sync Data Base, Both-side
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
MetaData = {}

-- enum
MetaData.UNDEFINED = 0
MetaData.SERVER = 1
MetaData.CLIENT = 2

-- 数据, 1是服务器, 2是客户端
MetaData.Host = MetaData.UNDEFINED

-- metatable
local sraw = {} -- server raw data
local craw = {} -- client raw data

-- 服务器数据元表
local function SetServerData(_t, _k, _v)
    NetUtil.Broadcast('DataSyncS2CEvent', _k, _v)
    print('S => C S => C S => C S => C S => C S => C S => C S => C S => C S => C S => C')
    print('[MetaData] S => C', _k, _v)
    sraw[_t][_k] = _v
end

-- 客户端数据元表
local function SetClientData(_t, _k, _v)
    NetUtil.Fire_S('DataSyncC2SEvent', localPlayer, _k, _v)
    print('C => S C => S C => S C => S C => S C => S C => S C => S C => S C => S C => S')
    print('[MetaData] C => S', _k, _v)
    craw[_t][_k] = _v
end

-- 生成数据
function MetaData.New(_t)
    -- ref https://www.jianshu.com/p/f556441bcf00
    local proxy = {}
    local mt = {}
    mt.__index = _t
    if MetaData.Host == MetaData.SERVER then
        sraw[proxy] = _t
        mt.__newindex = SetServerData
    elseif MetaData.Host == MetaData.CLIENT then
        craw[proxy] = _t
        mt.__newindex = SetClientData
    else
        error('[MetaData] 数据为定义所属，请先定义MetaData.Host，1是服务器, 2是客户端')
    end
    setmetatable(proxy, mt)
    return proxy
end

return MetaData
