---@module GuiBag
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local GuiBag, this = ModuleUtil.New("GuiBag", ClientBase)
local Config = Config.Item

local transTab, tmp
---对背包后端数据传过来的表进行转换
---@param _itemTable table
---@return table
local function TransformItemTable(_itemTable)
    transTab = {}

    for k, v in pairs(_itemTable) do
        for i = 1, v.count do
            local data = {
                id = k,
                cd = 0
            }
            table.merge(data, v)
            table.insert(transTab, data)
        end
    end
    tmp =
        table.sort(
        transTab,
        function(a, b)
            if a and b then
                return (a.id < b.id)
            end
        end
    )
    return transTab --! Only Test
end

---初始化函数
function GuiBag:Init()
    this:NodeDef()
    this:DataInit()
    this:SlotCreate()
    this:EventBind()
end

function GuiBag:NodeDef()
    this.root = localPlayer.Local.BagGui
    this.gui = this.root.BagPnl
    this.slotList = {}

    --* Button------------
    this.useBtn = this.gui.UseBtn
    this.nextBtn = this.gui.NextBtn
    this.prevBtn = this.gui.PrevBtn
    this.backBtn = this.gui.BackBtn

    --* Text--------------
    this.nameTxt = this.gui.NameTxt
    this.descTxt = this.gui.DescTxt
    this.pageTxt = this.gui.pageTxt
end

function GuiBag:DataInit()
    this.slotItem = {}
    this.pageIndex = 1 -- 页面序号
    this.maxPage = nil -- 最大页数
    this.selectIndex = nil

    --* 背包物品显示参数-------------
    this.rowNum = 10
    this.colNum = 5

    --* 计时器---------------
    this.timer = {}
    this.cdMask = {}
end

--单元格生成
local slot
function GuiBag:SlotCreate()
    for i = 1, this.rowNum * this.colNum do
        slot = world:CreateInstance("SlotImg", "SlotImg", this.gui.SlotPnl)
        --插入到表
        table.insert(this.slotList, slot)
        -- 调整位置
        slot.AnchorsX =
            Vector2((math.fmod(i, this.rowNum) - 1) * (1 / this.rowNum), math.fmod(i, this.rowNum) * (1 / this.rowNum))
        slot.AnchorsY =
            Vector2(
            1.1 - (math.modf(i / this.rowNum) + 1) * 1 / this.colNum,
            1.1 - (math.modf(i / this.rowNum) + 1) * 1 / this.colNum
        )
        -- 绑定事件
        slot.SelectBtn.OnClick:Connect(
            function()
                this:SelectItem(i)
            end
        )
    end
end

function GuiBag:EventBind()
    this.useBtn.OnClick:Connect(
        function()
            this:ClickUseBtn(this.selectIndex)
        end
    )
    this.nextBtn.OnClick:Connect(
        function()
            this:ClickChangePage(this.pageIndex + 1)
        end
    )
    this.prevBtn.OnClick:Connect(
        function()
            this:ClickPrePage(this.pageIndex - 1)
        end
    )
    this.backBtn.OnClick:Connect(
        function()
            this:HideBagUI()
        end
    )
end

