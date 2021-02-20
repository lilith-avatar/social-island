---  商店UI模块：
-- @module  GuiStore
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
---@module GuiStore

local GuiStore, this = ModuleUtil.New("GuiStore", ClientBase)

local gui

local oneLineNum = 4 ---每行的元素数量
local itemColumnSpacing = 0.02 --- 列间距
local itemRowSpacing = 0.1 ---行间距
local columnSpacing = 0.04 ---左右边缘的距离
local rowSpacing = 0.04 ---上下的距离 0.04
local oneItemWidth = (0.94 - (oneLineNum - 1) * itemColumnSpacing - 2 * columnSpacing) / oneLineNum
local oneItemHeight = 0.4

local curNpcID

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
    this:InstanceStore(40)
end

--节点事件绑定
function GuiStore:EventBind()
    gui.ShopPanel.CloseImg.CloseBtn.OnClick:Connect(
        function()
            NetUtil.Fire_C("SwitchStoreUIEvent", localPlayer, 2)
        end
    )
    gui.PurchasePanel.PurchaseBgImg.LaterBtn.OnClick:Connect(
        function()
            this:SwithConfirmUI(2, nil)
        end
    )
end

--初始化一个商店购买Btn
function GuiStore:InstanceBuyBtn(_index, _anchorsX, _anchorsY)
    local parentNode = gui.ShopPanel.DragPanel.Panel1
    local tempBtn =
        world:CreateInstance("ShopBgImg", "ShopBtn" .. _index, parentNode, Vector3(0, 0, 0), EulerDegree(0, 0, 0))
    tempBtn.AnchorsX = _anchorsX
    tempBtn.AnchorsY = _anchorsY
    tempBtn.Offset = Vector2.Zero
    tempBtn.Size = Vector2.Zero
    tempBtn.ItemID.Value = 0
end

--初始化商店
function GuiStore:InstanceStore(_itemNum)
    local index = 1
    for i = 1, _itemNum do
        local x = index % oneLineNum
        local y = math.floor(index / oneLineNum) + 1
        if x == 0 then
            x = oneLineNum
            y = y - 1
        end
        local anchorsX =
            Vector2(
            (x - 1) * (oneItemWidth + itemColumnSpacing) + columnSpacing,
            (x - 1) * (oneItemWidth + itemColumnSpacing) + columnSpacing + oneItemWidth
        )
        local anchorsY =
            Vector2(
            1 - ((y - 1) * (oneItemHeight + itemRowSpacing) + rowSpacing + oneItemHeight),
            1 - ((y - 1) * (oneItemHeight + itemRowSpacing) + rowSpacing)
        )
        index = index + 1
        this:InstanceBuyBtn(i, anchorsX, anchorsY)
    end
end

--获取商店出售物品data
function GuiStore:GetItemData(_itemData)
    for k, v in pairs(_itemData) do
        gui.ShopPanel.DragPanel.Panel1["ShopBtn" .. v.Index].ItemID.Value = v.ItemId
        gui.ShopPanel.DragPanel.Panel1["ShopBtn" .. v.Index].GoodsImg.ShopBtn.OnClick:Connect(
            function()
                this:SwithConfirmUI(1, v.ItemId)
            end
        )
    end
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

--更新一个购买Btn显示
function GuiStore:UpdateBuyBtnUI(_sellBtn)
    if _sellBtn.ItemID.Value == 0 then
        _sellBtn:SetActive(false)
    else
        --_sellBtn.GoodsImg.LockImg.Visible = true
        _sellBtn.GoodsImg.IMGNormal.Visible = true
        _sellBtn.PriceImg.Visible = true
        for k, v in pairs(Config.Item) do
            if v.ItemID == _sellBtn.ItemID.Value then
                _sellBtn.PriceImg.PriceTxt.Text = Config.Shop[curNpcID][v.ItemID].Price
                _sellBtn.GoodsImg.IMGNormal.Texture = ResourceManager.GetTexture("UI/ItemIcon/" .. v.Icon)
                --_sellBtn.GoodsImg.IMGEmpty.Texture = ResourceManager.GetTexture("Local/UI/ItemIcon/" .. v.IconEmpty)
                break
            end
        end
        for k, v in pairs(Data.Player.bag) do
            if
                k == _sellBtn.ItemID.Value and v.count > 0 and
                    tonumber(string.sub(tostring(_sellBtn.ItemID.Value), 1, 1)) < 6
             then
                _sellBtn.GoodsImg.ShopBtn.OnClick:Clear()
                _sellBtn.GoodsImg.ShopBtn.Clickable = false
                _sellBtn.GoodsImg.LockImg.Visible = true
                _sellBtn.GoodsImg.IMGNormal.Visible = false
                _sellBtn.PriceImg.Visible = false
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
