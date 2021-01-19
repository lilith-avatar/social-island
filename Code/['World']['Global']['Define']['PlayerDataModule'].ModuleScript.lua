--- 玩家数据模块
--- @module Player Data Manager
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local PlayerData = {}

-- const
local MetaData = MetaData
local new = MetaData.NewPlayerData

-- set define 数据同步框架设置
ClientDataSync.SetPlayerDataDefine(PlayerData)
ServerDataSync.SetPlayerDataDefine(PlayerData)

function PlayerData:Init()
    print('[PlayerData] Init()')
end

return PlayerData
