--- 全局常量的定义,全部定义在Const这张表下面,用于定义全局常量参数或者枚举类型
-- @module Constant Defines
-- @copyright Lilith Games, Avatar Team
local Const = {}

-- e.g. (need DELETE)
Const.MAX_PLAYERS = 4

--语言枚举
Const.LanguageEnum = {
    CHS = 'CHS', -- 简体中文
    CHT = 'CHT', -- 繁体中文
    EN = 'EN', -- 英文
    JP = 'JP' -- 日文
}

-- Game ID 常量，请小游戏作者陆续添加
Const.GameEnum = {
    MAZE = 3
}

Const.MazeEventEnum = {
    JOIN = 1, -- 进入游戏
    FINISH = 2, -- 完成游戏退出
    QUIT = 3 -- 中途退出
}

Const.MonsterEnum = {
    NEWROUND = 1,
    SKILLTIME = 2,
    SHOWSKILL = 3,
    BEHIT = 4,
    OVER = 5,
    NPCBEHIT = 6
}

-- NPC状态
Const.NpcState = {
    IDLE = 1, -- 闲置
    SEE_PLAYER = 2, -- 看见玩家
    TALKING = 3 -- 和玩家对话
}

return Const
