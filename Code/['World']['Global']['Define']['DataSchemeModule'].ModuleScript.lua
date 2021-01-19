--- 全局变量的定义
--- 定义在Data.Global和Data.Player的数据范式，用于全局可修改的参数
--- @module Data Scheme
--- @copyright Lilith Games, Avatar Team
local DataScheme = {}

-- -- Cache global vars
-- local MetaData = MetaData
-- local new = MetaData.NewGlobalData

-- -- set define 数据同步框架设置
-- ServerDataSync.SetGlobalDataDefine(GlobalData)
-- ClientDataSync.SetGlobalDataDefine(GlobalData)

DataScheme.Global = {
    a = 'A',
    b = 'B',
    c = {'C1', 'C2', 'C3'},
    d = {
        d1 = {d11 = 'D11', d12 = 'D12'},
        d2 = 'D2'
    },
    e = 'E',
    [5566] = {
        id = 1,
        type = '!!!!'
    }
}

DataScheme.Player = {
    -- 玩家属性
    attr = {
        uid = ''
    },
    -- 背包
    bag = {
        [1212] = {
            id = 1212,
            type = 12,
            count = 12,
            lastestTime = 0,
            isNew = true,
            isCount = true
        }
    },
    -- 小游戏相关
    mini = {},
    -- 统计数据
    stats = {}
}

-- -- 初始化
-- function GlobalData:Init()
--     print('[GlobalData] Init()')
--     InitScheme()
-- end

-- -- 定义GlobalData的数据格式
-- function InitScheme()
--     local meta = GenSchemeAux(scheme)
--     local mt = {
--         __index = meta,
--         __newindex = meta,
--         __pairs = MetaData.Pairs(getmetatable(meta).__index)
--     }
--     setmetatable(GlobalData, mt)
-- end

-- -- 生成Scheme的辅助函数
-- function GenSchemeAux(_define)
--     assert(_define, '[GlobalData] GenSchemeAux(), define为空')
--     if type(_define) == 'table' then
--         local meta = {}
--         for k, v in pairs(_define) do
--             meta[k] = GenSchemeAux(v)
--         end
--         return new(meta)
--     end
--     return _define
-- end

return DataScheme
