--- 玩家默认UI
--- @module Player Default GUI
--- @copyright Lilith Games, Avatar Team
local GuiDefault, this = ModuleUtil.New('GuiDefault', ClientBase)

-- 获取本地玩家
local player

-- 姓名板
local nameGUI

function GuiDefault:Init()
    print('[GuiDefault] Init()')
    -- 获取本地玩家
    player = localPlayer
    self:InitNameGui()
    self:InitListener()
end

-- 姓名板
function GuiDefault:InitNameGui()
    nameGUI = player.NameGui
    nameGUI.NameBarTxt1.Text = player.Name
    nameGUI.NameBarTxt2.Text = player.Name
end

-- 初始化事件
function GuiDefault:InitListener()
    world.OnRenderStepped:Connect(MainGUI)
end

-- 姓名板的显示逻辑
function NameBarLogic()
    nameGUI.Visible = player.DisplayName
    if player.DisplayName then
        nameGUI.LocalPosition = Vector3(0, 1 + player.Avatar.Height, 0)
    end
end

-- 每个渲染帧更新姓名板和血条的显示逻辑
function MainGUI(_delta)
    NameBarLogic()
end

return GuiDefault
