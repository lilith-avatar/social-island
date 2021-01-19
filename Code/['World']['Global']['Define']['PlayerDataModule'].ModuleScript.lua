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

local scheme = {
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

-- 初始化
function PlayerData:Init()
    print('[PlayerData] Init()')
    -- InitScheme()
end

-- 定义GlobalData的数据格式
function InitScheme()
    local meta = GenSchemeAux(scheme)
    local mt = {
        __index = meta,
        __newindex = meta,
        __pairs = MetaData.Pairs(getmetatable(meta).__index)
    }
    setmetatable(PlayerData, mt)
end

-- 生成Scheme的辅助函数
function GenSchemeAux(_define)
    assert(_define, '[PlayerData] GenSchemeAux, define为空')
    if type(_define) == 'table' then
        local meta = {}
        for k, v in pairs(_define) do
            meta[k] = GenSchemeAux(v)
        end
        return new(meta)
    end
    return _define
end

return PlayerData
