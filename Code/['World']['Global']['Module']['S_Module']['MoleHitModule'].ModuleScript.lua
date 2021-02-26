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
                if _hitObject.ClassName == "PlayerInstance" and _hitObject then
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
                if _hitObject.ClassName == "PlayerInstance" and _hitObject then
                    NetUtil.Fire_C("ResetDefUIEvent", _hitObject)
                end
            end
        )
    end
end

function MoleHit:InteractSEventHandler(_player, _gameId)
    if _gameId == 2 then
    end
end

--- 玩家击中地鼠事件
function MoleHit:MoleDestroy(_uid, _type, _pit)
    this:HitMoleAction(_uid, _type, _pit)
    -- 抽奖
    -- 增加数量
    this.hitTime[_type] = this.hitTime[_type] + 1
    --! only Test
    NetUtil.Broadcast(
        "InsertInfoEvent",
        string.format("%s进度:%s / %s", _type, this.hitTime[_type], math.floor(this.hitNum[_type])),
        2,
        true
    )
    -- 判断是否达到彩蛋条件
    if this.hitTime[_type] >= this.hitNum[_type] then
        this.startUpdate, this.hitTime[_type] = true, 0
        this.RefreshList[_type] = {
            timer = 0
        }
        --开启对应彩蛋
        print(string.format("开启 %s 彩蛋", _type))
    end
end

function MoleHit:HitMoleAction(_uid, _type, _pit)
    -- 打击表现
    _pit.Effect:SetActive(true)
    local tweener = Tween:ShakeProperty(_pit[_type], {"Rotation"}, 0.8, 30)
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

function MoleHit:EnterMiniGameEventHandler(_player, _gameId)
    if _gameId == 2 then
    end
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
