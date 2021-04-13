---@module GuiCook
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local GuiCook, this = ModuleUtil.New('GuiCook', ClientBase)

---初始化函数
function GuiCook:Init()
    this:NodeDef()
    this:DataInit()
    this:EventBind()
end

function GuiCook:Test()
    NetUtil.Fire_C('GetItemEvent', localPlayer, 6043)
end

function GuiCook:DataInit()
    this.startUpdate = false
    this.timer = 0
    this.pageIndex = 1
    this.maxPage = 1
    this.UsingMaterial = {} --食材栏中的食材
    this.BagMaterial = {} --背包中的食材
    this.foodLocation = nil

    --* 背包物品显示参数-------------
    this.pageSize = 9

    --* 成品显示页面需要的参数
    this.foodId = nil
    this.totalDesk = 0
    this.remainDesk = 0
    --* 打赏需要的参数
    this.cookUserId = nil

    this.canEat = false
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
    this.MaterialSlot = {
        this.gui.MaterialPanel.Material1,
        this.gui.MaterialPanel.Material2,
        this.gui.MaterialPanel.Material3
    }
    --* 进度条的slot
    --* Button------------------
    this.cookBtn = this.gui.MaterialPanel.CookBtn -- 烹饪按钮
    this.closeBtn = this.gui.MaterialPanel.CloseImg.CloseBtn -- 关闭按钮
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
            NetUtil.Fire_C('PlayerCookEvent', localPlayer, this.UsingMaterial)
        end
    )
    this.closeBtn.OnClick:Connect(
        function()
            NetUtil.Fire_S('LeaveInteractSEvent', localPlayer, 26)
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
            NetUtil.Fire_C('SliderPurchaseEvent', localPlayer, 27, '请选择你要打赏的数量')
        end
    )
end

function GuiCook:TransItemTable()
    --先清空表
    this.BagMaterial = {}
    for k, v in pairs(Data.Player.bag) do
        if v.count > 0 and Config.Material[k] and Config.Material[k].MaterialType == 'Food' then
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
    if _gameId == 26 then
        this:ShowUI()
    elseif _gameId == 27 then
        if this.canEat then
            this:ShowDetail()
        else
            NetUtil.Fire_C('InsertInfoEvent', localPlayer, '宴会还没有开始，晚上再来吧', 2, false)
        end
    end
end

function GuiCook:PurchaseCEventHandler(_purchaseCoin, _interactID)
    if _interactID == 27 then
        this:HideGui()
        NetUtil.Fire_S('FoodRewardEvent', localPlayer.UserId, this.cookUserId, _purchaseCoin)
    end
end

function GuiCook:LeaveInteractCEventHandler(_gameId)
    if _gameId == 26 then
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
    this.foodLocation = nil
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
    table.sort(
        this.BagMaterial,
        function(v1, v2)
            return v1.id < v2.id
        end
    )
    this:ShowMaterialIcon()
    this:ClickChangePage(this.pageIndex)
    this:JudgeCookLocked()
end

function GuiCook:ChooseMaterial(_index)
    if #this.UsingMaterial >= 3 then
        return
    end
    table.insert(this.UsingMaterial, {id = this.BagMaterial[(this.pageIndex - 1) * this.pageSize + _index].id})
    table.remove(this.BagMaterial, _index + (this.pageIndex - 1) * this.pageSize)
    this:ClickChangePage(this.pageIndex)
    this:ShowMaterialIcon()
    this:JudgeCookLocked()
end

function GuiCook:JudgeCookLocked()
    if this.UsingMaterial and #this.UsingMaterial == 3 then
        this.cookBtn.Locked:SetActive(false)
    else
        this.cookBtn.Locked:SetActive(true)
    end
end

function GuiCook:ClearAllMaterial()
    this.UsingMaterial = {}
    this:ShowMaterialIcon()
    this.cookBtn.Locked:SetActive(true)
end

function GuiCook:ShowMaterialIcon()
    for k, v in ipairs(this.MaterialSlot) do
        if this.UsingMaterial[k] then
            --v.ItemImg:SetActive(true)
            v.ItemImg.IMGNormal.Texture =
                ResourceManager.GetTexture('UI/ItemIcon/' .. Config.Item[this.UsingMaterial[k].id].Icon)
            v.ItemImg.IMGNormal.Size = Vector2(128, 128)
            v.ItemImg.ItemText.Text = LanguageUtil.GetText(Config.Item[this.UsingMaterial[k].id].Name)
        else
            v.ItemImg.IMGNormal.Texture = ResourceManager.GetTexture('UI/Cook/Result/CS_AVG_Icon_Food_1')
            v.ItemImg.IMGNormal.Size = Vector2(138, 151)
            v.ItemImg.ItemText.Text = 'Pick One'
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
        this.slotList[_index].ItemID.Value = ''
        return
    end
    -- 更换图片
    this.slotList[_index].ItemImg.IMGNormal.Texture =
        ResourceManager.GetTexture('UI/ItemIcon/' .. Config.Item[_itemId].Icon)
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
    this.titleTxt.Text = LanguageUtil.GetText(Config.CookMenu[this.foodId].Name)
    this.foodPanel:SetActive(true)
end

function GuiCook:SycnDeskFoodNumEventHandler(_cur, _total)
    this.deskBtn.Text = 'PUT ON DESK(' .. _cur .. '/' .. _total .. ')'
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

function GuiCook:SetSelectFoodEventHandler(_foodId, _cookName, _cookUserId, _foodLocation)
    this.detailName.Text = LanguageUtil.GetText(Config.CookMenu[_foodId].Name)
    this.authorName.Text = 'By ' .. _cookName
    this.cookUserId = _cookUserId
    this.foodId = _foodId
    this.foodLocation = _foodLocation
    -- 无法打赏自己做的菜
    if this.cookUserId == localPlayer.UserId or Data.Player.coin <= 0 then
        this.detailReward:SetActive(false)
    else
        this.detailReward:SetActive(true)
    end
end

function GuiCook:EatFood()
    NetUtil.Fire_C(
        'GetBuffEvent',
        localPlayer,
        Config.CookMenu[this.foodId].BuffId,
        Config.CookMenu[this.foodId].BuffDur
    )
    NetUtil.Fire_C('EatFoodEvent',localPlayer,this.foodId)
    this:HideGui()
    NetUtil.Fire_C('ChangeMiniGameUIEvent', localPlayer)
    if this.foodLocation then
        NetUtil.Fire_S('PlayerEatFoodEvent',this.foodLocation)
    end
    this.foodId = nil
    --this:ShowUI()
end

function GuiCook:PutOnDesk()
    NetUtil.Fire_S('FoodOnDeskEvent', this.foodId, localPlayer)
    this.foodId = nil
    NetUtil.Fire_C('ChangeMiniGameUIEvent',localPlayer)
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
            this.timer = 0
            this:ShowFood()
        end
    end
end

function GuiCook:SycnTimeCEventHandler(_clock)
    if _clock >= 19 or _clock <= 6 then
        this.canEat = true
    else
        this.canEat = false
    end
end

function GuiCook:PurchaseCEventHandler(_purchaseCoin, _interactID)
    if _interactID == 27 then
        this:EatFood()
    end
end

return GuiCook
