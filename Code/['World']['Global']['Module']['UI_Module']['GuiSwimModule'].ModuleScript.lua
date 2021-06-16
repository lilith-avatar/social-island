---@module GuiSwim
---@copyright Lilith Games, Avatar Team
---@author Dead Ratman
local GuiSwim, this = ModuleUtil.New('GuiSwim', ClientBase)

local jumpBtn

---初始化函数
function GuiSwim:Init()
    --print('[GuiSwim] Init()')
    this:NodeDef()
    this:DataInit()
    this:EventBind()
end

---节点定义
function GuiSwim:NodeDef()
    jumpBtn = localPlayer.Local.ControlGui.Ctrl.JumpBtn
end

---数据初始化
function GuiSwim:DataInit()
end

---事件绑定
function GuiSwim:EventBind()
    jumpBtn.OnClick:Connect(function()
        NetUtil.Fire_C('FsmTriggerEvent', localPlayer, 'JumpBeginState')
    end)
end

---Update函数 test
function GuiSwim:Update(_dt)
    if localPlayer:IsSwimming() then
        if localPlayer.Position.y > -15.7 and not jumpBtn.ActiveSelf then
            jumpBtn:SetActive(true)
        elseif localPlayer.Position.y < -15.7 and jumpBtn.ActiveSelf then
            jumpBtn:SetActive(false)
        end
    end

end

return GuiSwim
