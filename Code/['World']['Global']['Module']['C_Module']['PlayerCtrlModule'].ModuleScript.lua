--- 角色控制模块
--- @module Player Ctrl Module
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local PlayerCtrl, this = ModuleUtil.New("PlayerCtrl", ClientBase)

--声明变量
local isDead = false
local forwardDir = Vector3.Forward
local rightDir = Vector3.Right
local horizontal = 0
local vertical = 0

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

--- 初始化
function PlayerCtrl:Init()
    print("[PlayerCtrl] Init()")
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--- 节点引用
function PlayerCtrl:NodeRef()
end

--- 数据变量初始化
function PlayerCtrl:DataInit()
    this.finalDir = Vector3.Zero
    this.isControllable = true
end

--- 节点事件绑定
function PlayerCtrl:EventBind()
    -- Keyboard Input
    Input.OnKeyDown:Connect(
        function()
            if Input.GetPressKeyData(JUMP_KEY) == 1 then
                this:PlayerJump()
            end
            if Input.GetPressKeyData(Enum.KeyCode.F) == 1 then
                FsmMgr:FsmTriggerEventHandler("BowAttack")
            end
            if Input.GetPressKeyData(Enum.KeyCode.P) == 1 then
                ItemMgr.itemInstance[1001]:Use()
            --FsmMgr:FsmTriggerEventHandler("TwoHandedSwordIdle")
            end
            if Input.GetPressKeyData(Enum.KeyCode.O) == 1 then
                ItemMgr.itemInstance[2001]:Use()
            --FsmMgr:FsmTriggerEventHandler("TwoHandedSwordIdle")
            end
            if Input.GetPressKeyData(Enum.KeyCode.Mouse2) == 1 and ItemMgr.curWeaponID ~= 0 then
                ItemMgr.itemInstance[ItemMgr.curWeaponID]:Attack()
            --[[FsmMgr:FsmTriggerEventHandler("TwoHandedSwordAttack1")
                FsmMgr:FsmTriggerEventHandler("TwoHandedSwordAttack2")
                FsmMgr:FsmTriggerEventHandler("TwoHandedSwordAttack3")]]
            end
        end
    )
end

--获取按键盘时的移动方向最终取值
function GetKeyValue()
    moveForwardAxis = Input.GetPressKeyData(FORWARD_KEY) > 0 and 1 or 0
    moveBackAxis = Input.GetPressKeyData(BACK_KEY) > 0 and -1 or 0
    moveLeftAxis = Input.GetPressKeyData(LEFT_KEY) > 0 and 1 or 0
    moveRightAxis = Input.GetPressKeyData(RIGHT_KEY) > 0 and -1 or 0
    if localPlayer.State == Enum.CharacterState.Died then
        moveForwardAxis, moveBackAxis, moveLeftAxis, moveRightAxis = 0, 0, 0, 0
    end
end

-- 获取移动方向
function GetMoveDir()
    forwardDir = PlayerCam:IsFreeMode() and PlayerCam.curCamera.Forward or localPlayer.Forward
    forwardDir.y = 0
    rightDir = Vector3(0, 1, 0):Cross(forwardDir)
    horizontal = GuiControl.joystick.Horizontal
    vertical = GuiControl.joystick.Vertical
    if horizontal ~= 0 or vertical ~= 0 then
        this.finalDir = rightDir * horizontal + forwardDir * vertical
    else
        GetKeyValue()
        this.finalDir = forwardDir * (moveForwardAxis + moveBackAxis) - rightDir * (moveLeftAxis + moveRightAxis)
    end
end

-- 跳跃逻辑
function PlayerCtrl:PlayerJump()
    FsmMgr:FsmTriggerEventHandler("Jump")
end

-- 鼓掌逻辑
function PlayerCtrl:PlayerClap()
    localPlayer.Avatar:SetBlendSubtree(Enum.BodyPart.UpperBody, 9)
    localPlayer.Avatar:PlayAnimation("SocialApplause", 9, 1, 0, true, false, 1)
    --拍掌音效
    NetUtil.Fire_C("PlayEffectEvent", localPlayer, 1)
end

-- 射箭逻辑
function PlayerCtrl:PlayerArchery()
    local dir = (localPlayer.ArrowAim.Position - localPlayer.Position)
    dir.y = PlayerCam:TPSGetRayDir().y
    dir = dir.Normalized
    local arrow =
        world:CreateInstance("Arrow_01", "Arrow", world, localPlayer.Avatar.Bone_R_Hand.Position, localPlayer.Rotation)
    arrow.Forward = dir
    arrow.LinearVelocity = arrow.Forward * 40
    invoke(
        function()
            if arrow then
                arrow:Destroy()
            end
        end,
        3
    )
end

