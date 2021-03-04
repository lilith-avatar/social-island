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
-- 数据类型：全局 or 玩家
MetaData.Enum.GLOBAL = 'Global'
MetaData.Enum.PLAYER = 'Player'

-- 是否进行同步，数据初始化之后在开启同步
MetaData.Sync = false

--! 说明：两种双向同步机制
--* 1. Data.Global
--  a. 客户端和服务器持有相同的数据类型 Data.Global
--  b. C=>S，某一客户端更新，自动发送给服务器，服务器更新，然后再同步给全部客户端
--  c. S=>C，服务器更新，广播给所有客户端，客户端各自更新
--* 2. Data.Player
--  a. 客户端只持有自己的 Data.Player
--  b. 服务器持有全部玩家的 Data.Players
--  c. C=>S，客户端更新，自动发送给服务器，服务器更新对应玩家数据
--  d. S=>C，服务器更新，自动发送给对应客户端，客户端更新玩家数据

--! 私有方法

--- 新建一个MetaData的proxy，用于数据同步
-- @param _data 真实数据
-- @param _path 当前节点索引路径
-- @param _uid UserId
-- @return proxy 代理table，没有data，元表内包含方法和path
function NewData(_data, _path, _uid)
    local proxy = {}
    local mt = {
        _data = _data,
        _path = _path,
        _uid = _uid,
        __index = function(_t, _k)
            local mt = getmetatable(_t)
            local newpath = mt._path .. '.' .. _k
            PrintLog('__index,', '_k = ', _k, ', _path = ', mt._path, ', newpath = ', newpath)
            return _data[newpath]
        end,
        __newindex = function(_t, _k, _v)
            local mt = getmetatable(_t)

            local newpath = mt._path .. '.' .. _k
            PrintLog('__newindex,', '_k =', _k, ', _v =', _v, ', _path = ', mt._path, ', newpath = ', newpath)
            SetData(_data, newpath, _v, _uid, true)
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
                if type(v) == 'table' then
                    rawData[key] = GetData(_data, k)
                else
                    rawData[key] = v
                end
            end
        end
    end
    return rawData
end

--- 设置原始数据
-- @param _data 真实数据的存储位置
-- @param _path 当前节点索引路径
-- @param _value 传入的数据
-- @param _uid UserId
-- @param _sync true:同步数据
function SetData(_data, _path, _value, _uid, _sync)
    --* 数据同步
    -- TODO: 赋值的时候只要同步一次就可以的，存下newpath和_v，对方收到后赋值即可
    if _sync and MetaData.Sync then
        SyncData(_path, _value, _uid)
    end

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
        _data[_path] = NewData(_data, _path, _uid)
        for k, v in pairs(_value) do
            _data[_path][k] = v
        end
    else
        -- 一般数据，直接赋值
        _data[_path] = _value
    end
end

--- 数据同步
-- @param _path 当前节点索引路径
-- @param _value 传入的数据
-- @param _uid UserId
function SyncData(_path, _value, _uid)
    if localPlayer == nil and string.isnilorempty(_uid) then
        -- 服务器 => 客户端，Global 全局数据
        NetUtil.Broadcast('DataSyncS2CEvent', _path, _value)
    elseif localPlayer == nil then
        -- 服务器 => 客户端，Player 玩家数据
        local player = world:GetPlayerByUserId(_uid)
        assert(player, string.format('[MetaData] 玩家不存在 uid = %s', _uid))
        NetUtil.Fire_C('DataSyncS2CEvent', player, _path, _value)
    elseif localPlayer and localPlayer.UserId == _uid then
        -- 客户端 => 服务器
        NetUtil.Fire_S('DataSyncC2SEvent', localPlayer, _path, _value)
    else
        error(
            string.format(
                '[MetaData] SyncData() uid错误, path = %s, value = %s, uid = %s',
                _uid,
                _path,
                table.dump(_value)
            )
        )
    end
end

--! 公开API

--- 新建数据
MetaData.New = NewData

--- 设置数据
MetaData.Set = SetData

--- 从proxy中生成一个纯数据表格
MetaData.Get = function(_proxy)
    local mt = getmetatable(_proxy)
    return GetData(mt._data, mt._path)
end

--! 辅助方法

--- 打印数据同步日志
PrintLog = FrameworkConfig.DebugMode and debugMode and function(...)
        print('[MetaData]', ...)
    end or function()
    end

return MetaData

--! Command Test only
--[[
Data.Global.a = 11
Data.Global.b = {22, 33}
Data.Global.c = {c1 = {44, 55}, c2 = 66}
Data.Global.c.c3 = {c4 = 77}
Data.Global.d = {'88', Vector3(9,9,9)}
print(table.dump(Data.Global))
print(table.dump(MetaData.Get(Data.Global)))

print(table.dump(Data.Player))

print(table.dump(Data.Players))
]]
