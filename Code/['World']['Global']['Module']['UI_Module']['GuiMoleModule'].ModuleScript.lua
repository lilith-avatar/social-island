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
    --[[this.payRoot = localPlayer.Local.PayGui
    this.priceRoot = this.payRoot.PricePay
    this.des = this.priceRoot.PayBG.DesText
    this.cancel = this.priceRoot.PayBG.CancelBtn
    this.pay = this.priceRoot.PayBG.PayBtn]]
end

---事件绑定
function GuiMole:EventBind()
    --[[this.cancel.OnClick:Connect(
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
    )]]
end

---数据初始化
function GuiMole:DataInit()
    this.desText = ''
    this.curMoleType = nil
    this.curPit = nil
    this.curPrice = 0
end

function GuiMole:PurchaseCEventHandler(_coin,_id)
    if _id == 2 then
        CloudLogUtil.UploadLog('pannel_actions', 'window_moleGui_payGui_yes')
        NetUtil.Fire_S('PlayerHitEvent',localPlayer.UserId,this.curMoleType,this.curPit)
    end
end

function GuiMole:GetMolePriceEventHandler(_price,_type,_pit,_restNum)
    this.curPrice = _price
    this.curMoleType = _type
    this.curPit = _pit
    this.curPrice = _price
    this.curRestNum = _restNum
end

function GuiMole:InteractCEventHandler(_gameId)
    if _gameId == 2 then
        CloudLogUtil.UploadLog('pannel_actions', 'window_moleGui_payGui_show')
        CloudLogUtil.UploadLog('mole', 'mole_enter',{cur_coin = Data.Player.coin,type=this.curMoleType,rest_num=this.curRestNum})
        NetUtil.Fire_C('PurchaseConfirmEvent',localPlayer,this.curPrice,2,string.format(LanguageUtil.GetText(Config.GuiText['MoleGui_1'].Txt), this.curPrice))
    end
end

function GuiMole:ResetDefUIEventHandler()
end

---Update函数
function GuiMole:Update(_dt)
end

return GuiMole
