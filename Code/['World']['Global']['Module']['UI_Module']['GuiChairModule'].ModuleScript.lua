---@module GuiChair
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local GuiChair, this = ModuleUtil.New("GuiChair", ClientBase)

---初始化函数
function GuiChair:Init()
    print("[GuiChair] Init()")
    this:NodeDef()
    this:DataInit()
    this:EventBind()
    print(table.dump(Config.ChairGlobalConfig.SpiritDecayRate.Value))
    --[[! test
    invoke(function()
        this.startUpdate = true
    end, 5)]]
end

function GuiChair:DataInit()
    this.startUpdate = false
    this.timer = 0
    this.spiritDecayRate = 0
    this.chairId = nil
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
    this.spirit = this.gui.SpiritPanel.SlotImg.SpiritImg
    this.leftBtn = this.gui.ButtonPanel.LeftBtn
    this.rightBtn = this.gui.ButtonPanel.RightBtn
    this.timeText = this.gui.TimePanel.TimeBG.TimeText
end

function GuiChair:ClickMoveBtn(_dir)
    if this.spirit.FillAmount < 1 then
        this.spirit.FillAmount = this.spirit.FillAmount + Config.ChairGlobalConfig.SpiritIncrease.Value
    end
end

function GuiChair:GetDecayRate(_totalTime)
    local tmp = 0
    for k, v in pairs(Config.ChairGlobalConfig.SpiritDecayRate.Value) do
        if _totalTime >= k then
            tmp = v
        end
    end
    this.spiritDecayRate = tmp
end

function GuiChair:InteractCEventHandler(_gameId)
    if _gameId == 10 then
        NetUtil.Fire_S("PlayerSitEvent", localPlayer, this.chairId)
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
        this:GetDecayRate(this.timer)
        this.timer = this.timer + _dt
        this.spirit.FillAmount = this.spirit.FillAmount - this.spiritDecayRate * _dt
        if this.spirit.FillAmount <= 0 then
            NetUtil.Fire_S("JetOverEvent", localPlayer, this.chairId, this.timer)
            this.gui:SetActive(false)
            this.startUpdate = false
            this.timer = 0
            this.spirit.FillAmount = 1
        end
        this.timeText.Text = math.floor(this.timer)
    end
end

return GuiChair
