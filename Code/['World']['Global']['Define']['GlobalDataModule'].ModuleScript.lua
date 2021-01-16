--- 全局变量的定义,全部定义在GlobalData这张表下面,用于全局可修改的参数
--- @module GlobalData Defines
--- @copyright Lilith Games, Avatar Team
local GlobalData = {}
-- const
local MetaData = MetaData

-- set define 数据同步框架设置
ServerDataSync.SetGlobalDataDefine(GlobalData)
ClientDataSync.SetGlobalDataDefine(GlobalData)

-- 初始化
function GlobalData:Init()
    print('[GlobalData] Init()')
    DefineScheme()
end

-- 定义GlobalData的数据格式
function DefineScheme()
    GlobalData.Sync = MetaData.NewGlobalData({age = 12})
end

return GlobalData
