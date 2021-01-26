---计时赛跑客户端逻辑模块
---@module RaceGameUIMgr
---@copyright Lilith Games, Avatar Team
---@author Changoo Wu

local RaceGameUIMgr, this = ModuleUtil.New('RaceGameUIMgr', ClientBase)
local Config = Config
function RaceGameUIMgr:Init()
    print('[RaceGameUIMgr] Init()')
    this:NodeDef()
    this:DataInit()
    this:EventBind()
end

---节点定义
function RaceGameUIMgr:NodeDef()
    this.gui = localPlayer.Local.RaceGameGui
    this.CountDown = this.gui.CountDown
    this.Record = this.gui.Record
    this.GameStartTips = this.gui.GameStartTips
    this.GameOverWin = this.gui.GameOverWin
    this.GameOverLose = this.gui.GameOverLose
    this.CheckPoint = this.gui.CheckPoint
    this.CheckPointText = this.gui.CheckPoint.someTxt
end

---数据初始化
function RaceGameUIMgr:DataInit()
end

---事件绑定
function RaceGameUIMgr:EventBind()
end

---显示小游戏UI
function RaceGameUIMgr:Show()
    this.gui:SetActive(true)
    this:ShowGameStart()
end

---关掉小游戏UI
function RaceGameUIMgr:Hide()
    this.gui:SetActive(false)
end

---开始游戏时的表现
function RaceGameUIMgr:ShowGameStart()
    this.GameStartTips:SetActive(true)
    invoke(
        function()
            this.GameStartTips:SetActive(false)
        end,
        1.5
    )
end

---结束游戏时的表现
function RaceGameUIMgr:ShowGameOver(_res)
    if _res == 'win' then
        this.GameOverWin:SetActive(true)
    else
        this.GameOverLose:SetActive(true)
    end
    invoke(
        function()
            this.GameOverWin:SetActive(false)
            this.GameOverLose:SetActive(false)
            RaceGameUIMgr:Hide()
        end,
        1.5
    )
end

---碰到一个点时的表现
local radm = 0
function RaceGameUIMgr:GetCheckPoint(_nowScore, _totalPointNum)
    ---拿完成度做点什么事情
    this.CheckPoint:SetActive(true)
	
    radm = math.random(0, 100)
    this.CheckPointText.Text = '采集完成'..tostring(_nowScore) .. '/' .. tostring(_totalPointNum)

    invoke(
        function()
            if this.CheckPoint.ActiveSelf then
                this.CheckPoint:SetActive(false)
            end
        end,
        0.5
    )
end

---游戏计时器逻辑
function RaceGameUIMgr:Update(_dt, _tt)
    if RaceGame.startUpdate then
        this.CountDown.Text =
            os.date('%M', math.floor(RaceGame.totalTime)) .. ':' .. os.date('%S', math.floor(RaceGame.totalTime))
        this.Record.Text = os.date('%M', math.floor(RaceGame.timer)) .. ':' .. os.date('%S', math.floor(RaceGame.timer))
    end
end
return RaceGameUIMgr
