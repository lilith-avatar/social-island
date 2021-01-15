---计时赛跑客户端逻辑模块
---@module RaceGame
---@copyright Lilith Games, Avatar Team
---@author Changoo Wu
local RaceGame, this = ModuleUtil.New('RaceGame', ClientBase)
local Config = Config

---从服务器拿到启动回执
function RaceGame:ClientInitRaceEventHandler(_nowKey)
    this:DataInit(_nowKey)
    this:NodeDef()
    this:GameStart()
end

---数据初始化
function RaceGame:DataInit(_nowKey)
    this.pointRecord = 0
    this.nowKey = _nowKey
    this.pointNum = #Config.RacePoint[_nowKey]
    this.totalTime = Config.RacePoint[_nowKey][1].MaxTime
    this.startUpdate = false
    this.boostEffect = false
    this.timer = 0
end

---节点绑定
function RaceGame:NodeDef()
    ---如果玩家检测体不够大再扩一下
    print('[RaceGame]', Config.RacePoint[this.nowKey])
    this.checkPoint =
        world:CreateInstance(
        'CheckPoint',
        'CheckPoint',
        localPlayer.Local.Independent,
        Config.RacePoint[this.nowKey][1].Pos
    )
    this.checkPoint.OnCollisionBegin:Connect(
        function(_hitObject, _hitPoint, _hitNormal)
            this:FreshPoint(_hitObject, _hitPoint, _hitNormal)
        end
    )
end

---游戏开始
function RaceGame:GameStart()
    --Todo:面朝第一个点
    this.startUpdate = true
    RaceGameUIMgr:Show()
end

---游戏结束
local rewardRate = 0
function RaceGame:GameOver()
    this.startUpdate = false
    rewardRate = this.pointRecord / this.pointNum
    if rewardRate == 1 then
        RaceGameUIMgr:ShowGameOver('win')
    else
        RaceGameUIMgr:ShowGameOver('lose')
    end
    NetUtil.Fire_S('RaceGameOverEvent', localPlayer, this.timer, rewardRate)
    this.checkPoint.OnCollisionBegin:Clear()
    this.checkPoint:Destroy()
end

---碰到检查点之后的逻辑
function RaceGame:FreshPoint(_hitObject, _hitPoint, _hitNormal)
    if _hitObject == localPlayer then
        this.checkPoint:SetActive(false)
        this.pointRecord = this.pointRecord + 1
        if this.pointRecord == this.pointNum then
            RaceGame:GameOver()
        else
            RaceGameUIMgr:GetCheckPoint(this.pointRecord, this.pointNum)
            this.checkPoint.Position = Config.RacePoint[this.nowKey][this.pointRecord + 1].Pos
            this.checkPoint:SetActive(true)
        end
    end
end

---游戏计时器逻辑
function RaceGame:Update(_dt, _tt)
    if this.startUpdate then
        this.totalTime = this.totalTime - _dt
        this.timer = this.timer + _dt
        if this.totalTime < 0 then
            RaceGame:GameOver()
        end
    end
end
return RaceGame
