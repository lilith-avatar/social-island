---@module MoleGame
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local MoleGame, this = ModuleUtil.New('MoleGame', ClientBase)

---初始化函数
function MoleGame:Init()
    print('[MoleGame] Init()')
    this:DataInit()
    this:NodeDef()
    --this:GameStart()
end

---数据初始化
function MoleGame:DataInit()
    this.rangeList = {}
    this.pitList = {}
    this.score = 0
    this.time = Config.MoleGlobalConfig.PlayerGameTime.Value
    this.startUpdate = false
    this.boostEffect = false
    this.boostTime = Config.MoleGlobalConfig.BoostTime.Value
    this.boostNum = 0
    this.timer = 0
    localPlayer.WalkSpeed = 6
end

---节点绑定
function MoleGame:NodeDef()
    this.hitRange = localPlayer.HitRange
end

---事件绑定
function MoleGame:EventBindForStart()
    this.hitRange.OnCollisionBegin:Connect(
        function(_hitObject)
            if not _hitObject then
                return
            end
            this.rangeList[_hitObject.Name] = true
            if this.boostEffect then
                NetUtil.Fire_S('PlayerHitEvent', localPlayer.UserId, MoleGame.rangeList)
            end
        end
    )
    this.hitRange.OnCollisionEnd:Connect(
        function(_hitObject)
            if not _hitObject then
                return
            end
            this.rangeList[_hitObject.Name] = nil
        end
    )
end

--游戏开始
function MoleGame:GameStart()
    --Todo:传送到指定地点
    this:EventBindForStart()
    this.startUpdate = true
    GuiMole:UpdateTime(this.time)
    GuiMole:UpdateScore(this.score)
    GuiMole:UpdateBoost(this.boostNum)
    NetUtil.Fire_C("InsertInfoEvent", localPlayer, "挥舞锤子把地鼠锤晕吧", 5, true)
end

---游戏结束，重置数据
function MoleGame:GameOver()
    this.hitRange.OnCollisionBegin:Clear()
    this.hitRange.OnCollisionEnd:Clear()
    this:DataInit()
    NetUtil.Fire_S('PlayerLeaveMoleHitEvent', localPlayer.UserId)
    --Todo:传送到指定地点
end

---Update函数
function MoleGame:Update(dt, tt)
    this.timer = this.timer + dt
    if this.startUpdate and this.timer >= 1 then
        this.timer = 0
        this.time = this.time - 1
        GuiMole:UpdateTime(this.time)
        --结算强化效果
        this:BoostEffect()
        if this.time <= 0 then
            this:GameOver()
            GuiMole:GameOver()
            return
        end
    end
end

---强化效果结算
function MoleGame:BoostEffect()
    if this.boostEffect then
        --Todo:具体效果
        this.boostTime = this.boostTime - 1
        localPlayer.WalkSpeed = 8
        print('强化剩余' .. this.boostTime)
        if this.boostTime <= 0 then
            this.boostEffect = false
            localPlayer.WalkSpeed = 6
            this.boostTime = Config.MoleGlobalConfig.BoostTime.Value
        end
    end
end

---加分，加时间和积攒蓄力槽
function MoleGame:AddScoreAndBoostEventHandler(_type, _reward, _boostReward)
    if not this.boostEffect then
        this.boostNum = this.boostNum + _boostReward
        GuiMole:UpdateBoost(this.boostNum)
    end
    if this.boostNum >= 100 then
        this.boostEffect = true
        this.boostNum = 0
    end
    if _type == 'Time' then
        this.time = this.time + _reward
        GuiMole:UpdateTime(this.time)
    end
    if _type == 'Score' then
        this.score = this.score + _reward
        GuiMole:UpdateScore(this.score)
    end
end

function MoleGame:LeaveMoleGameRangeEventHandler()
    if this.startUpdate then
        this:GameOver()
        MoleUIMgr:GameOver()
    end
end

return MoleGame
