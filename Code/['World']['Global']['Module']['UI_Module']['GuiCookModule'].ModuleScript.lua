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
    this.fallPoint = localPlayer.Local.Independent.Cook.FallPoint
end

function GuiCook:NodeDef()
    --this.gui = localPlayer
    --* 菜谱的button slot
    --* 显示材料的slot
    --* 进度条的slot
end

function GuiCook:EventBind()
end

function GuiCook:InteractCEventHandler(_gameId)
    if _gameId == 99 then
    end
end

function GuiCook:LeaveInteractCEventHandler(_gameId)
    if _gameId == 99 then
    end
end

---Update函数
function GuiCook:Update(dt)
end

return GuiCook