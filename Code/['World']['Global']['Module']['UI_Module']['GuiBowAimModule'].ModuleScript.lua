---  弓箭瞄准UI模块：
-- @module  GuiBowAim
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
---@module GuiBowAim
local GuiBowAim, this = ModuleUtil.New("GuiBowAim", ClientBase)

function GuiBowAim:Init()
    print("GuiBowAim:Init")
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
            NetUtil.Fire_C("UseItemInHandEvent", localPlayer)
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
                ItemMgr.itemInstance[ItemMgr.curEquipmentID]:EndCharge()
                this.touchGui.AimStick.Size = Vector2(164, 164)
            end
        end
    )
end

--蓄力
function GuiBowAim:UpdateFrontSight(_chargeForce)
    this.gui.Panel.ChargeDown.Offset = Vector2(0, _chargeForce * 80)
    this.gui.Panel.ChargeRight.Offset = Vector2(_chargeForce * -80, 0)
    this.gui.Panel.ChargeLeft.Offset = Vector2(_chargeForce * 80, 0)
end

function GuiBowAim:Update(dt)
end

return GuiBowAim