function GuiBag:ShowBagUI()
    this:ClearSelect()
    this.root:SetActive(true)
    -- 转表
    this.slotItem = TransformItemTable(Data.Player.bag)
    -- 显示物品
    this:ClickChangePage(1)
    -- 根据长度获取最大页数
    this:GetMaxPageNum(#this.slotItem)
end

function GuiBag:HideBagUI()
    this.root:SetActive(false)
end

function GuiBag:ShowItemByIndex(_index, _itemId)
    this.slotItem[_index].id = _itemId
    -- 更换图片
    this.slotList[_index].IconImg.Texture = ResourceManager.GetTexture("UI/" .. Config.Item[_itemId].Ico)
    this.slotList[_index].IconImg.Size = this.slotList[_index].Size
    this.slotList[_index].IconImg:SetActive(_itemId and true or false)

    -- 若存在cd,则将mask放入表中
    if not this.cdMask[_itemId] then
        this.cdMask[_itemId] = {}
    end
    table.insert(this.cdMask[_itemId], this.slotList[_index].MaskImg)

    -- 红点系统前端表现
    -- if this.slotItem[_index].isNew and this.slotItem[_index] then
    --     --消除红点
    --     this.slotList[_index].RedDotImg:SetActive(true)
    -- end
end

function GuiBag:ClickUseBtn(_index)
    if not this.selectIndex or this.timer[this.slotItem[((this.pageIndex - 1) * this.rowNum * this.colNum) + _index].id] then
        return
    end
    local itemId = this.slotItem[((this.pageIndex - 1) * this.rowNum * this.colNum) + _index].id
    this.cdMask[itemId] = {this.slotList[_index].MaskImg}
    -- 该cd物品进入 cd
    this.timer[itemId] = 0
    -- TODO: 使用物品
    -- 物品消耗判定
    if not this.slotItem[((this.pageIndex - 1) * this.rowNum * this.colNum) + _index].isConst then
        table.remove(this.slotItem, ((this.pageIndex - 1) * this.rowNum * this.colNum) + _index)
        Data.Player.bag[itemId].count = Data.Player.bag[itemId].count - 1
    end
    -- 重新展示当前页面物品信息
    this:ClickChangePage(this.pageIndex)
    -- 清除选择
    this:ClearSelect()
end

---选中物品
function GuiBag:SelectItem(_index)
    if this.slotItem[_index] then
        this:ClearSelect()
        this.selectIndex = _index
        -- 进行名字和描述的更换,并高亮该物品
        this:ChangeNameAndDesc(this.slotItem[_index].id)
        -- TODO: 高亮
        this.slotList[_index].Image = ResourceManager.GetTexture("UI/")
        --开启使用按钮
        this.useBtn:SetActive(true)
    -- 红点系统前端表现
    -- if this.slotItem[_index].isNew and this.slotItem[_index] then
    --     --消除红点
    --     this.slotList[_index].RedDotImg:SetActive(false)
    -- end
    end
end

function GuiBag:ClearSelect()
    if this.selectIndex then
        -- TODO: 清除高亮
        this.slotList[this.selectIndex].Image = ResourceManager.GetTexture("UI/Btn_Left")
        this.selectIndex = nil
        --清除描述
        this.nameTxt.Text = " "
        this.descTxt.Text = " "
        this.useBtn:SetActive(false)
    end
end

function GuiBag:ClickChangePage(_pageIndex)
    --清除cdmask
    this.cdMask = {}
    this:ClearSelect()
    this:ShowItemsByPageIndex(_pageIndex)

    --页面数字显示
    this.pageTxt = tostring(math.floor(_pageIndex))
    --如果第一页则不显示上一页按钮
    if _pageIndex == 1 then
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
    table.dump(print(this.cdMask))
end

function GuiBag:ChangeNameAndDesc(_itemId)
    this.nameTxt.Text = LanguageUtil.GetText(Config.Item[_itemId].Name)
    this.descTxt.Text = LanguageUtil.GetText(Config.Item[_itemId].Des)
end

function GuiBag:ShowItemsByPageIndex(_pageIndex)
    for i = 1, this.rowNum * this.colNum do
        if this.slotItem[(_pageIndex - 1) * this.colNum * this.rowNum + i] then
            -- 显示当前页面物品
            this:ShowItemByIndex(i, this.slotItem[(_pageIndex - 1) * this.colNum * this.rowNum + i].id)
        else
            this.slotList[i].MaskImg.FillAmount = 0
            this.slotList[i].IconImg:SetActive(false)
        end
    end
end

---更新最大页面数
function GuiBag:GetMaxPageNum(_itemNum)
    this.maxPage = math.ceil(_itemNum / (this.colNum * this.rowNum))
    if this.maxPage == 0 then
        this.maxPage = 1
    end
end

---计时器进行冷却计时
function GuiBag:Update(dt)
    for k, v in pairs(this.timer) do
        this.timer[k] = this.timer[k] + dt
        if this.cdMask[k] then
            -- CD表现
            for _, n in pairs(this.cdMask[k]) do
                n.FillAmount = 1 - this.timer[k] / Config.Item[k].UseCD
            end
        end
        if this.timer[k] >= Config.Item[k].UseCD then
            this.timer[k] = nil
        end
    end
end

return GuiBag
