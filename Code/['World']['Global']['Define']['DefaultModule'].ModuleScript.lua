--- 全局默认定义：用于定义数据，节点属性等
--- @module Data Default
--- @copyright Lilith Games, Avatar Team
local Default = {}

--! 说明：这个module当作脚本使用

--* Data.Global和Data.Player中的默认值，用于框架初始化

Data.Default = Data.Default or {}

-- 全局变量定义
Data.Default.Global = {}

-- 玩家数据，初始化定义
Data.Default.Player = {
    -- 玩家属性
    attr = {
        uid = '',
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
        AnimState = 'Idle',
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

return Default
