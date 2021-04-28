---  商店UI模块：
-- @module  GuiStore
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
---@module GuiStore

local GuiStore, this = ModuleUtil.New('GuiStore', ClientBase)

local gui

local curNpcID

local chosenItemID = 0

function GuiStore:Init()
    print('GuiStore:Init')
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
            NetUtil.Fire_C('SwitchStoreUIEvent', localPlayer, 2)
            NetUtil.Fire_C('ChangeMiniGameUIEvent', localPlayer)
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
        gui.ShopPanel.DragPanel.Panel1['ShopBgImg' .. v.Index].ItemID.Value = v.ItemId
        gui.ShopPanel.DragPanel.Panel1['ShopBgImg' .. v.Index].GoodsImg.ShopBtn.OnClick:Connect(
            function()
                SoundUtil.Play2DSE(localPlayer.UserId, 101)
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
    if chosenItemID ~= 0 then
        NetUtil.Fire_C(
            'PurchaseConfirmEvent',
            localPlayer,
            Config.Shop[curNpcID][chosenItemID].Price,
            99,
            string.format(
                LanguageUtil.GetText(Config.GuiText.ShopGui_1.Txt),
                LanguageUtil.GetText(Config.Item[chosenItemID].Name)
            )
        )
    end
end

--确认支付事件
function GuiStore:PurchaseCEventHandler(_purchaseCoin, _interactID)
    if _interactID == 99 then
        this:BuyItem(chosenItemID)
    end
end

--购买一个物品
function GuiStore:BuyItem(_itemID)
    --Data.Player.coin = Data.Player.coin - Config.Shop[curNpcID][_itemID].Price
    NetUtil.Fire_C('GetItemEvent', localPlayer, _itemID)
    wait(0.1)
    this:UpdateStoreUI()
end

--更新物品信息显示
function GuiStore:UpdateItemInfo(_itemID)
    if _itemID then
        LanguageUtil.SetText(gui.ShopPanel.NameTextBox.NameText, Config.Item[_itemID].Name, true, 40, 80)
        LanguageUtil.SetText(gui.ShopPanel.DesTextBox.DesText, Config.Item[_itemID].Des, true, 30, 60)
    else
        gui.ShopPanel.NameTextBox.NameText.Text = ''
        gui.ShopPanel.DesTextBox.DesText.Text = ''
    end
end

--更新购买按钮显示
function GuiStore:UpdateBuyBtn()
    if chosenItemID ~= 0 then
        gui.ShopPanel.BuyBtn:SetActive(true)
        gui.ShopPanel.BuyBtn.Locked:SetActive(false)
        gui.ShopPanel.BuyBtn.Text = LanguageUtil.GetText(Config.GuiText.ShopGui_3.Txt)
        for k, v in pairs(Data.Player.bag) do
            local typeConfig = Config.ItemType[Config.Item[k].Type]
            if k == chosenItemID and v.count > 0 and typeConfig.IsGetRepeatedly == false then
                gui.ShopPanel.BuyBtn.Locked:SetActive(true)
                gui.ShopPanel.BuyBtn.Text = LanguageUtil.GetText(Config.GuiText.ShopGui_4.Txt)
                break
            end
        end
        if Config.Shop[curNpcID][chosenItemID] then
            if Config.Shop[curNpcID][chosenItemID].Price > Data.Player.coin then
                gui.ShopPanel.BuyBtn.Locked:SetActive(true)
                gui.ShopPanel.BuyBtn.Text = LanguageUtil.GetText(Config.GuiText.ShopGui_2.Txt)
            end
        end
    else
        gui.ShopPanel.BuyBtn:SetActive(false)
    end
end

--更新一个物品Btn显示
function GuiStore:UpdateBuyBtnUI(_sellBtn)
    _sellBtn:SetActive(true)
    if _sellBtn.ItemID.Value == 0 then
        _sellBtn:SetActive(false)
    else
        --锁定显示
        --[[_sellBtn.GoodsImg.LockImg.Visible = false
        for k, v in pairs(Data.Player.bag) do
            local typeConfig = Config.ItemType[Config.Item[k].Type]
            if k == _sellBtn.ItemID.Value and v.count > 0 and typeConfig.IsGetRepeatedly == false then
                _sellBtn.GoodsImg.LockImg.Visible = true
                break
            end
        end]]
        --Icon和价格显示
        for k, v in pairs(Config.Item) do
            if v.ItemID == _sellBtn.ItemID.Value then
                local typeConfig = Config.ItemType[v.Type]
                _sellBtn.PriceImg.PriceTxt.Text = Config.Shop[curNpcID][v.ItemID].Price
                _sellBtn.Texture = ResourceManager.GetTexture('UI/Shop/' .. typeConfig.SColor)
                _sellBtn.GoodsImg.IMGNormal.Texture = ResourceManager.GetTexture('UI/ItemIcon/' .. v.Icon)
                if Config.Shop[curNpcID][v.ItemID].Price > Data.Player.coin then
                    _sellBtn.PriceImg.PriceTxt.Color = Color(255, 0, 0, 255)
                else
                    _sellBtn.PriceImg.PriceTxt.Color = Color(0, 86, 142, 255)
                end
                break
            end
        end
        --选择框显示
        if chosenItemID == _sellBtn.ItemID.Value then
            _sellBtn.GoodsImg.Chosen:SetActive(true)
        else
            _sellBtn.GoodsImg.Chosen:SetActive(false)
        end
    end
end

--重置一个购买Btn
function GuiStore:ResetBuyBtnUI(_sellBtn)
    _sellBtn.ItemID.Value = 0
    _sellBtn.GoodsImg.ShopBtn.OnClick:Clear()
end

--更新金币显示
function GuiStore:UpdateCoin()
    gui.ShopPanel.CoinInfo.CoinNum.Text = Data.Player.coin
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
    this:UpdateCoin()
    this:UpdateBuyBtn()
end

--开关商店显示
--GuiStore:SwitchStoreUIEventHandler(1, 1)
function GuiStore:SwitchStoreUIEventHandler(_switch, _npcID)
    if _switch == 1 then
        print('开商店显示', _npcID)
        curNpcID = _npcID
        this:GetItemData(Config.Shop[curNpcID])
        this:UpdateStoreUI(false)
        gui.Visible = true
    elseif _switch == 2 then
        this:UpdateStoreUI(true)
        curNpcID = 0
        gui.Visible = false
    end
end

return GuiStore
