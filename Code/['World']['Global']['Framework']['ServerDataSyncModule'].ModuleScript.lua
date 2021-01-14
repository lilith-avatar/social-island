--- 游戏服务器数据同步
--- @module Server Sync Data, Server-side
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local ServerDataSync = {}

-- Localize global vars
local FrameworkConfig = FrameworkConfig

-- 数据定义格式: 全局数据, 玩家数据
local GLOBAL_DATA_DEFINE, PLAYER_DATA_DEFINE

-- 设置数据所属
MetaData.Host = MetaData.SERVER

--- 打印数据同步日志
local PrintLog = FrameworkConfig.DebugMode and function(...)
        print('[DataSync][Server]', ...)
    end or function()
    end

-- 客户端本地数据: 全局数据, 玩家数据
local globalData = {}
local playerDatas = {}

--! 初始化

--- 数据初始化
function ServerDataSync.Init()
    print('[DataSync][Server] Init()')
    InitEventsAndListeners()
    InitDefines()
end

--- 校验数据定义
function InitDefines()
    -- 数据校验
    assert(
        GLOBAL_DATA_DEFINE and type(GLOBAL_DATA_DEFINE) == 'table',
        '[DataSync][Server] 全局数据定义有误，请检查 FrameworkConfig.GlobalDataDefine'
    )
    assert(
        PLAYER_DATA_DEFINE and type(PLAYER_DATA_DEFINE) == 'table',
        '[DataSync][Server] 玩家数据定义有误，请检查 FrameworkConfig.PlayerDataDefine'
    )
end

--- 初始化事件和绑定Handler
function InitEventsAndListeners()
    if world.S_Event == nil then
        world:CreateObject('FolderObject', 'S_Event', world)
    end
    world:CreateObject('CustomEvent', 'DataSyncC2SEvent', world.S_Event)
    world.S_Event.DataSyncC2SEvent:Connect(DataSyncC2SEventHandler)
end

--! 外部接口

--- 定义全局数据
function ServerDataSync.SetGlobalDataDefine(_define)
    GLOBAL_DATA_DEFINE = _define
end

--- 定义玩家数据
function ServerDataSync.SetPlayerDataDefine(_define)
    PLAYER_DATA_DEFINE = _define
end

--! Event handler

--- 数据同步事件Handler
function DataSyncC2SEventHandler(_player, _key, _data)
    print('ssssssssssssssssssssssssssssssssssssss')
    print('[DataSync][Server]', _player, _key, _data)
    if not playerDatas[_player] then
        playerDatas[_player] = {}
    end
    playerDatas[_player][_key] = _data
end

return ServerDataSync

--[[
local people = {
    name = 'Jey',
    age = 18,
    run = function()
        print('people跑步🏃中')
    end
}

local other = {
    name = '我是多余的'
}

local tableA = {}

local tableB = {
    __index = people,
    __newindex = function(t, k, v)
        print('xxxxx', k, v)
        people[k] = v
    end
}

setmetatable(tableA, tableB)

tableA.run = function()
    print('别跑了')
end
tableA.age = '20'

-- a
tableA.run()
print('tableA.name=' .. tableA.name)
print('tableA.age=' .. tableA.age)

-- -- other
-- other.run()
-- print('other.name=' .. other.name)
-- print('other.age=' .. other.age)
]]
