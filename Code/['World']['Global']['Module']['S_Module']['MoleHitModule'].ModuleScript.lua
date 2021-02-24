---@module MoleHit
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local MoleHit, this = ModuleUtil.New("MoleHit", ServerBase)
local totalWeights = 0

---得到总权重
local function GetTotalWeights(_moleConfig)
end

---随机权重排序
local function RandomSortByWeights(_moleConfig)
end

local function TransformTable(_table)
end

---初始化函数
function MoleHit:Init()
    print("[MoleHit] Init()")
    this:DataInit()
    this:PitListInit()
    this:PoolInit()
end

function MoleHit:DataInit()
    this.hitNum = {
        ufo = 0,
        maze = 0
    }
    --TODO： 读表
    this.hitNum = {
        ufo = 100,
        maze = 100
    }
end

function MoleHit:PoolInit()
    for k, v in pairs(Config.MoleConfig) do
        this.molePool[k] = MolePool:new(v.Archetype, 10, v.ID)
    end
end

--选定坑位
function MoleHit:PitListInit()
    -- ufo坑位
    -- maze坑位
end

function MoleHit:RefreashMole()
end

function MoleHit:InteractSEventHandler(_player, _gameId)
    if _gameId == 2 then
    end
end

local player
function MoleHit:PlayerHitEventHandler(_uid, _mole)
end

function MoleHit:EnterMiniGameEventHandler(_player, _gameId)
    if _gameId == 2 then
    end
end

return MoleHit
