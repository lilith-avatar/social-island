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
                return (a.weight < b.weight)
            end
        end
    )
    print(table.dump(tmpWeightTab))
    return tmpWeightTab
end

---初始化函数
function MoleHit:Init()
    this:DataInit()
    this:PitListInit()
    GetTotalWeights(Config.MoleConfig)
end

function MoleHit:DataInit()
    this.playerList = {}
    this.pitList = {}
    this.timer = 0
    this.refreshTime = Config.MoleGlobalConfig.RefreshTime --! Only Test
    this.refreshList = Config.MoleGlobalConfig.PlayerNumEffect
end

--绑定坑位
function MoleHit:PitListInit()
    for k, v in pairs(world.MoleHit:GetChildren()) do
        local data = {
            model = v,
            mole = nil
        }
        table.insert(this.pitList, data)
    end
end

function MoleHit:PlayerStartMoleHit(_uid)
    this.playerList[_uid] = {
        inGame = true
    }
end

function MoleHit:PlayerLeaveMoleHit(_uid)
    this.playerList[_uid] = nil
end

---根据玩家人数刷地鼠
function MoleHit:RefreshMole(_playerNum)
    --! only test
    local tmpTable = table.shallowcopy(this.pitList)
    local tmpRandomTab
    for i = 1, Config.MoleGlobalConfig.PlayerNumEffect[_playerNum] do
        tmpRandomTab = RandomSortByWeights(Config.MoleConfig)
        tmpTable[math.random(1, #tmpTable)].mole = tmpRandomTab[1].id
        --对象池管理
    end
end

local player
function MoleHit:PlayerHitEvent(_uid, _hitPit)
    if this.pitList[_hitPit].mole then
        player = world:GetPlayerByUserId(_uid)
        --对象池管理

        NetUtil.Fire_C(
            "AddScoreAndBoostEvent",
            player,
            Config.MoleConfig[this.pitList[_hitPit].mole].Type,
            Config.MoleConfig[this.pitList[_hitPit].mole].Reward,
            Config.MoleConfig[this.pitList[_hitPit].mole].BoostReward
        )
    end
end

---Update函数
function MoleHit:Update(dt, tt)
    if table.nums(this.playerList) ~= 0 then
        this.timer = this.timer + dt
        if this.timer >= this.refreshTime then
        --刷地鼠
        end
    end
end

return MoleHit
