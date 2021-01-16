--- 游戏客户端数据同步
--- @module Client Sync Data, Client-side
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local ClientDataSync = {}

-- Localize global vars
local FrameworkConfig = FrameworkConfig
local MetaData = MetaData

-- 数据定义格式: 全局数据, 玩家数据
local GLOBAL_DATA_DEFINE, PLAYER_DATA_DEFINE

--- 打印数据同步日志
local PrintLog = FrameworkConfig.DebugMode and function(...)
        print('[DataSync][Client]', ...)
    end or function()
    end

-- 客户端本地数据: 全局数据, 玩家数据
local globalCache = {}
local playerCache = {}

--! 初始化

--- 数据初始化
function ClientDataSync.Init()
    print('[DataSync][Client] Init()')
    InitEventsAndListeners()
    InitDefines()
end

--- 校验数据定义
function InitDefines()
    -- 定义数据所属
    MetaData.Host = MetaData.Enum.CLIENT
    -- 数据校验
    assert(
        GLOBAL_DATA_DEFINE and type(GLOBAL_DATA_DEFINE) == 'table',
        '[DataSync][Client] 全局数据定义有误，请检查 FrameworkConfig.GlobalDataDefine'
    )
    assert(
        PLAYER_DATA_DEFINE and type(PLAYER_DATA_DEFINE) == 'table',
        '[DataSync][Client] 玩家数据定义有误，请检查 FrameworkConfig.PlayerDataDefine'
    )
end

--- 初始化事件和绑定Handler
function InitEventsAndListeners()
    if localPlayer.C_Event == nil then
        world:CreateObject('FolderObject', 'S_Event', localPlayer)
    end
    world:CreateObject('CustomEvent', 'DataSyncS2CEvent', localPlayer.C_Event)
    localPlayer.C_Event.DataSyncS2CEvent:Connect(DataSyncS2CEventHandler)
end

--! 外部接口

--- 定义全局数据
function ClientDataSync.SetGlobalDataDefine(_define)
    GLOBAL_DATA_DEFINE = _define
end

--- 定义玩家数据
function ClientDataSync.SetPlayerDataDefine(_define)
    PLAYER_DATA_DEFINE = _define
end

--! Event handler

--- 数据同步事件Handler
function DataSyncS2CEventHandler(_type, _table, _key, _data)
    PrintLog(string.format('收到 player = %s, type = %s, key = %s, data = %s', localPlayer, _table, _key, _data))
    if _type == MetaData.Enum.GLOBAL then
        MetaData.SetClientGlobalData(_table, _key, _data)
    elseif _type == MetaData.Enum.PLAYAER then
        --TODO:
        MetaData.SetClientPlayerData(_table, _key, _data)
    else
        error(
            string.format(
                '[DataSync][Client]  MetaData 数据类型错误 type = %s, table = %s, key = %s, data = %s',
                _type,
                _table,
                _key,
                table.dump(_data)
            )
        )
    end
end

return ClientDataSync
