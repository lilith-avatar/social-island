---  手枪瞄准UI模块：
-- @module  GuiPistolAim
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
---@module GuiPistolAim
local GuiPistolAim, this = ModuleUtil.New('GuiPistolAim', ClientBase)

function GuiPistolAim:Init()
    print('GuiPistolAim:Init')
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--节点引用
function GuiPistolAim:NodeRef()
    this.gui = localPlayer.Local.SpecialBottomUI.PistolAimGUI
    this.touchGui = localPlayer.Local.SpecialTopUI.PistolAimGUI
end

--数据变量声明
function GuiPistolAim:DataInit()
end

--节点事件绑定
function GuiPistolAim:EventBind()
    this.touchGui.AimStick.OnEnter:Connect(
        function()
            NetUtil.Fire_C('UseItemInHandEvent', localPlayer)
            this.touchGui.AimStick.Size = Vector2(1800, 1500)
        end
    )
    this.touchGui.AimStick.OnTouched:Connect(
        function(touchInfo)
            PlayerCam:CameraMove(touchInfo)
        end
    )
    this.touchGui.AimStick.OnLeave:Connect(
        function()
            if ItemMgr.curWeaponID ~= 0 then
                ItemMgr.itemInstance[Data.Player.curEquipmentID]:EndFire()
                this.touchGui.AimStick.Size = Vector2(164, 164)
            end
        end
    )
end

--蓄力
function GuiPistolAim:UpdateFrontSight(_chargeForce)
    this.gui.Panel.ChargeDown.Offset = Vector2(0, _chargeForce * 80)
    this.gui.Panel.ChargeRight.Offset = Vector2(_chargeForce * -80, 0)
    this.gui.Panel.ChargeLeft.Offset = Vector2(_chargeForce * 80, 0)
end

function GuiPistolAim:Update(dt)
end

return GuiPistolAim
