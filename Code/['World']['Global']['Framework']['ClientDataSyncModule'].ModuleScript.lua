--- 游戏客户端数据同步
--- @module Client Sync Data, Client-side
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local ClientDataSync = {}

--- 数据初始化
function ClientDataSync.Init()
    InitEventsAndListeners()
end

--- 初始化事件和绑定Handler
function InitEventsAndListeners()
    if localPlayer.C_Event == nil then
        world:CreateObject('FolderObject', 'S_Event', localPlayer)
    end
    world:CreateObject('CustomEvent', 'DataSyncS2CEvent', localPlayer.C_Event)
    localPlayer.C_Event.DataSyncS2CEvent:Connect(DataSyncS2CHandler)
end

--- 数据同步事件Handler
function DataSyncS2CHandler(_key, _data)
    print('cccccccccccccccccccccccccccccccccccccc')
    print(localPlayer, _key, _data)
end

return ClientDataSync
