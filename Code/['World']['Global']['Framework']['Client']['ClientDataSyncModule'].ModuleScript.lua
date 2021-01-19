--- 游戏客户端数据同步
--- @module Client Sync Data, Client-side
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local ClientDataSync = {}

-- Localize global vars
local FrameworkConfig = FrameworkConfig
local MetaData = MetaData

--- 打印数据同步日志
local PrintLog = FrameworkConfig.DebugMode and function(...)
        print('[DataSync][Client]', ...)
    end or function()
    end

--! 初始化

--- 数据初始化
function ClientDataSync.Init()
    print('[DataSync][Client] Init()')
    InitEventsAndListeners()
    InitDefines()
end

--- 初始化事件和绑定Handler
function InitEventsAndListeners()
    if localPlayer.C_Event == nil then
        world:CreateObject('FolderObject', 'S_Event', localPlayer)
    end
    world:CreateObject('CustomEvent', 'DataSyncS2CEvent', localPlayer.C_Event)
    localPlayer.C_Event.DataSyncS2CEvent:Connect(DataSyncS2CEventHandler)
end

--- 校验数据定义
function InitDefines()
    -- 定义数据所属
    MetaData.Host = MetaData.Enum.CLIENT
    -- 定义客户端的两个数据
    Data.Global = {}
    Data.Player = {}
    -- 生成数据
    MetaData.InitDataTable(DataScheme.Global, Data.Global, MetaData.NewGlobalData)
    -- MetaData.InitDataTable(DataScheme.Player, Data.Player, MetaData.NewPlayerData)
end

--! Event handler

--- 数据同步事件Handler
function DataSyncS2CEventHandler(_type, _metaId, _key, _data)
    PrintLog(
        string.format(
            '收到 player = %s, type = %s, metaId = %s, key = %s, data = %s',
            localPlayer,
            _type,
            _metaId,
            _key,
            _data
        )
    )
    if _type == MetaData.Enum.GLOBAL then
        MetaData.SetClientGlobalData(_metaId, _key, _data)
    elseif _type == MetaData.Enum.PLAYAER then
        MetaData.SetClientPlayerData(_metaId, _key, _data)
    else
        error(
            string.format(
                '[DataSync][Client]  MetaData 数据类型错误 type = %s, metaId = %s, key = %s, data = %s',
                _type,
                _metaId,
                _key,
                table.dump(_data)
            )
        )
    end
end

return ClientDataSync
