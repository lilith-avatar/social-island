---@module GuiChair
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local GuiChair, this = ModuleUtil.New("GuiChair", ClientBase)

local BalanceRatio = {
    Left = -1,
    Right = 1
}

---初始化函数
function GuiChair:Init()
    print("[GuiChair] Init()")
    this:NodeDef()
    this:DataInit()
    this:EventBind()
    invoke(function()
        this.startUpdate = true
    end, 8)
end

function GuiChair:DataInit()
    this.startUpdate = false
    this.timer = 0
    this.spiritDecayRate = 0
    this.chairId = nil

    this.balanceDir = nil
end

function GuiChair:EventBind()
    this.leftBtn.OnClick:Connect(
        function()
            this:ClickMoveBtn("Left")
        end
    )
    this.rightBtn.OnClick:Connect(
        function()
            this:ClickMoveBtn("Right")
        end
    )
end

function GuiChair:NodeDef()
    this.gui = localPlayer.Local.ChairGui
    this.spirit = {
        Left = this.gui.SpiritPanel.SlotImg.LeftImg,
        Right = this.gui.SpiritPanel.SlotImg.RightImg
    }
    --this.gui.SpiritPanel.SlotImg.SpiritImg
    this.leftBtn = this.gui.ButtonPanel.LeftBtn
    this.rightBtn = this.gui.ButtonPanel.RightBtn
    this.timeText = this.gui.TimePanel.TimeBG.TimeText

    -- * Value Object
    this.balance = world.MiniGames.Game_10_Chair.Balance
end

function GuiChair:ClickMoveBtn(_dir)
    if this.balanceDir ~= _dir then
        this.spirit[this.balanceDir].FillAmount = this.spirit[this.balanceDir].FillAmount - Config.ChairGlobalConfig.SpiritIncrease.Value
    else
        this.spirit[this.balanceDir].FillAmount = this.spirit[this.balanceDir].FillAmount + Config.ChairGlobalConfig.SpiritIncrease.Value
    end
    if this.spirit[this.balanceDir].FillAmount <= 0 then
        local delta = math.abs(this.spirit[this.balanceDir].FillAmount)
        this.spirit[this.balanceDir].FillAmount = 0
        this.balanceDir = _dir
        this.spirit[this.balanceDir].FillAmount = this.spirit[this.balanceDir].FillAmount + delta
    end
    this.balance.Value = this.spirit[this.balanceDir].FillAmount * BalanceRatio[this.balanceDir]
end

function GuiChair:GetDecayRate(_totalTime)
    local tmp = 0
    for k, v in pairs(Config.ChairGlobalConfig.SpiritDecayRate.Value) do
        if _totalTime >= k then
            tmp = v
        end
    end
    this.spiritDecayRate = tmp
    return this.balance.Value > 0 and "Right" or "Left"
end

function GuiChair:InteractCEventHandler(_gameId)
    if _gameId == 10 then
        NetUtil.Fire_C("ChangeMiniGameUIEvent", localPlayer, _gameId)
        NetUtil.Fire_S("PlayerSitEvent", localPlayer, this.chairId)
        localPlayer.Local.Independent.ChairCam.Position = Vector3(5.57, 2.693132, -18.319471)
        NetUtil.Fire_C("SetCurCamEvent", localPlayer, PlayerCam.chairCam, localPlayer)
    end
end

function GuiChair:StartJetEventHandler()
    this.gui:SetActive(true)
    this.startUpdate = true
end

function GuiChair:ChangeChairIdEventHandler(_chairId)
    this.chairId = _chairId
end

function GuiChair:Update(_dt)
    if this.startUpdate then
        this.balanceDir = this:GetDecayRate(this.timer)
        this.timer = this.timer + _dt
        print(this.balanceDir)
        this.spirit[this.balanceDir].FillAmount = this.spirit[this.balanceDir].FillAmount + this.spiritDecayRate * _dt
        if this.spirit[this.balanceDir].FillAmount >= 1 then
            --NetUtil.Fire_S("JetOverEvent", localPlayer, this.chairId, this.timer)
            this.startUpdate = false
            this.timer = 0
            this.spirit['Left'].FillAmount = 0
            this.spirit['Right'].FillAmount = 0
        end
        this.balance.Value = this.spirit[this.balanceDir].FillAmount * BalanceRatio[this.balanceDir]
        this.timeText.Text = math.floor(this.timer)
    end
end

return GuiChair
