---@module MoleGame
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local MoleGame, this = ModuleUtil.New("MoleGame", ClientBase)

---初始化函数
function MoleGame:Init()
    this:DataInit()
    this:NodeDef()
    this:GameStart()
end

---数据初始化
function MoleGame:DataInit()
    this.rangeList = {}
    this.score = 0
    this.totalTime = 999  --Config.MoleGlobalConfig.PlayerGameTime
    this.startUpdate = false
    this.boostEffect = false
    this.timer = 0
end

---节点绑定
function MoleGame:NodeDef()
    this.hitRange = localPlayer.HitRange
end

---事件绑定
function MoleGame:EventBindForStart()
    this.hitRange.OnCollisionBegin:Connect(
        function(_hitObject)
            this.rangeList[_hitObject.Name] = true
            print(_hitObject.Name .. " Begin")
        end
    )
    this.hitRange.OnCollisionEnd:Connect(
        function(_hitObject)
            this.rangeList[_hitObject.Name] = nil
            print(_hitObject.Name .. " End")
        end
    )
end

--游戏开始
function MoleGame:GameStart()
    --Todo:传送到指定地点
    this:EventBindForStart()
    this.startUpdate = true
end

---游戏结束，重置数据
function MoleGame:GameOver()
    this.hitRange.OnCollisionBegin:Clear()
    this.hitRange.OnCollisionEnd:Clear()
    this:DataInit()
    --Todo:传送到指定地点
end

---Update函数
function MoleGame:Update(dt, tt)
    if this.startUpdate and this.timer + dt >= 1 then
        this.totalTime = this.totalTime - 1
        this.timer = 0
        if this.totalTime <= 0 then
            this:GameOver()
            return
        end
        --结算强化效果
        this:BoostEffect()
        print(this.totalTime)
    end
end

---强化效果结算
function MoleGame:BoostEffect()
    if this.boostEffect then
        --Todo:具体效果
        this.boostTime = this.boostTime - 1
        if this.boostTime <= 0 then
            this.boostEffect = false
        end
    end
end

return MoleGame
