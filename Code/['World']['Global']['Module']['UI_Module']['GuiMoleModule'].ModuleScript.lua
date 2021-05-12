---@module GuiMole
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local GuiMole, this = ModuleUtil.New('GuiMole', ClientBase)
local GuiStateEnum = {
    Close = 1,
    Pre = 2,
    Reward = 3
}

---初始化函数
function GuiMole:Init()
    print('[GuiMole] Init()')
    this:DataInit()
    this:NodeDef()
    this:EventBind()
    this:LanguageInit()
end

---节点定义
function GuiMole:NodeDef()
    this.gui = localPlayer.Local.MoleGui
    this.preGui = this.gui.PrePanel
    this.preContinue = this.preGui.ContinueBtn
    this.arrow = this.preContinue.Arrow
end

function GuiMole:LanguageInit()
    this.preGui.TalkBG.NameTxt.Text = LanguageUtil.GetText(Config.GuiText['MoleGui_4'].Txt)
    this.preGui.TalkBG.DescTxt.Text = LanguageUtil.GetText(Config.GuiText['MoleGui_2'].Txt)
end

---事件绑定
function GuiMole:EventBind()
    this.preContinue.OnClick:Connect(
        function()
            this.preGui:SetActive(false)
            NetUtil.Fire_C(
                'PurchaseConfirmEvent',
                localPlayer,
                this.curPrice,
                2,
                string.format(LanguageUtil.GetText(Config.GuiText['MoleGui_1'].Txt), this.curPrice)
            )
        end
    )
end

---数据初始化
function GuiMole:DataInit()
    this.desText = ''
    this.curMoleType = nil
    this.curPit = nil
    this.curPrice = 0
    this.state = GuiStateEnum.Close
end

function GuiMole:Test()
    this.state = GuiStateEnum.Pre
end

function GuiMole:PurchaseCEventHandler(_coin, _id)
    if _id == 2 then
        CloudLogUtil.UploadLog('pannel_actions', 'window_moleGui_payGui_yes')
        CloudLogUtil.UploadLog(
            'mole',
            'mole_confirm',
            {cur_coin = Data.Player.coin, type = this.curMoleType, rest_num = this.curRestNum}
        )
        NetUtil.Fire_S('PlayerHitEvent', localPlayer.UserId, this.curMoleType, this.curPit)
    end
end

function GuiMole:GetMolePriceEventHandler(_price, _type, _pit, _restNum)
    this.curPrice = _price
    this.curMoleType = _type
    this.curPit = _pit
    this.curPrice = _price
    this.curRestNum = _restNum
end

function GuiMole:InteractCEventHandler(_gameId)
    if _gameId == 2 then
        CloudLogUtil.UploadLog('pannel_actions', 'window_moleGui_payGui_show')
        CloudLogUtil.UploadLog(
            'mole',
            'mole_enter',
            {cur_coin = Data.Player.coin, type = this.curMoleType, rest_num = this.curRestNum}
        )
        this.preGui:SetActive(true)
        this.state = GuiStateEnum.Pre
    end
end

function GuiMole:ResetDefUIEventHandler()
end

---Update函数
function GuiMole:Update(dt, tt)
    if this.state == GuiStateEnum.Pre then
        this.arrow.AnchorsY = Vector2(0.055 + 0.01 * math.cos(tt * 3), 0.055 + 0.01 * math.cos(tt * 3))
    end
end

return GuiMole
