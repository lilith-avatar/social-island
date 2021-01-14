--- 游戏服务器数据同步
--- @module Server Sync Data, Server-side
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local ServerDataSync = {}

--- 数据初始化
function ServerDataSync.Init()
    print('[DataSync][Server] Init()')
    InitEventsAndListeners()
end

--- 初始化事件和绑定Handler
function InitEventsAndListeners()
    if world.S_Event == nil then
        world:CreateObject('FolderObject', 'S_Event', world)
    end
    world:CreateObject('CustomEvent', 'DataSyncC2SEvent', world.S_Event)
    world.S_Event.DataSyncC2SEvent:Connect(DataSyncC2SHandler)
end

--- 数据同步事件Handler
function DataSyncC2SHandler(_player, _key, _data)
    print('ssssssssssssssssssssssssssssssssssssss')
    print(_player, _key, _data)
end

return ServerDataSync
