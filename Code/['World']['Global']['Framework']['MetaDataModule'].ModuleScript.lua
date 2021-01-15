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
local sgraw = {} -- server global raw data
local cgraw = {} -- client global raw data
local spraw = {} -- server player raw data
local cpraw = {} -- client player raw data

-- 服务器GlobalData数据元表
local function SetServerData(_t, _k, _v)
    NetUtil.Broadcast('DataSyncS2CEvent', _k, _v)
    print('S => C S => C S => C S => C S => C S => C S => C S => C S => C S => C S => C')
    print('[MetaData] S => C', _k, _v)
    -- TODO: 应该不能直接赋值，而是用Add设置？
    sgraw[_t][_k] = _v
end

-- 客户端GlobalData数据元表
local function SetClientData(_t, _k, _v)
    NetUtil.Fire_S('DataSyncC2SEvent', localPlayer, _k, _v)
    print('C => S C => S C => S C => S C => S C => S C => S C => S C => S C => S C => S')
    print('[MetaData] C => S', _k, _v)
    cgraw[_t][_k] = _v
end

-- 生成数据
function MetaData.New(_t)
    -- ref https://www.jianshu.com/p/f556441bcf00
    local proxy = {}
    local mt = {}
    mt.__index = _t
    if MetaData.Host == MetaData.SERVER then
        sgraw[proxy] = _t
        mt.__newindex = SetServerData
    elseif MetaData.Host == MetaData.CLIENT then
        cgraw[proxy] = _t
        mt.__newindex = SetClientData
    else
        error('[MetaData] 数据为定义所属，请先定义MetaData.Host，1是服务器, 2是客户端')
    end
    setmetatable(proxy, mt)
    return proxy
end

return MetaData
