---@module GuiBag
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local GuiBag, this = ModuleUtil.New("GuiBag", ClientBase)

---初始化函数
function GuiBag:Init()
    this:NodeDef()
    this:DataInit()
    this:EventBind()
end

function GuiBag:NodeDef()
    this.root = localPlayer.Local.BagGui
    this.gui = this.root.BagPanel
    this.slotList = this.gui.DragPanel.SlotPanel:GetChildren()

    --* Button------------
    this.useBtn = this.gui.UseBtn
    this.closeBtn = this.gui.CloseImg.CloseBtn
    this.prevBtn = this.gui.DragPanel.PreBtn
    this.nextBtn = this.gui.DragPanel.NextBtn

    --* Text--------------
    this.nameTxt = this.gui.NameTextBox.NameText
    this.descTxt = this.gui.DesTextBox.DesText
    this.pageTxt = this.gui.DragPanel.PageText
    this.coinTxt = this.gui.CoinInfo.CoinNum
end

function GuiBag:DataInit()
    this.slotItem = {}
    this.pageIndex = 1 -- 页面序号
    this.maxPage = 1 -- 最大页数
    this.selectIndex = nil

    --* 背包物品显示参数-------------
    this.pageSize = 15
end

function GuiBag:EventBind()
    this.closeBtn.OnClick:Connect(
        function()
            this:HideBagUI()
        end
    )
    this.useBtn.OnClick:Connect(
        function()
            this:ClickUseBtn(this.selectIndex)
        end
    )
    this.prevBtn.OnClick:Connect(
        function()
            this:ClickChangePage(this.pageIndex - 1)
        end
    )
    this.nextBtn.OnClick:Connect(
        function()
            this:ClickChangePage(this.pageIndex + 1)
        end
    )
    --单元格按键事件绑定
    for k, v in pairs(this.slotList) do
        v.ItemImg.SelectBtn.OnClick:Connect(
            function()
                this:SelectItem(k)
            end
        )
    end
end

function GuiBag:TransItemTable()
    --先清空表
    this.slotItem = {}
    for k, v in pairs(Data.Player.bag) do
        if v.count > 0 then
            local data = {
                num = v.count,
                id = k,
                cd = 0
            }
            table.insert(this.slotItem, data)
        end
    end
end

