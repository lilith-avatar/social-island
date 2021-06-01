--- 全局常量的定义,全部定义在Const这张表下面,用于定义全局常量参数或者枚举类型
-- @module Constant Defines
-- @copyright Lilith Games, Avatar Team
local Const = {}

-- e.g. (need DELETE)
Const.MAX_PLAYERS = 4

-- 语言枚举
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

-- 交互枚举
Const.InteractEnum = {
    Def = 0,
    Hunt = 1,
    WhackAMole = 2,
    Maze = 3,
    Cannon = 4,
    Frog = 5,
    Zeppelin = 6,
    Flower = 7,
    Snail = 8,
    Race = 9,
    Chair = 10,
    MonsterArena = 11,
    NPC = 12,
    ScenesInteract = 13,
    TelescopeInteract = 14,
    SeatInteract = 15,
    BonfireInteract = 16,
    BounceInteract = 17,
    GrassInteract = 18,
    CaughtAnimal = 19,
    Trojan = 20,
    Guitar = 21,
    Tent = 22,
    Bomb = 23,
    Radio = 24,
    Buble = 25,
    Cook = 26,
    EatFood = 27,
    Lotus = 28,
    MapInteract = 29
}

Const.SeatStateEnum = {
    Disable = 0,
    Free = 1,
    Used = 2
}
---PC端交互按键
Const.KeyEnum = {
    FORWARD_KEY = Enum.KeyCode.W,
    BACK_KEY = Enum.KeyCode.S,
    LEFT_KEY = Enum.KeyCode.A,
    RIGHT_KEY = Enum.KeyCode.D
}

---元素类型
Const.ElementsTypeEnum = {
    Poker = 1,
    Dice = 2,
    Counter = 3,
    UnlimitedStack = 9999,
}

---操作模式
Const.ControlModeEnum = {
	None = 0,
	Select = 1,
	Split = 2,
	Rotate = 3,
	Camera = 4,
	Pile = 5
}

---玩家游戏状态
Const.GamingStateEnum = {
    Watching = 1,
    Gaming = 2,
}

---玩家游戏动画枚举
Const.GameAniEnum = {
    Select = 1,
    Cancel = 2,
    InHand = 3,
    OutHand = 4,
}
return Const
