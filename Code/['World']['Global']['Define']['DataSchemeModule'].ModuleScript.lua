--- 全局变量的定义
--- 定义在Data.Global和Data.Player的数据范式，用于全局可修改的参数
--- @module Data Scheme
--- @copyright Lilith Games, Avatar Team
local DataScheme = {}

-- 全局变量定义
DataScheme.Global = {
    a = "A",
    b = "B",
    c = {"C1", "C2", "C3"},
    d = {
        d1 = {
            d11 = "D11",
            d12 = "D12"
        },
        d2 = "D2"
    },
    e = "E",
    [5566] = {
        id = 1,
        type = "!!!!"
    }
}

-- 玩家数据定义
DataScheme.Player = {
    -- 玩家属性
    attr = {
        uid = "",
        AvatarHeight = 1,
        AvatarHeadSize = 1,
        AvatarWidth = 1,
        HeadEffect = {},
        BodyEffect = {},
        FootEffect = {},
        WalkSpeed = 6,
        JumpUpVelocity = 8,
        GravityScale = 2,
        SkinID = 0,
        AnimState = "Idle",
        EnableEquipable = true
    },
    coin = 0,
    -- 背包
    bag = {},
    -- 小游戏相关
    mini = {},
    -- 统计数据
    stats = {}
}

return DataScheme
