---@module MoleHit
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local MoleHit, this = ModuleUtil.New("MoleHit", ServerBase)

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
    for k, v in pairs(_DropCoinRange) do
        totalWeight = totalWeight + v.weight
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
    print("[MoleHit] Init()")
    this:DataInit()
    this:NodeDef()
    this:PoolInit()
    this:RefreashMole("ufo")
    this:RefreashMole("maze")
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
    this.hitTime = {
        ufo = 0,
        maze = 0
    }
    -- 读表
    this.hitNum = {
        ufo = Config.MoleGlobalConfig.UFOPitNum.Value,
        maze = Config.MoleGlobalConfig.MazePitNum.Value
    }
    this.bonusScene = {
        ufo = function()
            UFOMgr:ActiveUFO()
        end,
        maze = function()
            NetUtil.Fire_S("EnterMiniGameEvent", localPlayer, Const.GameEnum.MAZE)
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
    this.pitList[_type] = SelectPit(this.pitFolder[_type], this.hitNum[_type])
    -- 遍历对应坑位
    for k, v in pairs(this.pitList[_type]) do
        v.Mole:SetActive(true)
        -- 绑定碰撞事件
        v.OnCollisionBegin:Connect(
            function(_hitObject)
                if _hitObject and _hitObject.Avatar and _hitObject.Avatar.ClassName == "PlayerAvatarInstance" then
                    NetUtil.Fire_C(
                        "GetMolePriceEvent",
                        _hitObject,
                        Config.MoleConfig[this.molePool[_type].objId].MoneyNum,
                        _type,
                        v
                    )
                    NetUtil.Fire_C("OpenDynamicEvent", _hitObject, "Interact", 2)
                end
            end
        )
        v.OnCollisionEnd:Connect(
            function(_hitObject)
                if _hitObject and _hitObject.Avatar and _hitObject.Avatar.ClassName == "PlayerAvatarInstance" then
                    NetUtil.Fire_C("ChangeMiniGameUIEvent", _hitObject)
                end
            end
        )
    end
end

-- 日夜交替
function MoleHit:DayAndNightChange(_dayOrNight)
end

local player
--- 玩家击中地鼠事件
function MoleHit:PlayerHitEventHandler(_uid, _type, _pit)
    player = world:GetPlayerByUserId(_uid)
    this:HitMoleAction(_uid, _type, _pit)
    -- 抽奖
    local coinNum =
        Config.MoleGlobalConfig.DropCoinRange.Value[
        SortDropCoinByWeight(Config.MoleGlobalConfig.DropCoinRange.Value).index
    ].num
    NetUtil.Fire_S("SpawnCoinEvent", "P", _pit.Position + Vector3.Up, math.floor(coinNum))
    -- 增加数量
    this.hitTime[_type] = this.hitTime[_type] + 1
    -- 发送全局通知
    NetUtil.Broadcast(
        "InsertInfoEvent",
        string.format("%s进度:%s / %s", _type, this.hitTime[_type], math.floor(this.hitNum[_type])),
        2,
        true
    )
    for i = 1, math.random(1, 3) do
        NetUtil.Fire_C("GetItemFromPoolEvent", player, 9, 0)
    end
    -- 判断是否达到彩蛋条件
    if this.hitTime[_type] >= this.hitNum[_type] then
        this.startUpdate, this.hitTime[_type] = true, 0
        this.RefreshList[_type] = {
            timer = 0
        }
        -- 开启对应彩蛋
        this.bonusScene[_type]()
    end
end

function MoleHit:HitMoleAction(_uid, _type, _pit)
    -- 打击表现
    _pit.Effect:SetActive(true)
    local tweener = Tween:ShakeProperty(_pit.Mole, {"Rotation"}, 0.8, 30)
    tweener:Play()
    invoke(
        function()
            -- 摧毁地鼠
            _pit.Mole:SetActive(false)
            -- 关闭特效
            _pit.Effect:SetActive(false)
        end,
        1
    )
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
