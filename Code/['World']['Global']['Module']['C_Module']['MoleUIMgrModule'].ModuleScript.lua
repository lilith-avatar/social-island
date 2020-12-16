---@module MoleUIMgr
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local MoleUIMgr, this = ModuleUtil.New("MoleUIMgr", ClientBase)

---初始化函数
function MoleUIMgr:Init()
    this:NodeDef()
    this:DataInit()
    this:EventBind()
end

---节点定义
function MoleUIMgr:NodeDef()
    this.gui = localPlayer.Local.MoleHitGui
    this.hitButton = this.gui.HitBtn
    this.timeText = this.gui.InfoPnl.TimeTxt.NumTxt
    this.scoreText = this.gui.InfoPnl.ScoreTxt.NumTxt
    this.boostText = this.gui.InfoPnl.BoostTxt.NumTxt
end

---数据初始化
function MoleUIMgr:DataInit()
end

function MoleUIMgr:GameOver()
    this.gui:SetActive(false)
    --this.hitButton:SetActive(false)
end

---事件绑定
function MoleUIMgr:EventBind()
    this.hitButton.OnClick:Connect(
        function()
            this:Hit()
        end
    )
end

function MoleUIMgr:StartMoleEventHandler()
    this:StartGame()
    MoleGame:GameStart()
end

function MoleUIMgr:Hit()
    NetUtil.Fire_S("PlayerHitEvent", localPlayer.UserId, MoleGame.rangeList)
end

function MoleUIMgr:StartGame()
    NetUtil.Fire_S("PlayerStartMoleHitEvent", localPlayer.UserId)
    this.gui:SetActive(true)
    this.hitButton:SetActive(true)
end

function MoleUIMgr:UpdateScore(_score)
    this.scoreText.Text = math.floor(tonumber(_score))
end

function MoleUIMgr:UpdateBoost(_boostNum)
    this.boostText.Text = math.floor(tonumber(_boostNum))
end

function MoleUIMgr:UpdateTime(_time)
    this.timeText.Text = math.floor(tonumber(_time))
end

---强化过程表现
function MoleUIMgr:Boosting()
end

---Update函数
function MoleUIMgr:Update()
end

return MoleUIMgr
