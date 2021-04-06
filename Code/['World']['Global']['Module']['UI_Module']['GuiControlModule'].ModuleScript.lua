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
            if ItemMgr.curEquipmentID ~= 0 then
                print('UseBtn', ItemMgr.curEquipmentID)
                NetUtil.Fire_C('UseItemInHandEvent', localPlayer)
                return
            end
            if
                FsmMgr.playerActFsm.curState.stateName == 'SwimIdle' or
                    FsmMgr.playerActFsm.curState.stateName == 'Swimming'
             then
                return
            end
            PlayerCtrl:PlayerClap()
        end
    )
    ctrlFigure.UseBtn.OnEnter:Connect(
        function()
            if
                FsmMgr.playerActFsm.curState.stateName == 'SwimIdle' or
                    FsmMgr.playerActFsm.curState.stateName == 'Swimming'
             then
                localPlayer.LinearVelocity = Vector3(localPlayer.LinearVelocity.x, -3, localPlayer.LinearVelocity.z)
                return
            end
        end
    )
    ctrlFigure.UseBtn.OnLeave:Connect(
        function()
            if
                FsmMgr.playerActFsm.curState.stateName == 'SwimIdle' or
                    FsmMgr.playerActFsm.curState.stateName == 'Swimming'
             then
                localPlayer.LinearVelocity = Vector3(localPlayer.LinearVelocity.x, 0, localPlayer.LinearVelocity.z)
                return
            end
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
function GuiControl:OpenDynamicEventHandler(_type, _var)
    dynamicFigure:SetActive(true)
    if _type == 'Interact' then
        dynamicFigure.InteractBtn:SetActive(true)
        interactID = _var
    elseif _type == 'Pick' then
        dynamicFigure.PickBtn:SetActive(true)
        pickItemObj = _var
    end
end

--- 更新金币显示
function GuiControl:UpdateCoinNum(_num)
    NetUtil.Fire_C('ShowGetCoinNumEvent', localPlayer, _num)
    gui.Menu.CoinNum.Text = '金币：' .. Data.Player.coin
end

--- 改变使用按钮图标
function GuiControl:ChangeUseBtnIcon(_icon)
    _icon = _icon or 'Icon_Control'
    gui.Ctrl.UseBtn.Image = ResourceManager.GetTexture('UI/' .. _icon)
    gui.Ctrl.UseBtn.PressedImage = ResourceManager.GetTexture('UI/' .. _icon .. '_A')
end

--- 进入小游戏修改UI
function GuiControl:ChangeMiniGameUIEventHandler(_id)
    _id = _id or 0
    print('进入小游戏修改UI', _id)
    local config = Config.Interact[_id]
    gui.Joystick:SetActive(config.JoystickActive)
    gui.Menu:SetActive(config.MenuActive)
    gui.Ctrl:SetActive(config.CtrlActive)
    if config.CtrlActive then
        gui.Ctrl.UseBtn:SetActive(config.UseBtnActive)
        gui.Ctrl.JumpBtn:SetActive(config.JumpBtnActive)
        gui.Ctrl.LeaveBtn:SetActive(config.LeaveBtnActive)
        gui.Ctrl.SocialAnimBtn:SetActive(config.SocialAnimActive)
    end
    if config.UseBtnIcon ~= '' then
        this:ChangeUseBtnIcon(config.UseBtnIcon)
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
    this:UpdateTakeOffBtn()
end

--- 更新脱下Btn显示
function GuiControl:UpdateTakeOffBtn()
    if ItemMgr.curEquipmentID == 0 or ItemMgr.curEquipmentID == nil then
        gui.Ctrl.TakeOffBtn:SetActive(false)
    else
        gui.Ctrl.TakeOffBtn:SetActive(true)
    end
end

function GuiControl:Update(dt)
end

return GuiControl
