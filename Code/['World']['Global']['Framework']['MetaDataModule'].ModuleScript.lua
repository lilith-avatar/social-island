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
local smt = {}
local cmt = {}

-- 服务器数据元表
smt.__newindex = function(_t, _k, _v)
    NetUtil.Broadcast('DataSyncS2CEvent', _k, _v)
    print('S => C S => C S => C S => C S => C S => C S => C S => C S => C S => C S => C')
    print('[MetaData] S => C', _k, _v)
    _t[_k] = _v
end

-- 客户端数据元表
cmt.__newindex = function(_t, _k, _v)
    NetUtil.Fire_S('DataSyncC2SEvent', localPlayer, _k, _v)
    print('C => S C => S C => S C => S C => S C => S C => S C => S C => S C => S C => S')
    print('[MetaData] C => S', _k, _v)
    _t[_k] = _v
end

-- 生成数据
function MetaData.New(_t)
    _t = _t or {}
    if MetaData.Host == MetaData.SERVER then
        setmetatable(_t, smt)
    elseif MetaData.Host == MetaData.CLIENT then
        setmetatable(_t, cmt)
    else
        error('[MetaData] 数据为定义所属，请先定义MetaData.Host，1是服务器, 2是客户端')
    end
    return _t
end

return MetaData
