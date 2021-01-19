--- 游戏服务器数据同步
--- @module Server Sync Data, Server-side
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local ServerDataSync = {}

-- Localize global vars
local FrameworkConfig, MetaData = FrameworkConfig, MetaData

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
    assert(onPlayerJoinEvent, string.format('[DataSync][Server] %s不存在', onPlayerJoinEvent))
    onPlayerJoinEvent:Connect(OnPlayerJoinEventHandler)

    -- 玩家离开事件
    local onPlayerLeaveEvent = world.S_Event.OnPlayerLeaveEvent
    assert(onPlayerLeaveEvent, string.format('[DataSync][Server] %s不存在', onPlayerLeaveEvent))
    onPlayerLeaveEvent:Connect(OnPlayerLeaveEventHandler)
end

--- 校验数据定义
function InitDefines()
    -- 定义数据所属
    MetaData.Host = MetaData.Enum.SERVER
    -- 定义服务器的两个数据
    Data.Global = {}
    Data.Players = {}
    -- 生成数据
    MetaData.CreateDataTable(DataScheme.Global, Data.Global, MetaData.NewGlobalData)
end

--! Event handler

--- 数据同步事件Handler
function DataSyncC2SEventHandler(_player, _type, _metaId, _key, _data)
    PrintLog(
        string.format(
            '收到 player = %s, type = %s, metaId = %s, key = %s, data = %s',
            _player,
            _type,
            _metaId,
            _key,
            table.dump(_data)
        )
    )
    if _type == MetaData.Enum.GLOBAL then
        --* 收到客户端改变数据的时候需要同步给其他玩家
        MetaData.SetServerGlobalData(_metaId, _key, _data, true)
    elseif _type == MetaData.Enum.PLAYER then
        MetaData.SetServerPlayerData(_player, _metaId, _key, _data)
    else
        error(
            string.format(
                '[DataSync][Server]  MetaData 数据类型错误 type = %s, metaId = %s, key = %s, data = %s',
                _type,
                _metaId,
                _key,
                table.dump(_data)
            )
        )
    end
end

--- 新玩家加入事件Handler
function OnPlayerJoinEventHandler(_player)
    --TODO: 重置玩家Counter

    --TODO: 获取长期存储

    -- 服务器端创建PlayerData
    local uid = _player.UserId
    Data.Players[uid] = {}
    MetaData.CreateDataTable(DataScheme.Player, Data.Players[uid], MetaData.NewPlayerData, _player)

    print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
    -- 向客户端同步PlayerData
    for k, v in pairs(Data.Players[uid]) do
        print(k, table.dump(v))
        -- Data.Players[uid][k] = v
    end

    -- 向客户端同步GlobalData
    for k, v in pairs(Data.Global) do
        Data.Global[k] = v
    end
end

--- 玩家离开事件Handler
function OnPlayerLeaveEventHandler(_player)
    --TODO 删除玩家Counter
    --TODO: 保存长期存储
    --TODO 删除玩家端数据
end

return ServerDataSync
