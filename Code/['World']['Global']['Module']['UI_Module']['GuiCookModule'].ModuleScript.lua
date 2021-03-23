---@module GuiCook
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local GuiCook,this = ModuleUtil.New('GuiCook',ClientBase)

---初始化函数
function GuiCook:Init()
    this:NodeDef()
    this:DataInit()
    this:EventBind()
end

function GuiCook:DataInit()
    this.startUpdate = true
    this.timer = 0
    this.pageIndex = 1
    this.maxPage = 1
    this.UsingMaterial = {} --食材栏中的食材
    this.BagMaterial = {} --背包中的食材

    --* 背包物品显示参数-------------
    this.pageSize = 9
end

function GuiCook:NodeDef()
    this.root = localPlayer.Local.CookGui
    this.gui = this.root.BagPanel
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
    for k,v in ipairs(this.MaterialSlot) do
        v.ItemImg.SelectBtn.OnClick:Connect(function()
            this:CancelMaterial(k)
        end)
    end
    this.cookBtn.OnClick:Connect(function()
        this:StartCook()
    end)
end

function GuiCook:TransItemTable()
    --先清空表
    this.slotItem = {}
    for k, v in pairs(Data.Player.bag) do
        if v.count > 0 and Config.RewardItem[k] then
            local data = {
                num = v.count,
                id = k,
                cd = 0
            }
            table.insert(this.BagMaterial, data)
        end
    end
end

function GuiCook:ShowUI()
    this:ClearAllMaterial()
    this.root:SetActive(true)
    this.gui:SetActive(true)
end

function GuiCook:InteractCEventHandler(_gameId)
    if _gameId == 99 then
        this:ShowUI()
    end
end

function GuiCook:LeaveInteractCEventHandler(_gameId)
    if _gameId == 99 then
    end
end

function GuiCook:HideGui()
end

function GuiCook:StartCook()
    if #this.UsingMaterial == 0 or not this.UsingMaterial then
        return
    end
end

function GuiCook:CancelMaterial(_index)
    if not this.UsingMaterial[_index] then
        return
    end
    --this.MaterialSlot
    table.remove(this.UsingMaterial, _index)
    if #this.UsingMaterial == 0 or not this.UsingMaterial then
        this.cookBtn.Locked:SetActive(true)
    end
    this:ShowMaterialIcon()
end

function GuiCook:ChooseMaterial(_index)
    this.cookBtn.Locked:SetActive(false)
end

function GuiCook:ClearAllMaterial()
    this.UsingMaterial = {}
    this:ShowMaterialIcon()
end

function GuiCook:ShowMaterialIcon()
    for k,v in ipairs(this.MaterialSlot) do
        v.ItemImg.IMGNormal:SetActive(false)
    end
end

return GuiCook