--- 玩家控制UI模块
--- @module Player GuiControll, client-side
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local GuiControl, this = ModuleUtil.New('GuiControl', ClientBase)

-- 手机端交互UI
local gui, touchScreen, dynamicFigure, menuFigure, ctrlFigure

-- 交互ID
local interactID = 0

-- 拾取物体
local pickItemObj = 0

function GuiControl:Init()
    print('[GuiControl] Init()')
    self:InitGui()
    self:InitListener()
end

function GuiControl:InitGui()
    gui = localPlayer.Local.ControlGui
    this.joystick = gui.Joystick
    touchScreen = gui.TouchFig

    dynamicFigure = gui.Dynamic
    menuFigure = gui.Menu
    ctrlFigure = gui.Ctrl

    GuiControl:ResetDefUIEventHandler()
end

function GuiControl:InitListener()
    -- GUI
    touchScreen.OnTouched:Connect(
        function(touchInfo)
            PlayerCam:CameraMove(touchInfo)
        end
    )

    --[[touchScreen.OnPinchStay:Connect(
        function(pos1, pos2, deltaSize, pinchSpeed)
            PlayerCam:CameraZoom(pos1, pos2, deltaSize, pinchSpeed)
        end
    )]]
    dynamicFigure.InteractBtn.OnDown:Connect(OnInteractBtnClick)
    dynamicFigure.PickBtn.OnDown:Connect(OnPickBtnClick)
    ctrlFigure.JumpBtn.OnDown:Connect(
        function()
            PlayerCtrl:PlayerJump()
        end
    )
    ctrlFigure.UseBtn.OnDown:Connect(
        function()
            if Data.Player.curEquipmentID ~= 0 then
                NetUtil.Fire_C('UseItemInHandEvent', localPlayer)
                return
            end
            PlayerCtrl:PlayerHello()
        end
    )
    ctrlFigure.TakeOffBtn.OnDown:Connect(
        function()
            NetUtil.Fire_C('UnequipCurEquipmentEvent', localPlayer)
        end
    )
    ctrlFigure.LeaveBtn.OnDown:Connect(
        function()
            print('LeaveBtnClick')
            NetUtil.Fire_S('LeaveInteractSEvent', localPlayer, interactID)
            NetUtil.Fire_C('LeaveInteractCEvent', localPlayer, interactID)
            CloudLogUtil.UploadLog('pannel_actions', 'dialog_icon_' .. interactID .. '_close')
        end
    )
    menuFigure.BagBtn.OnClick:Connect(
        function()
            GuiBag:ShowBagUI()
        end
    )
    menuFigure.ResetBtn.OnClick:Connect(
        function()
            PlayerCtrl:PlayerReset()
        end
    )
end

--- 点击交互按钮
function OnInteractBtnClick()
    dynamicFigure.InteractBtn:SetActive(false)
    NetUtil.Fire_S('InteractSEvent', localPlayer, interactID)
    NetUtil.Fire_C('InteractCEvent', localPlayer, interactID)
    CloudLogUtil.UploadLog('pannel_actions', 'dialog_icon_' .. interactID .. '_click')
end

--- 点击拾取按钮
function OnPickBtnClick()
    dynamicFigure.PickBtn:SetActive(false)
    NetUtil.Fire_C('GetItemEvent', localPlayer, pickItemObj.ID.Value)
    pickItemObj:Destroy()
end

--更新UseBtn的遮罩
function GuiControl:UpdateUseBtnMask(_amount)
    ctrlFigure.UseBtn.Mask.FillAmount = _amount
    if _amount <= 0 and ctrlFigure.UseBtn.Mask.ActiveSelf == true then
        ctrlFigure.UseBtn.Mask:SetActive(false)
    elseif _amount > 0 and ctrlFigure.UseBtn.Mask.ActiveSelf == false then
        ctrlFigure.UseBtn.Mask:SetActive(true)
    end
end

