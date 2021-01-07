---@module GuiBag
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local GuiBag, this = ModuleUtil.New("GuiBag", ClientBase)
local Config = Config

local transTab, tmp
---对背包后端数据传过来的表进行转换
---@param _itemTable table
---@return table
local function TransformItemTable(_itemTable)
    transTab = {}
    tmp =
        table.sort(
        _itemTable,
        function(a, b)
            if a and b then
                return (a.id < b.id)
            end
        end
    )
    for _, v in pairs(_itemTable) do
        for i = 1, v.count do
            table.insert(transTab, v)
        end
    end
    return transTab
end

---初始化函数
function GuiBag:Init()
    print("GuiBag: Init")
    this:NodeDef()
    this:DataInit()
    this:SlotCreate()
    this:EventBind()
end

function GuiBag:NodeDef()
    this.gui = localPlayer.Local.BagGui.BagPnl
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
    this.gui:SetActive(true)
end

function GuiBag:HideBagUI()
    this.gui:SetActive(false)
end

function GuiBag:ShowItemByIndex(_index, _itemId)
    this.slotItem[_index] = _itemId
    -- TODO: 更换图片
    this.slotList[_index].Image = ResourceManager.GetTexture("")
    this.slotList[_index].Image:SetActive(_itemId and true or false)
end

function GuiBag:ClickUseBtn(_index)
    if not this.selectIndex then
        return
    end
    -- TODO: 使用物品
    -- 进行物品的使用
    if this.slotItem[((this.pageIndex - 1) * this.rowNum * this.colNum) + _index].isConst then
        -- 不移除
    else
        -- 移除
        table.remove(this.slotItem, ((this.pageIndex - 1) * this.rowNum * this.colNum) + _index)
    end
    -- 重新展示当前页面物品信息
    this:ClickChangePage(this.pageIndex)
    -- 清除选择
    this:ClearSelect()
    -- 重新读取物品信息
end

---选中物品
function GuiBag:SelectItem(_index)
    if this.slotItem[_index] then
        this:ClearSelect()
        this.selectIndex = _index
        -- 进行名字和描述的更换,并高亮该物品
        this:ChangeNameAndDesc(this.slotItem[_index])
        -- TODO: 红点系统预留
        if this.slotItem[_index].isNew then
        end
    end
end

function GuiBag:ChangeSelectOffset(_pageIndex)
end

function GuiBag:ClearSelect()
    if this.selectIndex then
        this.selectIndex = nil
        --清除描述，清除高亮
        this.nameTxt.Text = " "
        this.descTxt.Text = " "
        this.useBtn:SetActive(false)
    end
end

function GuiBag:ClickChangePage(_pageIndex)
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
    if _pageIndex ~= 1 or _pageIndex ~= this.maxPage then
        this.prevBtn:SetActive(true)
        this.nextBtn:SetActive(true)
    end
end

function GuiBag:ChangeNameAndDesc(_itemId)
    --this.nameTxt.Text = Config.itemInfo[_itemId].Name
    --this.descTxt.Text = Config.itemInfo[_itemId].Des
    -- TODO: 高亮
end

function GuiBag:ShowItemsByPageIndex(_pageIndex)
    for i = 1, this.rowNum * this.colNum do
        -- 显示当前页面物品
        this:ShowItemByIndex(i, this.slotItem[(_pageIndex - 1) * this.colNum * this.rowNum + i].id)
    end
end

---更新最大页面数
function GuiBag:GetMaxPageNum(_itemNum)
    this.maxPage = math.ceil(_itemNum / (this.colNum * this.rowNum))
end

return GuiBag