function GuiBag:ShowBagUI()
    this:ClearSelect()
    this.root:SetActive(true)
    -- 转表
    this:TransItemTable()
    -- 显示物品
    this:ClickChangePage(1)
    -- 根据长度获取最大页数
    this:GetMaxPageNum(#this.slotItem)
    -- 显示金钱
    this.coinTxt.Text = math.floor(Data.Player.coin)
end

function GuiBag:HideBagUI()
    this.root:SetActive(false)
end

function GuiBag:ShowItemByIndex(_index, _itemId)
    if not _itemId then
        this.slotList[_index]:SetActive(false)
        this.slotList[_index].ItemID.Value = ""
        return
    end
    this.slotList[_index].ItemID.Value = _itemId
    -- 更换图片
    this.slotList[_index].ItemImg.IMGNormal.Texture =
        ResourceManager.GetTexture("UI/ItemIcon/" .. Config.Item[_itemId].Icon)
    -- 显示数量
    this.slotList[_index].ItemNumBg.NumText.Text = Data.Player.bag[_itemId].count
    this.slotList[_index].ItemNumBg:SetActive(Data.Player.bag[_itemId].count ~= 1)
    this.slotList[_index].ItemImg.IMGNormal.Size = Vector2(128, 128)
    this.slotList[_index]:SetActive(_itemId and true or false)
end

function GuiBag:ClickUseBtn(_index)
    if not this.selectIndex then
        return
    end
    local itemId = this.slotList[_index].ItemID.Value
    -- 使用物品
    NetUtil.Fire_C("UseItemInBagEvent", localPlayer, itemId)
    -- 物品消耗判定
    this:ConsumeItem(_index)
    -- 重新展示当前页面物品信息
    this:ClickChangePage(this.pageIndex)
    -- 清除选择
    this:ClearSelect()
end

function GuiBag:ConsumeItem(_index)
    if Config.ItemType[Config.Item[this.slotItem[(this.pageIndex - 1) * this.pageSize + _index].id].Type].IsConsume then
        this.slotItem[(this.pageIndex - 1) * this.pageSize + _index].num =
            this.slotItem[(this.pageIndex - 1) * this.pageSize + _index].num - 1
        if this.slotItem[(this.pageIndex - 1) * this.pageSize + _index].num <= 0 then
            table.remove(this.slotItem, (this.pageIndex - 1) * this.pageSize + _index)
        end
    end
end

---选中物品
function GuiBag:SelectItem(_index)
    if this.slotList[_index].ItemID.Value then
        this:ClearSelect()
        this.selectIndex = _index
        -- 进行名字和描述的更换,并高亮该物品
        this:ChangeNameAndDesc(this.slotList[_index].ItemID.Value)
        this.slotList[_index].ItemImg.Chosen:SetActive(true)
        --判断是否开启使用按钮
        if Config.ItemType[Config.Item[this.slotList[_index].ItemID.Value].Type].IsUseable then
            this.useBtn:SetActive(true)
        end
    end
end

function GuiBag:ClearSelect()
    --清除描述
    this.nameTxt.Text = " "
    this.descTxt.Text = " "
    this.useBtn:SetActive(false)
    if this.selectIndex then
        this.slotList[this.selectIndex].ItemImg.Chosen:SetActive(false)
        --this.slotList[this.selectIndex].Image = ResourceManager.GetTexture("UI/Btn_Left")
        this.selectIndex = nil
    end
end

function GuiBag:ClickChangePage(_pageIndex)
    this:ClearSelect()
    this:ShowItemsByPageIndex(_pageIndex)
    this:RefreshPageBar(_pageIndex)
end

function GuiBag:RefreshPageBar(_pageIndex)
    this.pageIndex = _pageIndex
    --页面数字显示
    this.pageTxt.Text = tostring(math.floor(_pageIndex))
    --先全部打开
    this.prevBtn.UnableImg:SetActive(false)
    this.nextBtn.UnableImg:SetActive(false)
    --如果第一页则不显示上一页按钮
    if _pageIndex <= 1 then
        this.prevBtn.UnableImg:SetActive(true)
    end
    --如果最后一页不显示下一页按钮
    if _pageIndex == this.maxPage then
        this.nextBtn.UnableImg:SetActive(true)
    end
    --其他情况打开全部按钮
    if _pageIndex ~= 1 and _pageIndex ~= this.maxPage then
        this.prevBtn.UnableImg:SetActive(false)
        this.nextBtn.UnableImg:SetActive(false)
    end
end

function GuiBag:ChangeNameAndDesc(_itemId)
    this.nameTxt.Text = LanguageUtil.GetText(Config.Item[_itemId].Name)
    this.descTxt.Text = LanguageUtil.GetText(Config.Item[_itemId].Des)
end

function GuiBag:ShowItemsByPageIndex(_pageIndex)
    for i = 1, this.pageSize do
        if this.slotItem[(_pageIndex - 1) * this.pageSize + i] then
            -- 显示当前页面物品
            this:ShowItemByIndex(i, this.slotItem[(_pageIndex - 1) * this.pageSize + i].id)
        else
            this.slotList[i]:SetActive(false)
        end
    end
    this:GetMaxPageNum(#this.slotItem)
end

---更新最大页面数
function GuiBag:GetMaxPageNum(_itemNum)
    this.maxPage = math.ceil(_itemNum / (this.pageSize))
    if this.maxPage <= 0 then
        this.maxPage = 1
    end
end

---计时器进行冷却计时
function GuiBag:Update(dt)
end

return GuiBag
