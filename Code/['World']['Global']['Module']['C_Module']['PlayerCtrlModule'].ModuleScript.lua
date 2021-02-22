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
            if Input.GetPressKeyData(Enum.KeyCode.P) == 1 then
                ItemMgr.itemInstance[1001]:Use()
            end
            if Input.GetPressKeyData(Enum.KeyCode.O) == 1 then
                ItemMgr.itemInstance[2001]:Use()
            end
            if Input.GetPressKeyData(Enum.KeyCode.Mouse2) == 1 and ItemMgr.curWeaponID ~= 0 then
                ItemMgr.itemInstance[ItemMgr.curWeaponID]:Attack()
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

--游泳检测
function PlayerCtrl:PlayerSwim()
    if FsmMgr.playerActFsm.curState.stateName ~= "SwimIdle" and FsmMgr.playerActFsm.curState.stateName ~= "Swimming" then
        --print(localPlayer.Position, world.water.DeepWaterCol.Position)
        if
            localPlayer.Position.x < world.water.DeepWaterCol.Position.x + world.water.DeepWaterCol.Size.x / 2 and
                localPlayer.Position.x > world.water.DeepWaterCol.Position.x - world.water.DeepWaterCol.Size.x / 2 and
                localPlayer.Position.z < world.water.DeepWaterCol.Position.z + world.water.DeepWaterCol.Size.z / 2 and
                localPlayer.Position.z > world.water.DeepWaterCol.Position.z - world.water.DeepWaterCol.Size.z / 2 and
                localPlayer.Position.y < -15.7
         then
            --print("游泳检测")
            NetUtil.Fire_C("GetBuffEvent", localPlayer, 5, -1)
        --FsmMgr:FsmTriggerEventHandler("SwimIdle")
        end
    else
        if
            localPlayer.Position.x > world.water.DeepWaterCol.Position.x + world.water.DeepWaterCol.Size.x / 2 or
                localPlayer.Position.x < world.water.DeepWaterCol.Position.x - world.water.DeepWaterCol.Size.x / 2 or
                localPlayer.Position.z > world.water.DeepWaterCol.Position.z + world.water.DeepWaterCol.Size.z / 2 or
                localPlayer.Position.z < world.water.DeepWaterCol.Position.z - world.water.DeepWaterCol.Size.z / 2 or
                localPlayer.Position.y > -15.7
         then
            NetUtil.Fire_C("RemoveBuffEvent", localPlayer, 5)
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
    localPlayer.CharacterWidth = localPlayer.Avatar.Height * 0.5
    localPlayer.CharacterHeight = localPlayer.Avatar.Height * 1.7
    this:PlayerHeadEffectUpdate(Data.Player.attr.HeadEffect)
    this:PlayerBodyEffectUpdate(Data.Player.attr.BodyEffect)
    this:PlayerFootEffectUpdate(Data.Player.attr.FootEffect)
    this:PlayerSkinUpdate(Data.Player.attr.SkinID)
    if Data.Player.attr.AnimState ~= "" then
        NetUtil.Fire_C("FsmTriggerEvent", localPlayer, Data.Player.attr.AnimState)
    else
    end
    if not Data.Player.attr.EnableEquipable then
        NetUtil.Fire_C("UnequipCurWeaponEvent", localPlayer)
    end
end

-- 更新角色特效
function PlayerCtrl:PlayerHeadEffectUpdate(_effectList)
    for k, v in pairs(localPlayer.Avatar.Bone_Head.HeadEffect:GetChildren()) do
        --[[if v.ActiveSelf then
            v:SetActive(false)
        end]]
        v:Destroy()
    end
    for k, v in pairs(_effectList) do
        world:CreateInstance(
            v,
            v,
            localPlayer.Avatar.Bone_Head.HeadEffect,
            localPlayer.Avatar.Bone_Head.HeadEffect.Position
        )
        --localPlayer.Avatar.Bone_Head.HeadEffect[v]:SetActive(true)
    end
end
function PlayerCtrl:PlayerBodyEffectUpdate(_effectList)
    for k, v in pairs(localPlayer.Avatar.Bone_Pelvis.BodyEffect:GetChildren()) do
        --[[if v.ActiveSelf then
            v:SetActive(false)
        end]]
        v:Destroy()
    end
    for k, v in pairs(_effectList) do
        world:CreateInstance(
            v,
            v,
            localPlayer.Avatar.Bone_Pelvis.BodyEffect,
            localPlayer.Avatar.Bone_Pelvis.BodyEffect.Position
        )
        --localPlayer.Avatar.Bone_Pelvis.BodyEffect[v]:SetActive(true)
    end
end
function PlayerCtrl:PlayerFootEffectUpdate(_effectList)
    for k, v in pairs(localPlayer.Avatar.Bone_R_Foot.FootEffect:GetChildren()) do
        --[[if v.ActiveSelf then
            v:SetActive(false)
        end]]
        v:Destroy()
    end
    for k, v in pairs(localPlayer.Avatar.Bone_L_Foot.FootEffect:GetChildren()) do
        --[[if v.ActiveSelf then
            v:SetActive(false)
        end]]
        v:Destroy()
    end
    for k, v in pairs(_effectList) do
        world:CreateInstance(
            v,
            v,
            localPlayer.Avatar.Bone_R_Foot.FootEffect,
            localPlayer.Avatar.Bone_R_Foot.FootEffect.Position
        )
        world:CreateInstance(
            v,
            v,
            localPlayer.Avatar.Bone_L_Foot.FootEffect,
            localPlayer.Avatar.Bone_L_Foot.FootEffect.Position
        )
        --localPlayer.Avatar.Bone_R_Foot.FootEffect[v]:SetActive(true)
        --localPlayer.Avatar.Bone_L_Foot.FootEffect[v]:SetActive(true)
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

-- 角色受伤
function PlayerCtrl:CPlayerHitEventHandler(_data)
    FsmMgr:FsmTriggerEventHandler("Hit")
    FsmMgr:FsmTriggerEventHandler("BowHit")
    FsmMgr:FsmTriggerEventHandler("OneHandedSwordHit")
    FsmMgr:FsmTriggerEventHandler("TwoHandedSwordHit")
    print("角色受伤", table.dump(_data))
    BuffMgr:GetBuffEventHandler(_data.hitAddBuffID, _data.hitAddBuffDur)
    BuffMgr:RemoveBuffEventHandler(_data.hitRemoveBuffID)
end

function PlayerCtrl:Update(dt)
    if this.isControllable then
        GetMoveDir()
    end
    this:PlayerSwim()
end

return PlayerCtrl
