---@module GuiCook
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local GuiCook, this = ModuleUtil.New("GuiCook", ClientBase)

---初始化函数
function GuiCook:Init()
    this:NodeDef()
    this:DataInit()
    this:EventBind()
end

function GuiCook:Test()
    NetUtil.Fire_C("GetItemEvent", localPlayer, 6043)
end

function GuiCook:DataInit()
    this.startUpdate = false
    this.timer = 0
    this.pageIndex = 1
    this.maxPage = 1
    this.UsingMaterial = {} --食材栏中的食材
    this.BagMaterial = {} --背包中的食材

    --* 背包物品显示参数-------------
    this.pageSize = 9

    --* 成品显示页面需要的参数
    this.foodId = nil
    this.totalDesk = 0
    this.remainDesk = 0
end

function GuiCook:NodeDef()
    this.root = localPlayer.Local.CookGui
    this.gui = this.root.CookPanel
    this.progressPanel = this.root.ProgressPanel
    this.foodPanel = this.root.FoodPanel
    this.detailPanel = this.root.DetailPanel
    --* 背包中食材的slot
    this.slotList = this.gui.DragPanel.SlotPanel:GetChildren()
    --* 显示材料的slot
    this.MaterialSlot = this.gui.MaterialPanel:GetChildren()
    --* 进度条的slot
    --* Button------------------
    this.cookBtn = this.gui.CookBtn -- 烹饪按钮
    this.closeBtn = this.gui.CloseImg.CloseBtn -- 关闭按钮
    this.prevBtn = this.gui.DragPanel.PreBtn -- 上一页按钮
    this.nextBtn = this.gui.DragPanel.NextBtn -- 下一页按钮
    this.eatBtn = this.foodPanel.EatBtn
    this.deskBtn = this.foodPanel.DeskBtn
    --* Text--------------------
    this.pageTxt = this.gui.DragPanel.PageText
    this.titleTxt = this.foodPanel.TitleTxt
    this.numTxt = this.foodPanel.NumTxt
    --* icon--------------------
    this.foodIcon = this.foodPanel.IconImg
    --* 做饭的进度条
    this.progress = this.progressPanel.ProgressBar.ProgressImg
    --* 吃东西时候的信息ui
    this.detailName = this.detailPanel.TitleTxt
    this.authorName = this.detailPanel.AuthorTxt
    this.detailEatBtn = this.detailPanel.EatBtn
    this.detailReward = this.detailPanel.RewardBtn
end

function GuiCook:EventBind()
    --单元格按键事件绑定
    for k, v in pairs(this.slotList) do
        v.ItemImg.SelectBtn.OnClick:Connect(
            function()
                this:ChooseMaterial(k)
            end
        )
    end
    for k, v in ipairs(this.MaterialSlot) do
        v.ItemImg.SelectBtn.OnClick:Connect(
            function()
                this:CancelMaterial(k)
            end
        )
    end
    this.cookBtn.OnClick:Connect(
        function()
            this:StartCook()
            NetUtil.Fire_C("PlayerCookEvent", localPlayer, this.UsingMaterial)
        end
    )
    this.closeBtn.OnClick:Connect(
        function()
            this:HideGui()
        end
    )
    this.eatBtn.OnClick:Connect(
        function()
            this:EatFood()
        end
    )
    this.deskBtn.OnClick:Connect(
        function()
            this:PutOnDesk()
        end
    )
    this.detailEatBtn.OnClick:Connect(
        function()
            this:EatFood()
        end
    )
    this.detailReward.OnClick:Connect(
        function()
            NetUtil.Fire_C("SliderPurchaseEvent", localPlayer, 27, "请选择你要打赏的数量")
        end
    )
end

function GuiCook:TransItemTable()
    --先清空表
    this.BagMaterial = {}
    for k, v in pairs(Data.Player.bag) do
        if v.count > 0 and Config.RewardItem[k] then
            local data = {
                id = k
            }
            table.insert(this.BagMaterial, data)
        end
    end
    table.sort(
        this.BagMaterial,
        function(i1, i2)
            return i1.id < i2.id
        end
    )
end

function GuiCook:ShowUI()
    this:ClearAllMaterial()
    this:TransItemTable()
    this.progressPanel:SetActive(false)
    this.foodPanel:SetActive(false)
    this.detailPanel:SetActive(false)
    this.root:SetActive(true)
    this.gui:SetActive(true)
    this:ClickChangePage(1)
end

function GuiCook:ShowDetail()
    this.progressPanel:SetActive(false)
    this.foodPanel:SetActive(false)
    this.detailPanel:SetActive(true)
    this.gui:SetActive(false)
    this.root:SetActive(true)
end

function GuiCook:InteractCEventHandler(_gameId)
    if _gameId == 27 then
        this:ShowDetail()
    end
end

function GuiCook:PurchaseCEventHandler(_purchaseCoin, _interactID)
    if _interactID == 27 then
        this:HideGui()
    end
end

function GuiCook:LeaveInteractCEventHandler(_gameId)
    if _gameId == 99 then
        this:HideGui()
    end
end

function GuiCook:HideGui()
    this.root:SetActive(false)
end

function GuiCook:StartCook()
    if #this.UsingMaterial == 0 or not this.UsingMaterial then
        return
    end
    --开始烹饪
    this.gui:SetActive(false)
    --打开进度条
    this.progressPanel:SetActive(true)
    this.startUpdate = true
end

function GuiCook:GetFinalFoodEventHandler(_foodId)
    this.foodId = _foodId
end

