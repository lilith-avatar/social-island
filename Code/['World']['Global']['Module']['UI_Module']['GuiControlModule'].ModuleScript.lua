--- 玩家控制UI模块
--- @module Player GuiControll, client-side
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local GuiControl, this = ModuleUtil.New("GuiControl", ClientBase)

-- 手机端交互UI
local gui, touchScreen, dynamicFigure, infoFigure, menuFigure, ctrlFigure

-- 交互ID
local interactID = 0

-- 拾取物体
local pickItemObj = 0

function GuiControl:Init()
    print("[GuiControl] Init()")
    self:InitGui()
    self:InitNodes()
    self:InitListener()
end

function GuiControl:InitGui()
    gui = localPlayer.Local.ControlGui
    this.joystick = gui.Joystick
    touchScreen = gui.TouchFig

    dynamicFigure = gui.Dynamic
    infoFigure = gui.Info
    menuFigure = gui.Menu
    ctrlFigure = gui.Ctrl

    GuiControl:ResetDefUIEventHandler()
end

function GuiControl:InitNodes()
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
    dynamicFigure.InteractBtn.OnDown:Connect(OnInteractBtnClick)
    dynamicFigure.PickBtn.OnDown:Connect(OnPickBtnClick)
    ctrlFigure.JumpBtn.OnDown:Connect(
        function()
            PlayerCtrl:PlayerJump()
        end
    )
    ctrlFigure.UseBtn.OnDown:Connect(
        function()
            PlayerCtrl:PlayerClap()
        end
    )
    menuFigure.BagBtn.OnClick:Connect(
        function()
            GuiBag:ShowBagUI()
        end
    )
end

--- 点击交互按钮
function OnInteractBtnClick()
    dynamicFigure.InteractBtn:SetActive(false)
    NetUtil.Fire_S("InteractSEvent", localPlayer, interactID)
    NetUtil.Fire_C("InteractCEvent", localPlayer, interactID)
end

--- 点击拾取按钮
function OnPickBtnClick()
    dynamicFigure.PickBtn:SetActive(false)
    ItemMgr:GetItem(pickItemObj.ID.Value)
    pickItemObj:Destroy()
end

--- 设置通用UI事件
function GuiControl:SetDefUIEventHandler(_bool, _nodes, _root)
    _root = _root or gui
    local tmp = _root:GetChildren()
    for _, v in pairs(tmp) do
        for _, node in pairs(_nodes) do
            if v.Name == node then
                v:SetActive(_bool)
                break
            end
        end
    end
end

--- 重置通用UI事件
function GuiControl:ResetDefUIEventHandler()
    dynamicFigure:SetActive(false)
    infoFigure:SetActive(false)
    menuFigure:SetActive(true)
    ctrlFigure:SetActive(true)
    local tmp = gui:GetChildren()
    for _, v in pairs(dynamicFigure:GetChildren()) do
        v:SetActive(false)
    end
    for _, v in pairs(infoFigure:GetChildren()) do
        v:SetActive(true)
    end
    for _, v in pairs(menuFigure:GetChildren()) do
        v:SetActive(true)
    end
    for _, v in pairs(ctrlFigure:GetChildren()) do
        v:SetActive(true)
    end
end

--- 打开动态交互事件
function GuiControl:OpenDynamicEventHandler(_type, _var)
    dynamicFigure:SetActive(true)
    if _type == "Interact" then
        dynamicFigure.InteractBtn:SetActive(true)
        interactID = _var
    elseif _type == "Pick" then
        dynamicFigure.PickBtn:SetActive(true)
        pickItemObj = _var
    end
end

--- 显示info
function GuiControl:ShowInfo(_text, _t)
    infoFigure:SetActive(true)
    infoFigure.InfoText.Text = _text
    invoke(
        function()
            infoFigure:SetActive(false)
        end,
        _t
    )
end

return GuiControl
