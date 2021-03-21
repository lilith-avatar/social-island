--- This file is generated by ava-x2l.exe,
--- Don't change it manaully.
--- @copyright Lilith Games, Project Da Vinci(Avatar Team)
--- @see https://www.projectdavinci.com/
--- @see https://github.com/endaye/avatar-ava-xls2lua
--- source file: .//GameHunting.xlsm

local AnimalXls = {
    [1] = {
        ID = 1,
        Name = '麋鹿',
        ArchetypeName = 'Animal_Reindeer',
        DefMoveSpeed = 12.0,
        ScaredMoveSpeed = 18.0,
        IdleAnimationName = {'Idle', 'Idle02'},
        IdleAnimationDurRange = {5, 20},
        MoveAnimationName = {'Run'},
        MoveAnimationDurRange = {2, 4},
        DeadAnimationName = {'Dead'},
        HitAEID = 45,
        DeadAEID = 46,
        Weight = 8,
        LVCtrlIntensity = 1000000,
        RotCtrlIntensity = 1000000,
        ItemPoolID = 1,
        DropCoin = 62,
        CaughtRate = 0.1
    },
    [2] = {
        ID = 2,
        Name = '黄野猪',
        ArchetypeName = 'Animal_Boar001',
        DefMoveSpeed = 5.0,
        ScaredMoveSpeed = 10.0,
        IdleAnimationName = {'Idle', 'Idle2'},
        IdleAnimationDurRange = {5, 20},
        MoveAnimationName = {'Walk'},
        MoveAnimationDurRange = {2, 4},
        DeadAnimationName = {'Dead'},
        HitAEID = 48,
        DeadAEID = 49,
        Weight = 10,
        LVCtrlIntensity = 300000,
        RotCtrlIntensity = 500000,
        ItemPoolID = 4,
        DropCoin = 50,
        CaughtRate = 0.2
    },
    [3] = {
        ID = 3,
        Name = '黑野猪',
        ArchetypeName = 'Animal_Boar002',
        DefMoveSpeed = 5.0,
        ScaredMoveSpeed = 10.0,
        IdleAnimationName = {'Idle', 'Idle2'},
        IdleAnimationDurRange = {5, 20},
        MoveAnimationName = {'Walk'},
        MoveAnimationDurRange = {2, 4},
        DeadAnimationName = {'Dead'},
        HitAEID = 48,
        DeadAEID = 49,
        Weight = 5,
        LVCtrlIntensity = 300000,
        RotCtrlIntensity = 500000,
        ItemPoolID = 3,
        DropCoin = 100,
        CaughtRate = 0.05
    },
    [4] = {
        ID = 4,
        Name = '猫头鹰',
        ArchetypeName = 'Animal_Owl',
        DefMoveSpeed = 1.5,
        ScaredMoveSpeed = 3.0,
        IdleAnimationName = {'Idle', 'Idle2'},
        IdleAnimationDurRange = {5, 20},
        MoveAnimationName = {'Walk'},
        MoveAnimationDurRange = {2, 6},
        DeadAnimationName = {'Dead'},
        HitAEID = 53,
        DeadAEID = 54,
        Weight = 4,
        LVCtrlIntensity = 12000000,
        RotCtrlIntensity = 240000,
        ItemPoolID = 5,
        DropCoin = 125,
        CaughtRate = 0.04
    },
    [5] = {
        ID = 5,
        Name = '山鸡',
        ArchetypeName = 'Animal_Pheasant',
        DefMoveSpeed = 1.5,
        ScaredMoveSpeed = 4.0,
        IdleAnimationName = {'Idle', 'Idle2'},
        IdleAnimationDurRange = {5, 20},
        MoveAnimationName = {'Walk'},
        MoveAnimationDurRange = {1, 3},
        DeadAnimationName = {'Dead'},
        HitAEID = 47,
        DeadAEID = 48,
        Weight = 15,
        LVCtrlIntensity = 500000,
        RotCtrlIntensity = 1000000,
        ItemPoolID = 2,
        DropCoin = 33,
        CaughtRate = 0.2
    },
    [6] = {
        ID = 6,
        Name = '棕熊',
        ArchetypeName = 'Animal_Bear',
        DefMoveSpeed = 3.0,
        ScaredMoveSpeed = 6.0,
        IdleAnimationName = {'Idle', 'Idle2'},
        IdleAnimationDurRange = {5, 20},
        MoveAnimationName = {'Walk'},
        MoveAnimationDurRange = {1, 4},
        DeadAnimationName = {'Dead'},
        HitAEID = 57,
        DeadAEID = 58,
        Weight = 3,
        LVCtrlIntensity = 800000,
        RotCtrlIntensity = 1000000,
        ItemPoolID = 6,
        DropCoin = 166,
        CaughtRate = 0.0
    },
    [7] = {
        ID = 7,
        Name = '灰狼',
        ArchetypeName = 'Animal_Wolf',
        DefMoveSpeed = 3.0,
        ScaredMoveSpeed = 8.0,
        IdleAnimationName = {'Idle', 'Idle2'},
        IdleAnimationDurRange = {5, 20},
        MoveAnimationName = {'Walk'},
        MoveAnimationDurRange = {2, 4},
        DeadAnimationName = {'Dead'},
        HitAEID = 48,
        DeadAEID = 49,
        Weight = 6,
        LVCtrlIntensity = 500000,
        RotCtrlIntensity = 1000000,
        ItemPoolID = 7,
        DropCoin = 83,
        CaughtRate = 0.02
    },
    [8] = {
        ID = 8,
        Name = '蜗牛',
        ArchetypeName = 'Animal_Snail',
        DefMoveSpeed = 1.0,
        ScaredMoveSpeed = 1.5,
        IdleAnimationName = {'Idle'},
        IdleAnimationDurRange = {5, 20},
        MoveAnimationName = {'Move'},
        MoveAnimationDurRange = {4, 8},
        DeadAnimationName = {'Dead'},
        HitAEID = nil,
        DeadAEID = nil,
        Weight = 30,
        LVCtrlIntensity = 1600000,
        RotCtrlIntensity = 40000,
        ItemPoolID = 8,
        DropCoin = 16,
        CaughtRate = 0.3
    }
}

return AnimalXls
