--- 玩家控制模块
--- @module Player Controll, client-side
--- @copyright Lilith Games, Avatar Team
local GuiControl, this = ModuleUtil.New("GuiControl", ClientBase)
local player
--声明变量
local isDead = false
local forwardDir = Vector3.Forward
local rightDir = Vector3.Right
local horizontal = 0
local vertical = 0

-- 节点声明
local LocalAudio

-- 手机端交互UI
local gui, touchScreen, jumpBtn, useBtn

-- PC端交互按键
local FORWARD_KEY = Enum.KeyCode.W
local BACK_KEY = Enum.KeyCode.S
local LEFT_KEY = Enum.KeyCode.A
local RIGHT_KEY = Enum.KeyCode.D
local JUMP_KEY = Enum.KeyCode.Space

-- 键盘的输入值
local moveForwardAxis = 0
local moveBackAxis = 0
local moveLeftAxis = 0
local moveRightAxis = 0

function GuiControl:Init()
    self:InitGui()
    self:InitNodes()
    self:InitListener()
end

function GuiControl:InitGui()
    gui = localPlayer.Local.ControlGui
    this.joystick = gui.Joystick
    touchScreen = gui.TouchFig
    jumpBtn = gui.JumpBtn
    useBtn = gui.UseBtn
end

function GuiControl:InitNodes()
    LocalAudio = localPlayer.Local.LocalAudio
end

function GuiControl:InitListener()
    -- GUI
    touchScreen.OnTouched:Connect(
        function(touchInfo)
            PlayerCam:CountTouch(touchInfo)
        end
    )
    touchScreen.OnPanStay:Connect(
        function(pos, panDistance, deltaDistance, panSpeed)
            PlayerCam:CameraMove(pos, panDistance, deltaDistance, panSpeed)
        end
    )
    touchScreen.OnPinchStay:Connect(
        function(pos1, pos2, deltaSize, pinchSpeed)
            PlayerCam:CameraZoom(pos1, pos2, deltaSize, pinchSpeed)
        end
    )

    jumpBtn.OnDown:Connect(
        function()
            PlayerCtrl:PlayerJump()
        end
    )
    useBtn.OnDown:Connect(
        function()
            PlayerCtrl:PlayerClap()
        end
    )
end

return GuiControl