function GuiCook:CancelMaterial(_index)
    if not this.UsingMaterial[_index] then
        return
    end
    table.insert(this.BagMaterial, this.UsingMaterial[_index])
    table.remove(this.UsingMaterial, _index)
    if #this.UsingMaterial == 0 or not this.UsingMaterial then
        this.cookBtn.Locked:SetActive(true)
    end
    table.sort(
        this.BagMaterial,
        function(v1, v2)
            return v1.id < v2.id
        end
    )
    this:ShowMaterialIcon()
    this:ClickChangePage(this.pageIndex)
end

function GuiCook:ChooseMaterial(_index)
    if #this.UsingMaterial >= 3 then
        return
    end
    this.cookBtn.Locked:SetActive(false)
    table.insert(this.UsingMaterial, {id = this.BagMaterial[(this.pageIndex - 1) * this.pageSize + _index].id})
    table.remove(this.BagMaterial, _index + (this.pageIndex - 1) * this.pageSize)
    this:ClickChangePage(this.pageIndex)
    this:ShowMaterialIcon()
end

function GuiCook:ClearAllMaterial()
    this.UsingMaterial = {}
    this:ShowMaterialIcon()
    this.cookBtn.Locked:SetActive(true)
end

function GuiCook:ShowMaterialIcon()
    for k, v in ipairs(this.MaterialSlot) do
        if this.UsingMaterial[k] then
            v.ItemImg.IMGNormal.Texture =
                ResourceManager.GetTexture("UI/ItemIcon/" .. Config.Item[this.UsingMaterial[k].id].Icon)
            v.ItemImg.IMGNormal.Size = Vector2(128, 128)
            v.ItemImg:SetActive(true)
        else
            v.ItemImg:SetActive(false)
        end
    end
end

function GuiCook:ClickChangePage(_pageIndex)
    this:GetMaxPageNum(#this.BagMaterial)
    if _pageIndex > this.maxPage then
        _pageIndex = this.maxPage
    end
    this:ShowItemsByPageIndex(_pageIndex)
    this:RefreshPageBar(_pageIndex)
end

function GuiCook:ShowItemsByPageIndex(_pageIndex)
    for i = 1, this.pageSize do
        if this.BagMaterial[(_pageIndex - 1) * this.pageSize + i] then
            -- 显示当前页面物品
            this:ShowItemByIndex(i, this.BagMaterial[(_pageIndex - 1) * this.pageSize + i].id)
        else
            this.slotList[i]:SetActive(false)
        end
    end
    this:GetMaxPageNum(#this.BagMaterial)
end

function GuiCook:ShowItemByIndex(_index, _itemId)
    if not _itemId then
        this.slotList[_index]:SetActive(false)
        this.slotList[_index].ItemID.Value = ""
        return
    end
    -- 更换图片
    this.slotList[_index].ItemImg.IMGNormal.Texture =
        ResourceManager.GetTexture("UI/ItemIcon/" .. Config.Item[_itemId].Icon)
    -- 显示数量
    this.slotList[_index].ItemImg.IMGNormal.Size = Vector2(128, 128)
    this.slotList[_index].NameTxt.Text = LanguageUtil.GetText(Config.Item[_itemId].Name)
    this.slotList[_index]:SetActive(_itemId and true or false)
end

---更新最大页面数
function GuiCook:GetMaxPageNum(_itemNum)
    this.maxPage = math.ceil(_itemNum / (this.pageSize))
    if this.maxPage <= 0 then
        this.maxPage = 1
    end
end

function GuiCook:RefreshPageBar(_pageIndex)
    this.pageIndex = _pageIndex
    --页面数字显示
    this.pageTxt.Text = tostring(math.floor(_pageIndex))
    --如果第一页则不显示上一页按钮
    if _pageIndex <= 1 then
        this.prevBtn:SetActive(false)
    end
    --如果最后一页不显示下一页按钮
    if _pageIndex == this.maxPage then
        this.nextBtn:SetActive(false)
    end
    --其他情况打开全部按钮
    if _pageIndex ~= 1 and _pageIndex ~= this.maxPage then
        this.prevBtn:SetActive(true)
        this.nextBtn:SetActive(true)
    end
end

function GuiCook:ShowFood()
    if not this.foodId then
        invoke(
            function()
                this:ShowFood()
            end,
            0.5
        )
        return
    end
    this:ConsumeMaterial()
    this.titleTxt.Text = "你做出了" .. LanguageUtil.GetText(Config.CookMenu[this.foodId].Name)
    this.foodPanel:SetActive(true)
end

function GuiCook:SycnDeskFoodNumEventHandler(_cur, _total)
    this.numTxt.Text = _cur .. " / " .. _total
    if _cur >= _total then
        --禁止上桌
        this.deskBtn.Locked:SetActive(true)
    else
        this.deskBtn.Locked:SetActive(false)
    end
end

function GuiCook:ConsumeMaterial()
    for k, v in pairs(this.UsingMaterial) do
        Data.Player.bag[v.id].count = Data.Player.bag[v.id].count - 1
    end
end

function GuiCook:SetSelectFoodEventHandler(_foodId, _cookName)
    print(_foodId)
    this.detailName.Text = LanguageUtil.GetText(Config.CookMenu[_foodId].Name)
    this.authorName.Text = "By " .. _cookName
end

function GuiCook:EatFood()
    this.foodId = nil
    this:ShowUI()
end

function GuiCook:PutOnDesk()
    NetUtil.Fire_S("FoodOnDeskEvent", this.foodId, localPlayer)
    this.foodId = nil
    this:ShowUI()
end

function GuiCook:Update(dt)
    if this.startUpdate then
        this.timer = this.timer + dt
        this.progress.FillAmount = this.timer / 5
        if this.progress.FillAmount >= 1 then
            this.startUpdate = false
            this.progressPanel:SetActive(false)
            --this.gui:SetActive(true)
            this.progress.FillAmount = 0
            this:ShowFood()
        end
    end
end

return GuiCook
