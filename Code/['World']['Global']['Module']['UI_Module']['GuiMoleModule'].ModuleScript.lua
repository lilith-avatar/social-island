---@module GuiMole
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local GuiMole, this = ModuleUtil.New('GuiMole', ClientBase)

---初始化函数
function GuiMole:Init()
    print('[GuiMole] Init()')
    this:NodeDef()
    this:DataInit()
    this:EventBind()
end

---节点定义
function GuiMole:NodeDef()
    this.contrlGui = localPlayer.Local.ControlGui
    this.gui = localPlayer.Local.MoleHitGui
    this.hitButton = this.gui.HitBtn
    this.hitMask = this.hitButton.MaskImg
    this.timeText = this.gui.InfoPnl.TimeTxt.NumTxt
    this.scoreText = this.gui.InfoPnl.ScoreTxt.NumTxt
    this.boostText = this.gui.InfoPnl.BoostTxt.NumTxt
end

---数据初始化
function GuiMole:DataInit()
    this.isCooling = false
    this.coolTime = 1
    this.timer = 0
end

function GuiMole:GameOver()
    this.gui:SetActive(false)
    this.contrlGui.Ctrl:SetActive(true)
    --this.hitButton:SetActive(false)
end

---事件绑定
function GuiMole:EventBind()
end

function GuiMole:StartMoleEventHandler()
    this:StartGame()
    MoleGame:GameStart()
end


function GuiMole:StartGame()
    NetUtil.Fire_S('PlayerStartMoleHitEvent', localPlayer.UserId)
    this.gui:SetActive(true)
    this.hitButton:SetActive(true)
    this.contrlGui.Ctrl:SetActive(false)
end

function GuiMole:UpdateScore(_score)
    this.scoreText.Text = math.floor(tonumber(_score))
end

function GuiMole:UpdateBoost(_boostNum)
    this.boostText.Text = math.floor(tonumber(_boostNum))
end

function GuiMole:UpdateTime(_time)
    this.timeText.Text = math.floor(tonumber(_time))
end

---强化过程表现
function GuiMole:Boosting()
end

---Update函数
function GuiMole:Update(_dt)
end

return GuiMole
