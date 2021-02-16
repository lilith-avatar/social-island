---  商店UI模块：
-- @module  GuiStore
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
---@module GuiStore

local GuiStore, this = ModuleUtil.New("GuiStore", ClientBase)

local gui = localPlayer.Local.ShopGui

local oneLineNum = 4 ---每行的元素数量
local itemColumnSpacing = 0.02 --- 列间距
local itemRowSpacing = 0.1 ---行间距
local columnSpacing = 0.04 ---左右边缘的距离
local rowSpacing = 0.04 ---上下的距离 0.04
local oneItemWidth = (0.94 - (oneLineNum - 1) * itemColumnSpacing - 2 * columnSpacing) / oneLineNum
local oneItemHeight = 0.4
local VolumeTag = 1

local curNpcID = 0

function GuiStore:Init()
    print("GuiStore:Init")
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--节点引用
function GuiStore:NodeRef()
end

--数据变量声明
function GuiStore:DataInit()
end

--节点事件绑定
function GuiStore:EventBind()
    this.UI.ShopImg.ShopBtn.OnClick:Connect(
        function()
            this:SwitchStoreUI(1)
        end
    )
    this.UI.ShopPanel.CloseImg.CloseBtn.OnClick:Connect(
        function()
            this:SwitchStoreUI(2)
        end
    )
    this.UI.PurchasePanel.PurchaseBgImg.LaterBtn.OnClick:Connect(
        function()
            this:SwithConfirmUI(2, nil)
        end
    )
    for i = 1, 3, 1 do
        this.UI.ShopPanel["Tag" .. i .. "Btn"].OnClick:Connect(
            function()
                VolumeTag = i
                this:UpdateTagBtn()
                SoundEffect:PlaySound(2012)
            end
        )
    end
end

--初始化一个商店购买Btn
function GuiStore:InstanceBuyBtn(_itemID, _anchorsX, _anchorsY)
    if _itemID ~= nil then
        local parentNode = gui.ShopPanel.DragPanel.Panel1
        local tempBtn =
            world:CreateInstance("ShopBgImg", "ShopBtn" .. _itemID, parentNode, Vector3(0, 0, 0), EulerDegree(0, 0, 0))
        tempBtn.AnchorsX = _anchorsX
        tempBtn.AnchorsY = _anchorsY
        tempBtn.Offset = Vector2.Zero
        tempBtn.Size = Vector2.Zero
        tempBtn.ItemsID.Value = _itemID
        tempBtn.GoodsImg.ShopBtn.OnClick:Connect(
            function()
                this:SwithConfirmUI(1, _itemID)
            end
        )
        this:UpdateBuyBtnUI(tempBtn)
    end
end

--初始化商店
function GuiStore:InstanceStore(_itemIDList, _npcID)
    local volumeIndex = {1, 1, 1}
    curNpcID = _npcID
    for k, v in pairs(_itemIDList) do
        local x = volumeIndex[v.Volume] % oneLineNum
        local y = math.floor(volumeIndex[v.Volume] / oneLineNum) + 1
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
        volumeIndex[v.Volume] = volumeIndex[v.Volume] + 1

        this:InstanceBuyBtn(v, anchorsX, anchorsY)
    end
end

--开关确认支付面板
function GuiStore:SwithConfirmUI(_switch, _itemID)
    if _switch == 1 then
        this.UI.PurchasePanel.PurchaseBgImg.PriceFigure.ScoreText.Text = Data.Player.coin
        this.UI.PurchasePanel.PurchaseBgImg.PriceFigure.PriceText.Text = "/" .. Config.Shop[curNpcID][_itemID].Price
        if Data.Player.coin >= Config.Shop[curNpcID][_itemID].Price then
            this.UI.PurchasePanel.PurchaseBgImg.PurchaseBtn.LockImg.Visible = false
            this.UI.PurchasePanel.PurchaseBgImg.PurchaseBtn.OnClick:Connect(
                function()
                    this:BuyItem(_itemID)
                end
            )
        else
            this.UI.PurchasePanel.PurchaseBgImg.PurchaseBtn.LockImg.Visible = true
            this.UI.PurchasePanel.PurchaseBgImg.PurchaseBtn.OnClick:Clear()
        end
        this.UI.PurchasePanel.Visible = true
    elseif _switch == 2 then
        this.UI.PurchasePanel.PurchaseBgImg.PurchaseBtn.OnClick:Clear()
        this.UI.PurchasePanel.Visible = false
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
    --_sellBtn.GoodsImg.LockImg.Visible = true
    _sellBtn.GoodsImg.IMGNormal.Visible = false
    _sellBtn.PriceImg.Visible = true
    for k, v in pairs(Config.Item) do
        if v.ItemID == _sellBtn.ItemID.Value then
            _sellBtn.PriceImg.PriceTxt.Text = Config.Shop[curNpcID][v.ItemID].Price
            _sellBtn.GoodsImg.IMGNormal.Texture = ResourceManager.GetTexture("Local/UI/ItemIcon/" .. v.Ico)
            --_sellBtn.GoodsImg.IMGEmpty.Texture = ResourceManager.GetTexture("Local/UI/ItemIcon/" .. v.IconEmpty)
            break
        end
    end
    for k, v in pairs(Data.Player.bag) do
        if k == _sellBtn.ItemsID.Value and v.count > 0 then
            _sellBtn.GoodsImg.ShopBtn.OnClick:Clear()
            _sellBtn.GoodsImg.ShopBtn.Clickable = false
            _sellBtn.GoodsImg.LockImg.Visible = true
            _sellBtn.GoodsImg.IMGNormal.Visible = false
            _sellBtn.PriceImg.Visible = false
            break
        end
    end
end

--更新所有显示
function GuiStore:UpdateStoreUI()
    for k, v in pairs(this.UI.ShopPanel.DragPanel.Node1:GetChildren()) do
        this:UpdateBuyBtnUI(v)
    end
    for k, v in pairs(this.UI.ShopPanel.DragPanel.Node2:GetChildren()) do
        this:UpdateBuyBtnUI(v)
    end
    for k, v in pairs(this.UI.ShopPanel.DragPanel.Node3:GetChildren()) do
        this:UpdateBuyBtnUI(v)
    end
end

--开关商店显示
function GuiStore:SwitchStoreUI(_switch)
    if _switch == 1 then
        this:UpdateStoreUI()
        this.UI.ShopPanel.Visible = true
    elseif _switch == 2 then
        this.UI.ShopPanel.Visible = false
    end
end

return GuiStore
