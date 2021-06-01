---@module GuiLoading
---@copyright Lilith Games, Avatar Team
---@author Dead Ratman
local GuiLoading, this = ModuleUtil.New('GuiLoading', ClientBase)

local gui, bar, icon

local loadingDur = 10
local timer = 0

---初始化函数
function GuiLoading:Init()
    --print('[GuiLoading] Init()')
    this:NodeDef()
    this:DataInit()
    this:EventBind()
end

---节点定义
function GuiLoading:NodeDef()
    gui = localPlayer.Local.SpecialTopUI.Loading
    bar = gui.Bg.Bg_Bar.Bar
    icon = gui.Ico
end

---数据初始化
function GuiLoading:DataInit()
    gui:SetActive(true)
end

---事件绑定
function GuiLoading:EventBind()
end

---更新进度条
function GuiLoading:UpdateBar(_t)
    bar.FillAmount = _t / loadingDur
end

---更新图标
function GuiLoading:UpdateIcon(_t)
    local x = (_t / loadingDur * 1000) % 102
    if x <= 51 then
        x = x
    else
        x = 102 - x
    end
    icon.Size = Vector2(x, 51)
end

---Update函数
function GuiLoading:Update(_dt)
    if gui.ActiveSelf then
        if timer < loadingDur then
            timer = timer + _dt
            this:UpdateBar(timer)
            this:UpdateIcon(timer)
        else
            CloudLogUtil.UploadLog('game_fte', 'loading_complete')
            gui:SetActive(false)
        end
    end
end

return GuiLoading
