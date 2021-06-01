---  弓箭瞄准UI模块：
-- @module  GuiBowAim
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
---@module GuiBowAim
local GuiBowAim, this = ModuleUtil.New('GuiBowAim', ClientBase)

local isAble = true
local isUse = false

function GuiBowAim:Init()
    --print('GuiBowAim:Init')
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--节点引用
function GuiBowAim:NodeRef()
    this.gui = localPlayer.Local.SpecialBottomUI.BowAimGUI
    this.touchGui = localPlayer.Local.SpecialTopUI.BowAimGUI
end

--数据变量声明
function GuiBowAim:DataInit()
end

--节点事件绑定
function GuiBowAim:EventBind()
    this.touchGui.AimStick.OnEnter:Connect(
        function()
            if isAble then
                NetUtil.Fire_C('UseItemInHandEvent', localPlayer)
                this.touchGui.AimStick.Size = Vector2(1800, 1500)
                isUse = true
            end
        end
    )
    Input.OnKeyDown:Connect(
        function()
            if Input.GetPressKeyData(Enum.KeyCode.F) == Enum.KeyState.KeyStatePress then
                if isAble then
                    NetUtil.Fire_C('UseItemInHandEvent', localPlayer)
                    this.touchGui.AimStick.Size = Vector2(1800, 1500)
                    isUse = true
                end
            end
        end
    )
    this.touchGui.AimStick.OnTouched:Connect(
        function(touchInfo)
            if isAble then
                if isUse then
                    --print('isUse is true')
                    PlayerCam:CameraMove(touchInfo)
                else
                    --print('isUse is false')
                    NetUtil.Fire_C('UseItemInHandEvent', localPlayer)
                    this.touchGui.AimStick.Size = Vector2(1800, 1500)
                    isUse = true
                end
            --[[if FsmMgr.playerActFsm.curState.stateName ~= 'BowChargeIdle' then
                  
                end]]
            end
        end
    )
    Input.OnKeyHold:Connect(
        function()
            if Input.GetPressKeyData(Enum.KeyCode.F) == Enum.KeyState.KeyStateHold then
                if isAble then
                    if FsmMgr.playerActFsm.curState.stateName ~= 'BowChargeIdle' then
                        --PlayerCam:CameraMove(touchInfo)
                    else
                        NetUtil.Fire_C('UseItemInHandEvent', localPlayer)
                        this.touchGui.AimStick.Size = Vector2(1800, 1500)
                        isUse = true
                    end
                --PlayerCam:CameraMove(touchInfo)
                end
            end
        end
    )
    this.touchGui.AimStick.OnLeave:Connect(
        function()
            if Data.Player.curEquipmentID ~= 0 then
                if isAble then
                    ItemMgr.itemInstance[Data.Player.curEquipmentID]:EndCharge()
                    this.touchGui.AimStick.Size = Vector2(144, 144)
                    isUse = false
                end
            end
        end
    )
    Input.OnKeyUp:Connect(
        function()
            if Input.GetPressKeyData(Enum.KeyCode.F) == Enum.KeyState.KeyStateRelease then
                if Data.Player.curEquipmentID ~= 0 then
                    if isAble then
                        ItemMgr.itemInstance[Data.Player.curEquipmentID]:EndCharge()
                        this.touchGui.AimStick.Size = Vector2(144, 144)
                        isUse = false
                    end
                end
            end
        end
    )
end

--蓄力
function GuiBowAim:UpdateFrontSight(_chargeForce)
    this.gui.Panel.ChargeDown.Offset = Vector2(0, _chargeForce * 60)
    this.gui.Panel.ChargeRight.Offset = Vector2(_chargeForce * -60 * 0.866, _chargeForce * 60 * -0.5)
    this.gui.Panel.ChargeLeft.Offset = Vector2(_chargeForce * 60 * 0.866, _chargeForce * 60 * -0.5)
end

--CD
function GuiBowAim:UpdateTouchGuiCD(_amount)
    if _amount <= 0 and isAble == false then
        --this.touchGui.AimStick:SetActive(true)
        isAble = true
    elseif _amount > 0 and isAble == true then
        isAble = false
    --this.touchGui.AimStick:SetActive(false)
    end
end

function GuiBowAim:Update(dt)
end

return GuiBowAim
