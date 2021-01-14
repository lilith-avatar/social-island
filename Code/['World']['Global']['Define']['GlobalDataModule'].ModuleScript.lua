--- 全局变量的定义,全部定义在GlobalData这张表下面,用于全局可修改的参数
--- @module GlobalData Defines
--- @copyright Lilith Games, Avatar Team
local GlobalData = {}

-- const
local MetaData = MetaData

-- set define 数据同步框架设置
ClientDataSync.SetGlobalDataDefine(GlobalData)
ServerDataSync.SetGlobalDataDefine(GlobalData)

GlobalData.Sync = MetaData.New({age = 12})

return GlobalData
