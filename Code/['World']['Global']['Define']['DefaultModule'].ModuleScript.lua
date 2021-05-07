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
    -- 玩家ID, 框架默认
    uid = '',
    -- 玩家属性
    attr = {
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
        EnableEquipable = true
    },
    coin = 0,
    -- 背包
    bag = {},
    -- 装备
    curEquipmentID = 0,
    -- 宠物
    petID = 0,
    petName = '',
    -- 小游戏相关
    mini = {},
    -- 统计数据
    stats = {}
}

return Default
