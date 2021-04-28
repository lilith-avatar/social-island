---@module GuiMap
---@copyright Lilith Games, Avatar Team
---@author Dead Ratman
local GuiMap, this = ModuleUtil.New('GuiMap', ClientBase)

local gui, closeBtn

---初始化函数
function GuiMap:Init()
    print('[GuiMap] Init()')
    this:NodeDef()
    this:DataInit()
    this:EventBind()
end

---节点定义
function GuiMap:NodeDef()
    gui = localPlayer.Local.MapGUI
    closeBtn = gui.CloseBtn
end

---数据初始化
function GuiMap:DataInit()
end

---事件绑定
function GuiMap:EventBind()
    closeBtn.OnClick:Connect(
        function()
            NetUtil.Fire_S('LeaveInteractSEvent', localPlayer, 29)
        end
    )
end
---Update函数
function GuiMap:Update(_dt)
end

return GuiMap
