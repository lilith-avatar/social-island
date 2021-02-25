---@module GuiMole
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local GuiMole, this = ModuleUtil.New("GuiMole", ClientBase)

---初始化函数
function GuiMole:Init()
    print("[GuiMole] Init()")
    this:DataInit()
    this:NodeDef()
    this:EventBind()
end

---节点定义
function GuiMole:NodeDef()
    this.payRoot = localPlayer.Local.PayGui
    this.priceRoot = this.payRoot.PricePay
    this.des = this.priceRoot.PayBG.DesText
    this.cancel = this.priceRoot.PayBG.CancelBtn
    this.pay = this.priceRoot.PayBG.PayBtn
end

---事件绑定
function GuiMole:EventBind()
    this.cancel.OnClick:Connect(
        function()
            NetUtil.Fire_C("ResetDefUIEvent", localPlayer)
        end
    )
    this.pay.OnClick:Connect(
        function()
            -- 进行支付
            this:Pay()
            NetUtil.Fire_C("ResetDefUIEvent", localPlayer)
        end
    )
end

---数据初始化
function GuiMole:DataInit()
    this.curMoleType = nil
    this.curPit = nil
    this.curPrice = 0
end

function GuiMole:Pay()
    if Data.Player.coin >= this.curPrice then
        NetUtil.Fire_C("UpdateCoinEvent", localPlayer, -1 * this.curPrice)
        NetUtil.Fire_S("PlayerHitEvent", localPlayer.UserId, this.curMoleType, this.curPit)
    else
        --print('金钱不足')
        NetUtil.Fire_C("InsertInfoEvent", localPlayer, "金钱不足", 2, true)
    end
end

function GuiMole:GetPriceEventHandler(_price, _type, _pit)
    this.des.Text = string.format("需要支付 %s 来开启", _price)
    this.curMoleType = _type
    this.curPit = _pit
    this.curPrice = _price
end

function GuiMole:InteractCEventHandler(_gameId)
    print(_gameId)
    if _gameId == 2 then
        this.payRoot:SetActive(true)
        this.priceRoot:SetActive(true)
    end
end

function GuiMole:ResetDefUIEventHandler()
    this.payRoot:SetActive(false)
    this.priceRoot:SetActive(false)
end

---Update函数
function GuiMole:Update(_dt)
end

return GuiMole
