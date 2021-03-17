---  弓箭瞄准UI模块：
-- @module  GuiBowAim
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
---@module GuiBowAim
local GuiBowAim, this = ModuleUtil.New("GuiBowAim", ClientBase)

local isCharge = false

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
    this.aimStick = this.touchGui.AimStick
    this.chargeForce = 0
end

--数据变量声明
function GuiBowAim:DataInit()
end

--节点事件绑定
function GuiBowAim:EventBind()
    this.aimStick.OnEnter:Connect(
        function()
            ItemMgr.itemInstance[ItemMgr.curWeaponID]:Attack()
            isCharge = true
        end
    )
    this.aimStick.OnLongPressStay:Connect(
        function()
            --this:AimAngle(deltaDistance)
        end
    )
    this.aimStick.OnLeave:Connect(
        function()
            isCharge = false
            NetUtil.Fire_C("FsmTriggerEvent", localPlayer, "BowAttack")
        end
    )
end

--获取镜头移动方向
function GuiBowAim:CamMoveDir()
    local x, y = 0, 0
    if this.aimStick.Horizontal > 0.3 or this.aimStick.Horizontal < -0.3 then
        x = this.aimStick.Horizontal * 0.5
    else
        x = 0
    end
    if this.aimStick.Vertical > 0.3 or this.aimStick.Vertical < -0.3 then
        y = this.aimStick.Vertical
    else
        y = 0
    end
    return Vector2(x, y)
end

--蓄力
function GuiBowAim:Charge(dt)
    if isCharge then
        if this.chargeForce < 1 then
            this.chargeForce = this.chargeForce + dt * 2
        else
            this.chargeForce = 1
        end
    else
        if this.chargeForce > 0 then
            this.chargeForce = this.chargeForce - dt * 5
        else
            this.chargeForce = 0
        end
    end
    this.gui.Panel.ChargeDown.Offset = Vector2(0, this.chargeForce * 80)
    this.gui.Panel.ChargeRight.Offset = Vector2(this.chargeForce * -80, 0)
    this.gui.Panel.ChargeLeft.Offset = Vector2(this.chargeForce * 80, 0)
    
end

--玩家上半身角度移动
function GuiBowAim:AimAngle(deltaDistance)
    PlayerCam.curCamera.LookAt:Rotate(0, deltaDistance.x * 0.6, 0)
    PlayerCam.curCamera:CameraMove(Vector2(0, deltaDistance.y))
    --PlayerCam.curCamera.LookAt:Rotate(0, this:CamMoveDir().x, 0)
    --PlayerCam.curCamera:CameraMove(Vector2(0, this:CamMoveDir().y))
end

function GuiBowAim:Update(dt)
    this:Charge(dt)
end

return GuiBowAim
