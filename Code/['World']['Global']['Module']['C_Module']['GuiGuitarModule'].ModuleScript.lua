---@module GuiGuitar
---@copyright Lilith Games, Avatar Team
---@author XXX, XXXX
local GuiGuitar,this = ModuleUtil.New('GuiGuitar',ClientBase)

---初始化函数
function GuiGuitar:Init()
    this:DataInit()
    this:NodeDef()
    this:EventBind()
end

function GuiGuitar:DataInit()
    this.stringAudio = {}
end

function GuiGuitar:NodeDef()
end

function GuiGuitar:EventBind()
end

return GuiGuitar