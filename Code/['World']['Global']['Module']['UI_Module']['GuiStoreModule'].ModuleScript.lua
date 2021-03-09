---  商店UI模块：
-- @module  GuiStore
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
---@module GuiStore

local GuiStore, this = ModuleUtil.New("GuiStore", ClientBase)

local gui

local curNpcID

local chosenItemID = 0

function GuiStore:Init()
    print("GuiStore:Init")
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--节点引用
function GuiStore:NodeRef()
    gui = localPlayer.Local.ShopGui
end

--数据变量声明
function GuiStore:DataInit()
    curNpcID = 0
end

--节点事件绑定
function GuiStore:EventBind()
    gui.ShopPanel.CloseImg.CloseBtn.OnClick:Connect(
        function()
            NetUtil.Fire_C("SwitchStoreUIEvent", localPlayer, 2)
            NetUtil.Fire_C("ChangeMiniGameUIEvent", localPlayer)
        end
    )
    gui.PurchasePanel.PurchaseBgImg.LaterBtn.OnClick:Connect(
        function()
            this:SwithConfirmUI(2, nil)
        end
    )
    gui.ShopPanel.BuyBtn.OnClick:Connect(
        function()
            this:OnClickBuyBtn()
        end
    )
end

--获取商店出售物品data
function GuiStore:GetItemData(_itemData)
    for k, v in pairs(_itemData) do
        gui.ShopPanel.DragPanel.Panel1["ShopBgImg" .. v.Index].ItemID.Value = v.ItemId
        gui.ShopPanel.DragPanel.Panel1["ShopBgImg" .. v.Index].GoodsImg.ShopBtn.OnClick:Connect(
            function()
                chosenItemID = v.ItemId
                this:UpdateStoreUI(false)
                this:UpdateItemInfo(v.ItemId)
                this:UpdateBuyBtn()
            end
        )
    end
end

--点击购买Btn
function GuiStore:OnClickBuyBtn()
    gui.PurchasePanel.PurchaseBgImg.DesText.Text = "是否购买" .. LanguageUtil.GetText(Config.Item[chosenItemID].Name)
    this:SwithConfirmUI(1, chosenItemID)
end

--开关确认支付面板
function GuiStore:SwithConfirmUI(_switch, _itemID)
    if _switch == 1 then
        gui.PurchasePanel.PurchaseBgImg.PriceFigure.ScoreText.Text = Data.Player.coin
        gui.PurchasePanel.PurchaseBgImg.PriceFigure.PriceText.Text = "/" .. Config.Shop[curNpcID][_itemID].Price
        if Data.Player.coin >= Config.Shop[curNpcID][_itemID].Price then
            gui.PurchasePanel.PurchaseBgImg.PurchaseBtn.LockImg.Visible = false
            gui.PurchasePanel.PurchaseBgImg.PurchaseBtn.OnClick:Connect(
                function()
                    this:BuyItem(_itemID)
                end
            )
        else
            gui.PurchasePanel.PurchaseBgImg.PurchaseBtn.LockImg.Visible = true
            gui.PurchasePanel.PurchaseBgImg.PurchaseBtn.OnClick:Clear()
        end
        gui.PurchasePanel.Visible = true
    elseif _switch == 2 then
        gui.PurchasePanel.PurchaseBgImg.PurchaseBtn.OnClick:Clear()
        gui.PurchasePanel.Visible = false
    end
end

--购买一个物品
function GuiStore:BuyItem(_itemID)
    Data.Player.coin = Data.Player.coin - Config.Shop[curNpcID][_itemID].Price
    NetUtil.Fire_C("GetItemEvent", localPlayer, _itemID)
    this:SwithConfirmUI(2)
    wait(0.1)
    this:UpdateStoreUI()
end

--更新物品信息显示
function GuiStore:UpdateItemInfo(_itemID)
    if _itemID then
        gui.ShopPanel.NameTextBox.NameText.Text = LanguageUtil.GetText(Config.Item[_itemID].Name)
        gui.ShopPanel.DesTextBox.DesText.Text = LanguageUtil.GetText(Config.Item[_itemID].Des)
    else
        gui.ShopPanel.NameTextBox.NameText.Text = ""
        gui.ShopPanel.DesTextBox.DesText.Text = ""
    end
end

--更新购买按钮显示
function GuiStore:UpdateBuyBtn()
    gui.ShopPanel.BuyBtn.Locked:SetActive(false)
    for k, v in pairs(Data.Player.bag) do
        if k == chosenItemID and v.count > 0 and tonumber(string.sub(tostring(chosenItemID), 1, 1)) < 6 then
            gui.ShopPanel.BuyBtn.Locked:SetActive(true)
            break
        end
    end
end

--更新一个物品Btn显示
function GuiStore:UpdateBuyBtnUI(_sellBtn)
    _sellBtn:SetActive(true)
    if _sellBtn.ItemID.Value == 0 then
        _sellBtn:SetActive(false)
    else
        --Icon和价格显示
        for k, v in pairs(Config.Item) do
            if v.ItemID == _sellBtn.ItemID.Value then
                _sellBtn.PriceImg.PriceTxt.Text = Config.Shop[curNpcID][v.ItemID].Price
                _sellBtn.GoodsImg.IMGNormal.Texture = ResourceManager.GetTexture("UI/ItemIcon/" .. v.Icon)
                break
            end
        end
        --选择框显示
        if chosenItemID == _sellBtn.ItemID.Value then
            _sellBtn.GoodsImg.Chosen:SetActive(true)
        else
            _sellBtn.GoodsImg.Chosen:SetActive(false)
        end
        --锁定显示
        for k, v in pairs(Data.Player.bag) do
            if
                k == _sellBtn.ItemID.Value and v.count > 0 and
                    tonumber(string.sub(tostring(_sellBtn.ItemID.Value), 1, 1)) < 6
             then
                _sellBtn.GoodsImg.LockImg.Visible = true
                break
            end
        end
    end
end

--重置一个购买Btn
function GuiStore:ResetBuyBtnUI(_sellBtn)
    _sellBtn.ItemID.Value = 0
    _sellBtn.GoodsImg.ShopBtn.OnClick:Clear()
end

--更新所有显示
function GuiStore:UpdateStoreUI(_isReset)
    for k, v in pairs(gui.ShopPanel.DragPanel.Panel1:GetChildren()) do
        if _isReset then
            this:ResetBuyBtnUI(v)
        else
            this:UpdateBuyBtnUI(v)
        end
    end
    this:UpdateItemInfo()
end

--开关商店显示
--GuiStore:SwitchStoreUIEventHandler(1, 1)
function GuiStore:SwitchStoreUIEventHandler(_switch, _npcID)
    if _switch == 1 then
        print("开商店显示", _npcID)
        curNpcID = _npcID
        this:GetItemData(Config.Shop[curNpcID])
        this:UpdateStoreUI(false)
        gui.Visible = true
    elseif _switch == 2 then
        curNpcID = 0
        this:UpdateStoreUI(true)
        gui.Visible = false
    end
end

return GuiStore
