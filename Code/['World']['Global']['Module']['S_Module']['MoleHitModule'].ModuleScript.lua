---@module MoleHit
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local MoleHit, this = ModuleUtil.New("MoleHit", ServerBase)
local totalWeights = 0

---得到总权重
local function GetTotalWeights(_moleConfig)
    for _, v in pairs(_moleConfig) do
        totalWeights = totalWeights + v.Weight
    end
end

---随机权重排序
local function RandomSortByWeights(_moleConfig)
    local tmpWeightTab = {}
    for _, v in pairs(_moleConfig) do
        local data = {
            id = v.ID,
            weight = v.Weight + math.random(0, totalWeights)
        }
        table.insert(tmpWeightTab, data)
    end
    --进行排序
    table.sort(
        tmpWeightTab,
        function(a, b)
            if a and b then
                return (a.weight > b.weight)
            end
        end
    )
    return tmpWeightTab
end

local function TransformTable(_table)
    local final = {}
    for k, v in pairs(_table) do
        table.insert(final, v)
    end
    return final
end

---初始化函数
function MoleHit:Init()
    print("MoleHit: Init")
    this:DataInit()
    this:PitListInit()
    this:PoolInit()
    GetTotalWeights(Config.MoleConfig)
end

function MoleHit:DataInit()
    this.playerList = {}
    this.pitList = {}
    this.timer = 0
    this.refreshTime = Config.MoleGlobalConfig.RefreshTime --! Only Test
    this.refreshList = Config.MoleGlobalConfig.PlayerNumEffect
    ---对象池表
    this.molePool = {}
end

function MoleHit:PoolInit()
    for k, v in pairs(Config.MoleConfig) do
        this.molePool[k] = MolePool:new(v.Archetype, 10)
    end
end

--绑定坑位
function MoleHit:PitListInit()
    for k, v in pairs(world.MiniGames.Game_02_WhackAMole.Pits:GetChildren()) do
        this.pitList[v.Name] = {
            model = v,
            mole = nil
        }
    end
end

function MoleHit:EnterMiniGameEventHandler(_player, _gameId)
    if _gameId == 2 then
        NetUtil.Fire_C("StartMoleEvent", _player)
    end
end

function MoleHit:PlayerStartMoleHitEventHandler(_uid)
    this.playerList[_uid] = {
        inGame = true
    }
end

function MoleHit:PlayerLeaveMoleHitEventHandler(_uid)
    this.playerList[_uid] = nil
end

---根据玩家人数刷地鼠
function MoleHit:RefreshMole(_playerNum)
    local tmpTable = TransformTable(this.pitList)
    local tmpRandomTab
    --! only test
    --清除现有的地鼠
    for k, v in pairs(this.pitList) do
        if v.model.Mole then
            v.model.Mole:Destroy()
            v.mole = nil
        end
    end

    for i = 1, Config.MoleGlobalConfig.PlayerNumEffect.Value[_playerNum] do
        local pitIndex = math.random(1, #tmpTable)
        tmpRandomTab = RandomSortByWeights(Config.MoleConfig)
        tmpTable[pitIndex].mole = tmpRandomTab[1].id
        --Todo: 对象池
        local mole = this.molePool[tmpRandomTab[1].id]:Create(tmpTable[pitIndex].model,tmpTable[pitIndex].model.Position,tmpTable[pitIndex].model.Rotation)
        invoke(
            function()
                if mole then
                    --Todo: 对象池销毁
                    this.molePool[tmpRandomTab[1].id]:Destroy(mole)
                end
            end,
            Config.MoleConfig[tmpRandomTab[1].id].KeepTime
        )
        table.remove(tmpTable, pitIndex)
    end
end

local player
function MoleHit:PlayerHitEventHandler(_uid, _hitPit)
    for k, _ in pairs(_hitPit) do
        if this.pitList[k] and this.pitList[k].mole and this.pitList[k].model.Mole then
            player = world:GetPlayerByUserId(_uid)
            NetUtil.Fire_C(
                "AddScoreAndBoostEvent",
                player,
                Config.MoleConfig[this.pitList[k].mole].Type,
                Config.MoleConfig[this.pitList[k].mole].Reward,
                Config.MoleConfig[this.pitList[k].mole].BoostReward
            )
            this.pitList[k].model.Mole:Destroy()
            this.pitList[k].mole = nil
        end
    end
end

---Update函数
function MoleHit:Update(dt, tt)
    if table.nums(this.playerList) ~= 0 then
        this.timer = this.timer + dt
        if this.timer >= this.refreshTime.Value then
            this.timer = 0
            MoleHit:RefreshMole(table.nums(this.playerList) + 1)
        end
    end
end

return MoleHit