--游泳检测
function PlayerCtrl:PlayerSwim()
    if FsmMgr.fsmState ~= "SwimIdle" and FsmMgr.fsmState ~= "Swimming" then
        if
            localPlayer.Position.x < world.water.DeepWaterCol.Position.x + world.water.DeepWaterCol.Size.x / 2 and
                localPlayer.Position.x > world.water.DeepWaterCol.Position.x - world.water.DeepWaterCol.Size.x / 2 and
                localPlayer.Position.z < world.water.DeepWaterCol.Position.z + world.water.DeepWaterCol.Size.z / 2 and
                localPlayer.Position.z > world.water.DeepWaterCol.Position.z - world.water.DeepWaterCol.Size.z / 2 and
                localPlayer.Position.y < -15.7
         then
            FsmMgr:FsmTriggerEventHandler("SwimIdle")
        end
    else
        if
            localPlayer.Position.x > world.water.DeepWaterCol.Position.x + world.water.DeepWaterCol.Size.x / 2 or
                localPlayer.Position.x < world.water.DeepWaterCol.Position.x - world.water.DeepWaterCol.Size.x / 2 or
                localPlayer.Position.z > world.water.DeepWaterCol.Position.z + world.water.DeepWaterCol.Size.z / 2 or
                localPlayer.Position.z < world.water.DeepWaterCol.Position.z - world.water.DeepWaterCol.Size.z / 2 or
                localPlayer.Position.y > -15.7
         then
            NetUtil.Fire_C("GetBuffEvent", localPlayer, 5, -1)
            FsmMgr:FsmTriggerEventHandler("Idle")
        end
    end
end

-- 修改是否能控制角色
function PlayerCtrl:SetPlayerControllableEventHandler(_bool)
    this.isControllable = _bool
    if this.isControllable then
        localPlayer.Local.ControlGui:SetActive(true)
    else
        localPlayer.Local.ControlGui:SetActive(false)
    end
end

-- 角色属性更新
function PlayerCtrl:PlayerAttrUpdate()
    localPlayer.WalkSpeed = Data.Player.attr.WalkSpeed
    localPlayer.JumpUpVelocity = Data.Player.attr.JumpUpVelocity
    localPlayer.Avatar.HeadSize = Data.Player.attr.AvatarHeadSize
    localPlayer.Avatar.Height = Data.Player.attr.AvatarHeight
    localPlayer.Avatar.Width = Data.Player.attr.AvatarWidth
    localPlayer.CharacterWidth = localPlayer.Avatar.Width * 0.5
    localPlayer.CharacterHeight = localPlayer.Avatar.Height * 1.7
    this:PlayerHeadEffectUpdate(Data.Player.attr.HeadEffect)
    this:PlayerBodyEffectUpdate(Data.Player.attr.BodyEffect)
    this:PlayerFootEffectUpdate(Data.Player.attr.Footffect)
    this:PlayerSkinUpdate(Data.Player.attr.SkinID)
    if Data.Player.attr.AnimState ~= "" then
        NetUtil.Fire_C("FsmTriggerEvent", localPlayer, Data.Player.attr.AnimState)
    else
        NetUtil.Fire_C("FsmTriggerEvent", localPlayer, "Idle")
    end
end

-- 更新角色特效
function PlayerCtrl:PlayerHeadEffectUpdate(_effectList)
    for k, v in pairs(localPlayer.Avatar.Bone_Head.HeadEffect:GetChildren()) do
        if v.ActiveSelf then
            v:SetActive(false)
        end
    end
    for k, v in pairs(_effectList) do
        localPlayer.Avatar.Bone_Head.HeadEffect[v]:SetActive(true)
    end
end
function PlayerCtrl:PlayerBodyEffectUpdate(_effectList)
    for k, v in pairs(localPlayer.Avatar.Bone_Pelvis.BodyEffect:GetChildren()) do
        if v.ActiveSelf then
            v:SetActive(false)
        end
    end
    for k, v in pairs(_effectList) do
        localPlayer.Avatar.Bone_Pelvis.BodyEffect[v]:SetActive(true)
    end
end
function PlayerCtrl:PlayerFootEffectUpdate(_effectList)
    for k, v in pairs(localPlayer.Avatar.Bone_R_Foot.FootEffect:GetChildren()) do
        if v.ActiveSelf then
            v:SetActive(false)
        end
    end
    for k, v in pairs(localPlayer.Avatar.Bone_L_Foot.FootEffect:GetChildren()) do
        if v.ActiveSelf then
            v:SetActive(false)
        end
    end
    for k, v in pairs(_effectList) do
        localPlayer.Avatar.Bone_R_Foot.FootEffect[v]:SetActive(true)
        localPlayer.Avatar.Bone_L_Foot.FootEffect[v]:SetActive(true)
    end
end

-- 更新角色服装
function PlayerCtrl:PlayerSkinUpdate(_skinID)
    for k, v in pairs(Config.Skin[_skinID]) do
        if localPlayer.Avatar[k] and v ~= "" then
            localPlayer.Avatar[k] = v or localPlayer.Avatar[k]
        --print(k, v)
        end
    end
end

-- 更新金币
function PlayerCtrl:UpdateCoinEventHandler(_num)
    if _num then
        Data.Player.coin = Data.Player.coin + _num
        GuiControl:UpdateCoinNum(_num)
    end
end

function PlayerCtrl:Update(dt)
    if this.isControllable then
        GetMoveDir()
    end
    this:PlayerSwim()
end

return PlayerCtrl
