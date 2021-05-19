---@module GuiMole
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local GuiMole, this = ModuleUtil.New('GuiMole', ClientBase)
local GuiStateEnum = {
    close = 'Close',
    pre = 'Pre',
    reward = 'Reward'
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
    this.gui = localPlayer.Local.SpecialTopUI.MoleGui
    this.preGui = this.gui.PrePanel
    this.rewardGui = this.gui.RewardPanel

    this.preContinue = this.preGui.ContinueBtn
    this.preArrow = this.preContinue.Arrow
    this.rewardQueue = {}
    this.rewardArrow = this.rewardGui.ItemBG.Arrow
    this.rewardContinue = this.rewardGui.ContinueBtn
    this.rewardAccept = this.rewardGui.ItemBG.AcceptBtn
    this.rewardLight = this.rewardGui.ItemBG.Info.Light
    this.rewardIcon = this.rewardGui.ItemBG.Info.ItemIcon
    this.rewardName = this.rewardGui.ItemBG.Info.ItemName
    this.rewardStar = this.rewardGui.ItemBG.Info.Star
end

function GuiMole:LanguageInit()
    this.preGui.TalkBG.NameTxt.Text = LanguageUtil.GetText(Config.GuiText['MoleGui_4'].Txt)
    this.preGui.TalkBG.DescTxt.Text = LanguageUtil.GetText(Config.GuiText['MoleGui_2'].Txt)
    this.rewardGui.ItemBG.Info.GetText.Text = LanguageUtil.GetText(Config.GuiText['MoleGui_3'].Txt)
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
    this.rewardContinue.OnClick:Connect(
        function()
            this.queueIndex = this.queueIndex + 1
            this:ShowRewardItem(this.queueIndex)
        end
    )
    this.rewardAccept.OnClick:Connect(
        function()
            this.queueIndex = {}
            this.queueIndex = 1
            this.gui:SetActive(false)
            this.rewardGui:SetActive(false)
            NetUtil.Fire_C('ChangeMiniGameUIEvent', localPlayer)
        end
    )
end

---数据初始化
function GuiMole:DataInit()
    this.desText = ''
    this.curMoleType = nil
    this.curPit = nil
    this.curPrice = 0
    this.state = GuiStateEnum.close
    this.queueIndex = 1
end

function GuiMole:Test()
    this.state = GuiStateEnum.reward
end

function GuiMole:PurchaseCEventHandler(_coin, _id)
    if _id == 2 then
        CloudLogUtil.UploadLog('pannel_actions', 'window_moleGui_payGui_yes')
        NetUtil.Fire_S('PlayerHitEvent', localPlayer.UserId, this.curMoleType, this.curPit)
        this.state = GuiStateEnum.reward
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
            {cur_coin = Data.Player.coin, rest_num = this.curRestNum}
        )
        this.gui:SetActive(true)
        this.preGui:SetActive(true)
        this.state = GuiStateEnum.pre
        NetUtil.Fire_C('ChangeMiniGameUIEvent', localPlayer, 2)
    end
end

local rewardTweener
function GuiMole:ShowRewardItem(_index)
    -- 先进行缩放表现
    this:RewardPres()
    -- 显示物品名字和icon
    this.rewardArrow:SetActive(_index ~= table.nums(this.rewardQueue))
    this.rewardContinue:SetActive(_index ~= table.nums(this.rewardQueue))
    this.rewardAccept:SetActive(_index == table.nums(this.rewardQueue))
    this.rewardName.Text = LanguageUtil.GetText(Config.Item[this.rewardQueue[_index]].Name)
    this.rewardIcon.Texture = ResourceManager.GetTexture('UI/ItemIcon/' .. Config.Item[this.rewardQueue[_index]].Icon)
    this.rewardGui.ItemBG.Info:SetActive(true)
    -- 回弹表现
    rewardTweener = Tween:TweenProperty(this.rewardGui.ItemBG, {Size = Vector2(873, 535)}, 0.05, 1)
    rewardTweener:Play()
    rewardTweener:WaitForComplete()
end

function GuiMole:RewardPres()
    if rewardTweener then
        rewardTweener:Pause()
        rewardTweener:Destroy()
    end
    this.rewardContinue:SetActive(false)
    this.rewardAccept:SetActive(false)
    this.rewardGui.ItemBG.Info:SetActive(false)
    this.rewardGui:SetActive(true)
    this.rewardGui.ItemBG.Size = Vector2(523.8, 321)
    rewardTweener = Tween:TweenProperty(this.rewardGui.ItemBG, {Size = Vector2(960, 588.5)}, 0.1, 1)
    rewardTweener:Play()
    rewardTweener:WaitForComplete()
end

function GuiMole:GetMoleRewardEventHandler(_rewardList)
    this.rewardQueue = _rewardList
    this:ShowRewardItem(this.queueIndex)
    CloudLogUtil.UploadLog(
        'mole',
        'mole_confirm',
        {cur_coin = Data.Player.coin, rest_num = this.curRestNum,item_list = _rewardList}
    )
end

---Update函数
function GuiMole:Update(dt, tt)
    this[this.state .. 'Update'](self, dt, tt)
end

function GuiMole:CloseUpdate()
end

function GuiMole:PreUpdate(dt, tt)
    this.preArrow.AnchorsY = Vector2(0.055 + 0.01 * math.cos(tt * 3), 0.055 + 0.01 * math.cos(tt * 3))
end

function GuiMole:RewardUpdate(dt, tt)
    if this.rewardArrow.ActiveSelf then
        this.rewardArrow.AnchorsY = Vector2(-0.02 + 0.01 * math.cos(tt * 5), -0.02 + 0.01 * math.cos(tt * 5))
    end
    if this.rewardLight.ActiveSelf then
        this.rewardLight.Angle = this.rewardLight.Angle + dt * 10
    end
    if this.rewardStar.ActiveSelf then
        this.rewardStar.Alpha = 0.35 * math.cos(tt) + 0.65
    end
end

return GuiMole
