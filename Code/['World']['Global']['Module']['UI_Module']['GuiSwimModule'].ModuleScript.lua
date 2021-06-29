---@module GuiSwim
---@copyright Lilith Games, Avatar Team
---@author Dead Ratman
local GuiSwim, this = ModuleUtil.New('GuiSwim', ClientBase)

local ctrlFig

---初始化函数
function GuiSwim:Init()
    --print('[GuiSwim] Init()')
    this:NodeDef()
    this:DataInit()
    this:EventBind()
end

---节点定义
function GuiSwim:NodeDef()
    ctrlFig = localPlayer.Local.ControlGui.Ctrl
end

---数据初始化
function GuiSwim:DataInit()
end

---事件绑定
function GuiSwim:EventBind()
end

---Update函数 test
function GuiSwim:Update(_dt)
    if localPlayer:IsSwimming() and ctrlFig.ActiveSelf then
        ctrlFig:SetActive(false)
    elseif not localPlayer:IsSwimming() and not ctrlFig.ActiveSelf and not GameFlow.inGame then
        ctrlFig:SetActive(true)
    end
end

return GuiSwim
