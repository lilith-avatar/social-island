--- 游戏服务器数据同步
--- @module Server Sync Data, Server-side
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local ServerDataSync = {}

-- Localize global vars
local FrameworkConfig, MetaData = FrameworkConfig, MetaData

-- 服务器端私有数据
local rawDataGlobal = {}
local rawDataPlayers = {}

--- 打印数据同步日志
local PrintLog = FrameworkConfig.DebugMode and function(...)
        print('[DataSync][Server]', ...)
    end or function()
    end

--! 初始化

--- 数据初始化
function ServerDataSync.Init()
    print('[DataSync][Server] Init()')
    InitEventsAndListeners()
    InitDefines()
end

--- 初始化事件和绑定Handler
function InitEventsAndListeners()
    if world.S_Event == nil then
        world:CreateObject('FolderObject', 'S_Event', world)
    end

    -- 数据同步事件
    world:CreateObject('CustomEvent', 'DataSyncC2SEvent', world.S_Event)
    world.S_Event.DataSyncC2SEvent:Connect(DataSyncC2SEventHandler)

    -- 玩家加入事件
    local onPlayerJoinEvent = world.S_Event.OnPlayerJoinEvent
    assert(onPlayerJoinEvent, '[DataSync][Server] 不存在 OnPlayerJoinEvent')
    onPlayerJoinEvent:Connect(OnPlayerJoinEventHandler)

    -- 玩家离开事件
    local onPlayerLeaveEvent = world.S_Event.OnPlayerLeaveEvent
    assert(onPlayerLeaveEvent, '[DataSync][Server] 不存在 OnPlayerLeaveEvent')
    onPlayerLeaveEvent:Connect(OnPlayerLeaveEventHandler)
end

--- 校验数据定义
function InitDefines()
    --* 服务器全局数据
    InitDataGlobal()

    --* 服务器玩家数据, key是uid
    Data.Players = {}
end

--- 初始化Data.Global
function InitDataGlobal()
    --* 服务器全局数据
    Data.Global = Data.Global or MetaData.New(rawDataGlobal, MetaData.Enum.GLOBAL, nil)
    -- 默认赋值
    for k, v in pairs(Data.Default.Global) do
        Data.Global[k] = v
    end
end

--- 初始化Data.Players中对应玩家数据
function InitDataPlayer(_player)
    --* 服务器端创建Data.Player
    local uid = _player.UserId
    local path = MetaData.Enum.PLAYER .. uid
    rawDataPlayers[uid] = {}
    Data.Players[uid] = MetaData.New(rawDataPlayers[uid], path, uid)

    -- 默认赋值
    for k, v in pairs(Data.Default.Player) do
        Data.Players[uid][k] = v
    end
end

--- 开始同步
function ServerDataSync.Start()
    -- MetaData.ServerSync = true
end

--! Event handler

--- 数据同步事件Handler
function DataSyncC2SEventHandler(_player, _path, _value)
    if not MetaData.ServerSync then
        return
    end

    PrintLog(string.format('收到 player = %s, _path = %s, _value = %s', _player, _path, table.dump(_value)))

    local uid = _player.UserId

    if string.startswith(_path, MetaData.Enum.GLOBAL) then
        --* Data.Global：收到客户端改变数据的时候需要同步给其他玩家
        MetaData.Set(rawDataGlobal, _path, _value, nil, true)
    elseif string.startswith(_path, MetaData.Enum.PLAYER .. uid) then
        --* Data.Players
        MetaData.Set(rawDataPlayers[uid], _path, _value, uid, false)
    else
        error(
            string.format(
                '[DataSync][Server] _path错误 _player = %s, _path = %s, _value = %s',
                _player,
                _path,
                table.dump(_data)
            )
        )
    end
end

--- 新玩家加入事件Handler
function OnPlayerJoinEventHandler(_player)
    print('[DataSync][Server] OnPlayerJoinEventHandler', _player, _player.UserId)
    --* 向客户端同步Data.Global
    NetUtil.Fire_C('DataSyncS2CEvent', _player, MetaData.Enum.GLOBAL, MetaData.Get(Data.Global))

    local uid = _player.UserId
    InitDataPlayer(_player)

    --TODO: 获取长期存储,成功后向客户端同步
end

--- 玩家离开事件Handler
function OnPlayerLeaveEventHandler(_player, _uid)
    print('[DataSync][Server] OnPlayerLeaveEventHandler', _player, _uid)
    assert(not string.isnilorempty(_uid), '[ServerDataSync] OnPlayerLeaveEventHandler() uid不存在')

    --TODO: 保存长期存储：rawDataPlayers[_uid] 保存成功后删掉
    rawDataPlayers[_uid] = nil

    --* 删除玩家端数据
    Data.Players[_uid] = nil
end

return ServerDataSync
