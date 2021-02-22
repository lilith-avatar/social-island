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
    print("[MoleHit] Init()")
    this:DataInit()
    this:PitListInit()
    this:PoolInit()
    GetTotalWeights(Config.MoleConfig)
end

function MoleHit:DataInit()
    this.playerList = {}
    this.rangePlayer = {}
    this.pitList = {}
    this.moleList = {}
    this.timer = 0
    this.refreshTime = Config.MoleGlobalConfig.RefreshTime --! Only Test
    this.refreshList = Config.MoleGlobalConfig.PlayerNumEffect
    ---对象池表
    this.molePool = {}

    world.MiniGames.Game_02_WhackAMole.GameRange.OnCollisionBegin:Connect(
        function(_hitObject)
            if _hitObject.ClassName == "PlayerInstance" then
                --[[if this.rangePlayer[_hitObject.UserId] then
                    NetUtil.Fire_S('PlayerStartMoleHitEvent',_hitObject.UserId)
                end]]
                this.rangePlayer[_hitObject.UserId] = true
            --NetUtil.Fire_C('LeaveMoleGameRangeEvent', _hitObject)
            end
        end
    )

    world.MiniGames.Game_02_WhackAMole.GameRange.OnCollisionEnd:Connect(
        function(_hitObject)
            if _hitObject.ClassName == "PlayerInstance" then
                this.rangePlayer[_hitObject.UserId] = nil
                NetUtil.Fire_C("LeaveMoleGameRangeEvent", _hitObject)
            end
        end
    )
end

function MoleHit:PoolInit()
    for k, v in pairs(Config.MoleConfig) do
        this.molePool[k] = MolePool:new(v.Archetype, 10, v.ID)
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

function MoleHit:InteractSEventHandler(_player, _gameId)
    if _gameId == 2 then
    --NetUtil.Fire_C("StartMoleEvent", _player)
    end
end

function MoleHit:PlayerStartMoleHitEventHandler(_uid)
    local player = world:GetPlayerByUserId(_uid)
    this.playerList[_uid] = {
        inGame = true
    }
    print("PlayerStartMoleHitEvent")
    NetUtil.Fire_C("StartMoleEvent", player)
end

function MoleHit:PlayerLeaveMoleHitEventHandler(_uid)
    this.playerList[_uid] = nil
end

---根据玩家人数刷地鼠
function MoleHit:RefreshMole(_playerNum)
    local tmpTable = TransformTable(this.pitList)
    local tmpRandomTab, pitIndex, mole

    for i = 1, Config.MoleGlobalConfig.PlayerNumEffect.Value[_playerNum] do
        pitIndex, tmpRandomTab = math.random(1, #tmpTable), RandomSortByWeights(Config.MoleConfig)
        --删除该坑仍保留的地鼠
        for k, v in pairs(tmpTable[pitIndex].model:GetChildren()) do
            if v.ActiveSelf then
                v:Destroy()
            end
        end
        mole = {
            mole = this.molePool[tmpRandomTab[1].id]:Create(tmpTable[pitIndex].model, tmpRandomTab[1].id),
            pit = tmpTable[pitIndex].model.Name
        }
        this.pitList[tmpTable[pitIndex].model.Name].mole = mole.mole
        table.insert(this.moleList, mole)
        table.remove(tmpTable, pitIndex)
    end
end

local player
function MoleHit:PlayerHitEventHandler(_uid, _hitPit)
    for k, _ in pairs(_hitPit) do
        if this.pitList[k] and this.pitList[k].mole and not this.pitList[k].mole:IsDestroy() then
            player = world:GetPlayerByUserId(_uid)
            this.pitList[k].mole:BeBeaten(player)
            local effect = world:CreateInstance("MoleBeatEffect", "Effect", this.pitList[k].model)
            effect.Position = this.pitList[k].model.Position
            invoke(
                function()
                    effect:Destroy()
                end,
                0.7
            )
        end
    end
end

function MoleHit:EnterMiniGameEventHandler(_player, _gameId)
    if _gameId == 2 then
        if this.rangePlayer[_player.UserId] then
            NetUtil.Fire_S("PlayerStartMoleHitEvent", _player.UserId)
        end
        this.rangePlayer[_player.UserId] = true
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
        -- 每个老鼠的单独计时,若状态为Destroy，则放回到对应的池子中
        for k, v in pairs(this.moleList) do
            v.mole:StartTimer(dt)
            if v.mole:IsDestroy() then
                this.molePool[v.mole.moleId]:Destroy(v.mole)
                this.pitList[v.pit].mole = nil
                -- 将该对象移出存在的池子
                table.remove(this.moleList, k)
            end
        end
    end
end

return MoleHit
