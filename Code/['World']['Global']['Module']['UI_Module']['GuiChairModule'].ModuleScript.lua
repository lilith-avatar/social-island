---@module GuiChair
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local GuiChair, this = ModuleUtil.New("GuiChair", ClientBase)

local type = ""
local chairId = 0

---初始化函数
function GuiChair:Init()
    print("[GuiChair] Init()")
    this:NodeDef()
    this:DataInit()
    this:EventBind()
end

function GuiChair:DataInit()
end

function GuiChair:EventBind()
end

function GuiChair:NodeDef()
end

function GuiChair:ClickSitBtn(_type, _chairId)
end


function GuiChair:InteractCEventHandler(_id)
    if _id == 10 then
    end
end

function GuiChair:ShowSitBtnEventHandler(_type, _chairId)
end

function GuiChair:NormalBack()
end

function GuiChair:GetQteForward(_dir, _speed)
end

function GuiChair:QteButtonClick(_dir)
end

function GuiChair:ShowQteButton(_keepTime)
end

function GuiChair:ChangeTotalTime(_total)
end

function GuiChair:Update(_dt)
end

return GuiChair
