---@module MoleHit
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local MoleHit, this = ModuleUtil.New('MoleHit', ServerBase)

local function SelectPit(_pitList, _num)
    local tmpPits = table.deepcopy(_pitList)
    local returnList = {}
    for i = 1, _num do
        local randomIndex = math.random(1, #tmpPits)
        table.insert(returnList, tmpPits[randomIndex])
        table.remove(tmpPits, randomIndex)
    end
    return returnList
end

local tmpRange, totalWeight
local function SortDropCoinByWeight(_DropCoinRange)
    tmpRange, totalWeight = {}, 0
    if totalWeight == 0 then
        for k, v in pairs(_DropCoinRange) do
            totalWeight = totalWeight + v.weight
        end
    end
    for k, v in pairs(_DropCoinRange) do
        local data = {
            index = k,
            weight = v.weight + math.random(0, totalWeight)
        }
        table.insert(tmpRange, data)
    end
    table.sort(
        tmpRange,
        function(t1, t2)
            return t1.weight > t2.weight
        end
    )
    return tmpRange[1]
end

---初始化函数
function MoleHit:Init()
    --print('[MoleHit] Init()')
    this:DataInit()
    this:NodeDef()
    this:PoolInit()
    this:RefreashMole('ufo')
    this:RefreashMole('maze')
end

function MoleHit:DataInit()
    this.startUpdate = false
    this.RefreshList = {}
    this.molePool = {
        ufo = {},
        maze = {}
    }
    this.pitList = {
        ufo = {},
        maze = {}
    }
    this.hitTime = 0
    -- 读表
    this.hitNum = 15
    this.bonusScene = {
        ufo = function()
            UFOMgr:ActiveUFO()
        end,
        maze = function()
            for _, p in pairs(world:FindPlayers()) do
                NetUtil.Fire_S('EnterMiniGameEvent', p, Const.GameEnum.MAZE)
            end
        end
    }
end

function MoleHit:NodeDef()
    this.pitFolder = {
        ufo = world.MiniGames.Game_02_WhackAMole.Pits.ufo:GetChildren(),
        maze = world.MiniGames.Game_02_WhackAMole.Pits.maze:GetChildren()
    }
end

function MoleHit:PoolInit()
    for k, v in pairs(Config.MoleConfig) do
        this.molePool[v.Type] = MolePool:new(v.Archetype, 20, v.ID)
    end
end

function MoleHit:RefreashMole(_type)
    this.pitList[_type] = SelectPit(this.pitFolder[_type], math.floor(this.hitNum / 2) + 3)
    -- 遍历对应坑位
    for k, v in pairs(this.pitList[_type]) do
        v.Mole:SetActive(true)
        -- 绑定碰撞事件
        v.OnCollisionBegin:Connect(
            function(_hitObject)
                if _hitObject and _hitObject.Avatar and _hitObject.Avatar.ClassName == 'PlayerAvatarInstance' then
                    NetUtil.Fire_C(
                        'GetMolePriceEvent',
                        _hitObject,
                        Config.MoleConfig[this.molePool[_type].objId].MoneyNum,
                        _type,
                        v,
                        this.hitNum - this.hitTime
                    )
                    NetUtil.Fire_C('OpenDynamicEvent', _hitObject, 'Interact', 2)
					NetUtil.Fire_C('OutlineCtrlEvent', _hitObject,v,true)
                end
            end
        )
        v.OnCollisionEnd:Connect(
            function(_hitObject)
                if _hitObject and _hitObject.Avatar and _hitObject.Avatar.ClassName == 'PlayerAvatarInstance' then
                    NetUtil.Fire_C('ChangeMiniGameUIEvent', _hitObject)
					NetUtil.Fire_C('OutlineCtrlEvent', _hitObject,v,false)
                end
            end
        )
    end
end

-- 日夜交替
function MoleHit:DayAndNightChange(_dayOrNight)
end

local player
local getItemList = {}
--- 玩家击中地鼠事件
function MoleHit:PlayerHitEventHandler(_uid, _type, _pit)
    player = world:GetPlayerByUserId(_uid)
    getItemList[_uid] = {}
    this:HitMoleAction(_uid, _type, _pit)
    -- 抽奖
    local coinNum =
        Config.MoleGlobalConfig.DropCoinRange.Value[
        SortDropCoinByWeight(Config.MoleGlobalConfig.DropCoinRange.Value).index
    ].num
    NetUtil.Fire_S('SpawnCoinEvent', 'P', _pit.Position + Vector3.Up, math.floor(coinNum), 12)
    -- 增加数量
    this.hitTime = this.hitTime + 1
    -- 发送全局通知
    NetUtil.Broadcast('InsertInfoEvent', this.hitTime .. '/15', 2, false)
    for i = 1, math.random(1, 3) do
        table.insert(getItemList[_uid], this:MoleItemPool(9, player))
    end
    NetUtil.Fire_C('GetMoleRewardEvent', player, getItemList[_uid],coinNum)
    -- 判断是否达到彩蛋条件
    if this.hitTime >= this.hitNum then
        this.startUpdate, this.hitTime = true, 0
        -- 先关闭所有地鼠
        this:DestroyAllMole()
        -- 关闭特效
        _pit.Effect:SetActive(false)
        this.RefreshList[_type] = {
            timer = 0
        }
        -- 随机开启彩蛋
        this.bonusScene[math.random(1, 2) == 1 and 'ufo' or 'maze']()
    end
end

function MoleHit:MoleItemPool(_poolID, _player)
    if _poolID ~= 0 then
        local tempTable = {}
        for k, v in pairs(Config.ItemPool[_poolID]) do
            if
                Data.Players[_player.UserId].bag[v.ItemId] and
                    Config.ItemType[Config.Item[v.ItemId].Type].IsGetRepeatedly == false
             then
            else
                tempTable[k] = v
            end
        end
        local weightSum = 0
        for _, v in pairs(tempTable) do
            weightSum = weightSum + v.Weight
        end
        local randomNum = math.random(weightSum)
        local tempWeightSum = 0
        for _, v in pairs(tempTable) do
            tempWeightSum = tempWeightSum + v.Weight
            if randomNum < tempWeightSum then
                NetUtil.Fire_C('GetItemEvent', _player, v.ItemId)
                return v.ItemId
            end
        end
    end
end

function MoleHit:DestroyAllMole()
    for k, v in pairs(this.pitList.maze) do
        v.Mole:SetActive(false)
        v.Mole.Mole.Block = false
        v.OnCollisionBegin:Clear()
        v.OnCollisionEnd:Clear()
    end
    for k, v in pairs(this.pitList.ufo) do
        v.Mole:SetActive(false)
        v.Mole.Mole.Block = false
        v.OnCollisionBegin:Clear()
        v.OnCollisionEnd:Clear()
    end
end

function MoleHit:HitMoleAction(_uid, _type, _pit)
    -- 打击表现
	local hitPlayer = world:GetPlayerByUserId(_uid)
    _pit.Effect:SetActive(true)
    _pit.Mole.Mole.Block = false
	NetUtil.Fire_C('OutlineCtrlEvent', hitPlayer,_pit,false)
    local tweener = Tween:ShakeProperty(_pit.Mole, {'Rotation'}, 0.8, 30)
    tweener:Play()
    invoke(
        function()
            -- 摧毁地鼠
            _pit.Mole:SetActive(false)
            _pit.Mole.Mole.Block = false
            -- 关闭特效
            _pit.Effect:SetActive(false)
        end,
        1
    )
    SoundUtil.Play3DSE(_pit.Mole.Position, 116)
    --解除绑定
    _pit.OnCollisionBegin:Clear()
    _pit.OnCollisionEnd:Clear()
end

function MoleHit:Update(dt)
    if this.startUpdate then
        for k, v in pairs(this.RefreshList) do
            v.timer = v.timer + dt
            if v.timer >= Config.MoleGlobalConfig.RefreshTime.Value then
                this:RefreashMole(k)
                this.RefreshList[k] = nil
            end
        end
    end
end

return MoleHit