--更新UseBtn的图标
function GuiControl:UpdateUseBtnIcon(_icon)
    _icon = _icon or 'Icon_Applaud'
    ctrlFigure.UseBtn.Img.Texture = ResourceManager.GetTexture('UI/IconNew/' .. _icon)
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
    if interactID == 0 then
        print('重置通用UI事件')
        gui.Joystick:SetActive(true)
        dynamicFigure:SetActive(false)
        menuFigure:SetActive(true)
        ctrlFigure:SetActive(true)
        local tmp = gui:GetChildren()
        for _, v in pairs(dynamicFigure:GetChildren()) do
            v:SetActive(false)
        end
        for _, v in pairs(menuFigure:GetChildren()) do
            v:SetActive(true)
        end
        for _, v in pairs(ctrlFigure:GetChildren()) do
            v:SetActive(true)
        end
        gui.Ctrl.LeaveBtn:SetActive(false)
        this:UpdateTakeOffBtn()
    end
end

--- 打开动态交互事件
function GuiControl:OpenDynamicEventHandler(_type, _var, _scenesInteractID)
    dynamicFigure:SetActive(true)
    if _type == 'Interact' then
        dynamicFigure.InteractBtn:SetActive(true)
        interactID = _var
        if _var ~= 13 then
            dynamicFigure.InteractBtn.Img.Texture =
                ResourceManager.GetTexture('UI/IconNew/' .. Config.Interact[_var].InteractBtnIcon)
        else
            dynamicFigure.InteractBtn.Img.Texture =
                ResourceManager.GetTexture('UI/IconNew/' .. Config.ScenesInteract[_scenesInteractID].InteractBtnIcon)
        end
    elseif _type == 'Pick' then
        dynamicFigure.PickBtn:SetActive(true)
        pickItemObj = _var
    end
end

--- 关闭动态交互事件
function GuiControl:CloseDynamicEventHandler()
    dynamicFigure:SetActive(false)
    dynamicFigure.InteractBtn:SetActive(false)
    dynamicFigure.PickBtn:SetActive(false)
end

--- 更新金币显示
function GuiControl:UpdateCoinNum(_num)
    NetUtil.Fire_C('ShowGetCoinNumEvent', localPlayer, _num)
    gui.Menu.CoinInfoBG.CoinNum.Text = Data.Player.coin
end

--- 金币UI震动
function GuiControl:CoinUIShake(_num)
    local strength = 0
    if _num < 10 then
        strength = 1
    elseif _num < 100 then
        strength = 5
    elseif _num < 500 then
        strength = 10
    else
        strength = 20
    end
    local uiTweener = Tween:ShakeProperty(gui.Menu.CoinInfoBG, {'Offset'}, 0.2, strength)
    uiTweener:Play()
end

--- 进入小游戏修改UI
function GuiControl:ChangeMiniGameUIEventHandler(_id)
    _id = _id or 0
    print('进入小游戏修改UI', _id)
    local config = Config.Interact[_id]
    gui.Joystick:SetActive(config.JoystickActive)
    gui.Menu:SetActive(config.MenuActive)
    gui.Ctrl:SetActive(config.CtrlActive)
    this:UpdateTakeOffBtn()
    if config.MenuActive then
        gui.Menu.BagBtn:SetActive(config.BagBtnActive)
        gui.Menu.ResetBtn:SetActive(config.ResetBtnActive)
        gui.Menu.CoinInfoBG:SetActive(config.CoinInfoBGActive)
    end
    if config.CtrlActive then
        gui.Ctrl.UseBtn:SetActive(config.UseBtnActive)
        gui.Ctrl.JumpBtn:SetActive(config.JumpBtnActive)
        gui.Ctrl.LeaveBtn:SetActive(config.LeaveBtnActive)
        gui.Ctrl.SocialAnimBtn:SetActive(config.SocialAnimActive)
        gui.Ctrl.TakeOffBtn:SetActive(config.TakeOffBtnActive)
    end

    for k, v in pairs(localPlayer.Local:GetChildren()) do
        if v.ClassName == 'UiScreenUiObject' and v.Name ~= 'ControlGui' and v.ActiveSelf then
            v:SetActive(false)
        end
    end
    if localPlayer.Local[config.OpenGui] then
        localPlayer.Local[config.OpenGui]:SetActive(true)
    end
    if _id == 0 then
        interactID = 0
        this:ResetDefUIEventHandler()
    end
end

--- 更新脱下Btn显示
function GuiControl:UpdateTakeOffBtn()
    if Data.Player.curEquipmentID == 0 or Data.Player.curEquipmentID == nil then
        gui.Ctrl.TakeOffBtn:SetActive(false)
    else
        gui.Ctrl.TakeOffBtn:SetActive(true)
    end
end

function GuiControl:Update(dt)
end

return GuiControl
