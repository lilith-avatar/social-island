---  支付UI模块：
-- @module  GuiPurchase
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
---@module GuiPurchase

local GuiPurchase, this = ModuleUtil.New("GuiPurchase", ClientBase)

local gui, confirmPanel, scrollPanel

---交互ID
local interactID = 0

---支付金币数目
local purchaseCoin = 0

---滑块输入的极值
local sliderMin, sliderMax = 0, 0

function GuiPurchase:Init()
    print("GuiPurchase:Init")
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--节点引用
function GuiPurchase:NodeRef()
    gui = localPlayer.Local.SpecialTopUI.PurchaseGUI
    confirmPanel = gui.PurchasePanel.PurchaseBgImg.ConfirmPanel
    scrollPanel = gui.PurchasePanel.PurchaseBgImg.ScrollPanel
end

--数据变量声明
function GuiPurchase:DataInit()
end

--节点事件绑定
function GuiPurchase:EventBind()
    gui.PurchasePanel.PurchaseBgImg.LaterBtn.OnClick:Connect(
        function()
            this:OnClickPurchaseLaterBtn()
            SoundUtil.Play2DSE(localPlayer.UserId, 6)
        end
    )
    scrollPanel.Slider.OnScroll:Connect(
        function()
            purchaseCoin =
                math.floor((sliderMax - sliderMin) * (100 - scrollPanel.Slider.ScrollScale) / 100 + sliderMin)
            scrollPanel.CurText.Text = purchaseCoin
        end
    )
end

--购买确认
function GuiPurchase:PurchaseConfirmEventHandler(_coinNUm, _interactID, _text)
    gui:SetActive(true)
    SoundUtil.Play2DSE(localPlayer.UserId, 3)
    interactID = _interactID
    purchaseCoin = _coinNUm
    gui.PurchasePanel.PurchaseBgImg.PurchaseBtn.LockImg:SetActive(Data.Player.coin < _coinNUm)
    gui.PurchasePanel.PurchaseBgImg.DesText.Text = _text
    confirmPanel:SetActive(true)
    confirmPanel.PriceText.Text = _coinNUm
    confirmPanel.PlayerCoinText.Text = "/" .. Data.Player.coin
    gui.PurchasePanel.PurchaseBgImg.PurchaseBtn.OnClick:Clear()
    gui.PurchasePanel.PurchaseBgImg.PurchaseBtn.OnClick:Connect(
        function()
            this:OnClickPurchaseConfirmBtn()
        end
    )
end

--滑块
function GuiPurchase:SliderPurchaseEventHandler(_interactID, _text, _min, _max)
    gui:SetActive(true)
    SoundUtil.Play2DSE(localPlayer.UserId, 3)
    interactID = _interactID
    gui.PurchasePanel.PurchaseBgImg.DesText.Text = _text
    sliderMin = _min or 1
    sliderMax = _max or Data.Player.coin
    scrollPanel.MinText.Text = _min or 1
    scrollPanel.MaxText.Text = _max or Data.Player.coin
    gui.PurchasePanel.PurchaseBgImg.PurchaseBtn.LockImg:SetActive(false)
    purchaseCoin = math.floor((sliderMax - sliderMin) * (100 - scrollPanel.Slider.ScrollScale) / 100 + sliderMin)
    scrollPanel.CurText.Text = purchaseCoin
    scrollPanel:SetActive(true)
    gui.PurchasePanel.PurchaseBgImg.PurchaseBtn.OnClick:Clear()
    gui.PurchasePanel.PurchaseBgImg.PurchaseBtn.OnClick:Connect(
        function()
            scrollPanel:SetActive(false)
            NetUtil.Fire_C("PurchaseConfirmEvent", localPlayer, purchaseCoin, interactID, _text)
        end
    )
end

--点击关闭
function GuiPurchase:OnClickPurchaseLaterBtn()
    confirmPanel:SetActive(false)
    scrollPanel:SetActive(false)
    gui:SetActive(false)
    gui.PurchasePanel.PurchaseBgImg.PurchaseBtn.OnClick:Clear()
	NetUtil.Fire_C("ChangeMiniGameUIEvent", localPlayer)
    interactID = 0
    purchaseCoin = 0
end

--点击购买
function GuiPurchase:OnClickPurchaseConfirmBtn()
    NetUtil.Fire_C("PurchaseCEvent", localPlayer, purchaseCoin, interactID)
    NetUtil.Fire_S("PurchaseSEvent", localPlayer, purchaseCoin, interactID)
    NetUtil.Fire_C("UpdateCoinEvent", localPlayer, -1 * purchaseCoin)
    SoundUtil.Play2DSE(localPlayer.UserId, 7)
    this:OnClickPurchaseLaterBtn()
    purchaseCoin = 0
    sliderMin = 0
    sliderMax = 0
    scrollPanel.Slider.ScrollScale = 50
end

return GuiPurchase
