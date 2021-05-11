--- 角色控制模块
--- @module Player Ctrl Module
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local PlayerCtrl, this = ModuleUtil.New('PlayerCtrl', ClientBase)

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

local isOnWater = false

local isSwim = false

--- 初始化
function PlayerCtrl:Init()
    --print('[PlayerCtrl] Init()')
    this:SoundInit()
    this:DataInit()
    this:EventBind()
end

--- 节点引用
function PlayerCtrl:SoundInit()
    SoundUtil.Init(Config.Sound)
    SoundUtil.InitAudioSource(localPlayer.UserId)
    SoundUtil.Play2DSE(localPlayer.UserId, 2)
end

--- 数据变量初始化
function PlayerCtrl:DataInit()
    this.finalDir = Vector3.Zero
    this.isControllable = true
    localPlayer.Avatar:SetBlendSubtree(Enum.BodyPart.UpperBody, 8)
    localPlayer.Avatar:SetBlendSubtree(Enum.BodyPart.LowerBody, 9)
    for k, v in pairs(world.ScenesAudio:GetChildren()) do
        if v.State == Enum.AudioSourceState.Stopped then
            v:Play()
        end
    end
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
    localPlayer.PlayerCol.OnCollisionBegin:Connect(
        function(_hitObject)
            if _hitObject then
                this:ColFunc(_hitObject, true)
            end
        end
    )
    localPlayer.PlayerCol.OnCollisionEnd:Connect(
        function(_hitObject)
            if _hitObject then
                this:ColFunc(_hitObject, false)
            end
        end
    )
    localPlayer.CoinCol.OnCollisionBegin:Connect(
        function(_hitObject)
            if _hitObject and _hitObject.CoinUID then
                if _hitObject.CoinUID.Value == localPlayer.UserId or string.isnilorempty(_hitObject.CoinUID.Value) then
                    _hitObject.CoinUID.Value = localPlayer.UserId
                end
            end
        end
    )

    localPlayer.OnCollisionBegin:Connect(
        function(_hitObject)
            if _hitObject then
                if _hitObject.Name == 'SallowWaterCol' then
                    isOnWater = true
                end
            end
        end
    )
    localPlayer.OnCollisionEnd:Connect(
        function(_hitObject)
            if _hitObject then
                if _hitObject.Name == 'SallowWaterCol' then
                    isOnWater = false
                end
            end
        end
    )
    localPlayer.Avatar.Bone_R_Foot.FootStep.OnCollisionEnd:Connect(
        function(_hitObject, _hitPoint)
            PlayerCtrl:FeetStepEffect('R', _hitObject, _hitPoint)
        end
    )
    localPlayer.Avatar.Bone_L_Foot.FootStep.OnCollisionEnd:Connect(
        function(_hitObject, _hitPoint)
            PlayerCtrl:FeetStepEffect('L', _hitObject, _hitPoint)
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
    FsmMgr:FsmTriggerEventHandler('Jump')
end

-- 鼓掌逻辑
function PlayerCtrl:PlayerHello()
    CloudLogUtil.UploadLog('pannel_actions', 'movement_sayhi')
    localPlayer.Avatar:PlayAnimation('SocialHello', 8, 1, 0, true, false, 1)
end

--脚步声
function PlayerCtrl:FeetStepEffect(_dir, _hitObject, _hitPoint)
    if
        _hitPoint.y < localPlayer.Position.y + 0.1 and FsmMgr.playerActFsm.curState.stateName ~= 'SwimIdle' and
            FsmMgr.playerActFsm.curState.stateName ~= 'Swimming'
     then
        if isOnWater then
            SoundUtil.Play2DSE(localPlayer.UserId, 19)
        elseif _hitObject and _hitObject.Parent then
            if _dir == 'R' and _hitObject.Parent.Name == 'grass' then
                SoundUtil.Play2DSE(localPlayer.UserId, 118)
            elseif _dir == 'L' and _hitObject.Parent.Name == 'grass' then
                SoundUtil.Play2DSE(localPlayer.UserId, 17)
            elseif _dir == 'R' and _hitObject.Parent.Name == 'cloth' then
                SoundUtil.Play2DSE(localPlayer.UserId, 122)
            elseif _dir == 'L' and _hitObject.Parent.Name == 'cloth' then
                SoundUtil.Play2DSE(localPlayer.UserId, 121)
            elseif _dir == 'R' and _hitObject.Parent.Name == 'stone' then
                SoundUtil.Play2DSE(localPlayer.UserId, 124)
            elseif _dir == 'L' and _hitObject.Parent.Name == 'stone' then
                SoundUtil.Play2DSE(localPlayer.UserId, 123)
            elseif _dir == 'R' and _hitObject.Parent.Name == 'cloud' then
                SoundUtil.Play2DSE(localPlayer.UserId, 130)
            elseif _dir == 'L' and _hitObject.Parent.Name == 'cloud' then
                SoundUtil.Play2DSE(localPlayer.UserId, 129)
            elseif _dir == 'R' and _hitObject.Parent.Name == 'wood' then
                SoundUtil.Play2DSE(localPlayer.UserId, 126)
            elseif _dir == 'L' and _hitObject.Parent.Name == 'wood' then
                SoundUtil.Play2DSE(localPlayer.UserId, 125)
            elseif _dir == 'R' and _hitObject.Parent.Name == 'metal' then
                SoundUtil.Play2DSE(localPlayer.UserId, 128)
            elseif _dir == 'L' and _hitObject.Parent.Name == 'metal' then
                SoundUtil.Play2DSE(localPlayer.UserId, 127)
            elseif _dir == 'R' then
                SoundUtil.Play2DSE(localPlayer.UserId, 118)
            else
                SoundUtil.Play2DSE(localPlayer.UserId, 17)
            end
        end
        localPlayer.Avatar['Bone_' .. _dir .. '_Foot'].FootStep.OnCollisionEnd:Clear()
        invoke(
            function()
                localPlayer.Avatar['Bone_' .. _dir .. '_Foot'].FootStep.OnCollisionEnd:Connect(
                    function(_hitObject, _hitPoint)
                        this:FeetStepEffect(_dir, _hitObject, _hitPoint)
                    end
                )
            end,
            0.1
        )
    end
end

--游泳检测
function PlayerCtrl:PlayerSwim()
    if isSwim == false then
        if
            localPlayer.Position.x < world.Water.DeepWaterCol.Position.x + world.Water.DeepWaterCol.Size.x / 2 and
                localPlayer.Position.x > world.Water.DeepWaterCol.Position.x - world.Water.DeepWaterCol.Size.x / 2 and
                localPlayer.Position.z < world.Water.DeepWaterCol.Position.z + world.Water.DeepWaterCol.Size.z / 2 and
                localPlayer.Position.z > world.Water.DeepWaterCol.Position.z - world.Water.DeepWaterCol.Size.z / 2 and
                localPlayer.Position.y < -15.4
         then
            --print('进入游泳')
            FsmMgr:FsmTriggerEventHandler('SwimIdle')
            if
                FsmMgr.playerActFsm.curState.stateName == 'SwimIdle' or
                    FsmMgr.playerActFsm.curState.stateName == 'Swimming'
             then
                isSwim = true
                NetUtil.Fire_C('ChangeMiniGameUIEvent', localPlayer, 30)
                NetUtil.Fire_C('GetBuffEvent', localPlayer, 5, -1)
                SoundUtil.Play2DSE(localPlayer.UserId, 20)
            end
        end
    else
        if
            localPlayer.Position.x > world.Water.DeepWaterCol.Position.x + world.Water.DeepWaterCol.Size.x / 2 or
                localPlayer.Position.x < world.Water.DeepWaterCol.Position.x - world.Water.DeepWaterCol.Size.x / 2 or
                localPlayer.Position.z > world.Water.DeepWaterCol.Position.z + world.Water.DeepWaterCol.Size.z / 2 or
                localPlayer.Position.z < world.Water.DeepWaterCol.Position.z - world.Water.DeepWaterCol.Size.z / 2 or
                localPlayer.Position.y > -15.4
         then
            --print('退出游泳')
            FsmMgr:FsmTriggerEventHandler('Idle')
            if
                FsmMgr.playerActFsm.curState.stateName ~= 'SwimIdle' and
                    FsmMgr.playerActFsm.curState.stateName ~= 'Swimming'
             then
                isSwim = false
                localPlayer.GravityScale = 2
                NetUtil.Fire_C('ChangeMiniGameUIEvent', localPlayer)
                NetUtil.Fire_C('RemoveBuffEvent', localPlayer, 5)
                local effect =
                    world:CreateInstance('LandWater', 'LandWater', world, localPlayer.Position + Vector3(0, 2, 0))
                invoke(
                    function()
                        effect:Destroy()
                    end,
                    1
                )
            end
        else
            if
                FsmMgr.playerActFsm.curState.stateName ~= 'SwimIdle' and
                    FsmMgr.playerActFsm.curState.stateName ~= 'Swimming'
             then
                isSwim = false
                NetUtil.Fire_C('ChangeMiniGameUIEvent', localPlayer)
                NetUtil.Fire_C('RemoveBuffEvent', localPlayer, 5)
                local effect =
                    world:CreateInstance('LandWater', 'LandWater', world, localPlayer.Position + Vector3(0, 2, 0))
                invoke(
                    function()
                        effect:Destroy()
                    end,
                    1
                )
            end
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
    this:PlayerHandEffectUpdate(Data.Player.attr.HandEffect)
    this:PlayerFootEffectUpdate(Data.Player.attr.FootEffect)
    this:PlayerEntiretyEffectUpdate(Data.Player.attr.EntiretyEffect)
    --this:PlayerSkinUpdate(Data.Player.attr.SkinID)
    if not Data.Player.attr.EnableEquipable then
        NetUtil.Fire_C('UnequipCurEquipmentEvent', localPlayer)
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
            localPlayer.Avatar.Bone_Head.HeadEffect.Position,
            localPlayer.Avatar.Bone_Head.HeadEffect.Rotation
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
            localPlayer.Avatar.Bone_Pelvis.BodyEffect.Position,
            localPlayer.Avatar.Bone_Pelvis.BodyEffect.Rotation
        )
        --localPlayer.Avatar.Bone_Pelvis.BodyEffect[v]:SetActive(true)
    end
end

function PlayerCtrl:PlayerHandEffectUpdate(_effectList)
    for k, v in pairs(localPlayer.Avatar.Bone_R_Hand.HandEffect:GetChildren()) do
        v:Destroy()
    end
    for k, v in pairs(localPlayer.Avatar.Bone_L_Hand.HandEffect:GetChildren()) do
        v:Destroy()
    end
    for k, v in pairs(_effectList) do
        world:CreateInstance(
            v,
            v,
            localPlayer.Avatar.Bone_R_Hand.HandEffect,
            localPlayer.Avatar.Bone_R_Hand.HandEffect.Position,
            localPlayer.Avatar.Bone_R_Hand.HandEffect.Rotation
        )
        world:CreateInstance(
            v,
            v,
            localPlayer.Avatar.Bone_L_Hand.HandEffect,
            localPlayer.Avatar.Bone_L_Hand.HandEffect.Position,
            localPlayer.Avatar.Bone_L_Hand.HandEffect.Rotation
        )
    end
end
function PlayerCtrl:PlayerFootEffectUpdate(_effectList)
    for k, v in pairs(localPlayer.Avatar.Bone_R_Foot.FootEffect:GetChildren()) do
        v:Destroy()
    end
    for k, v in pairs(localPlayer.Avatar.Bone_L_Foot.FootEffect:GetChildren()) do
        v:Destroy()
    end
    for k, v in pairs(_effectList) do
        world:CreateInstance(
            v,
            v,
            localPlayer.Avatar.Bone_R_Foot.FootEffect,
            localPlayer.Avatar.Bone_R_Foot.FootEffect.Position,
            localPlayer.Avatar.Bone_R_Foot.FootEffect.Rotation
        )
        world:CreateInstance(
            v,
            v,
            localPlayer.Avatar.Bone_L_Foot.FootEffect,
            localPlayer.Avatar.Bone_L_Foot.FootEffect.Position,
            localPlayer.Avatar.Bone_L_Foot.FootEffect.Rotation
        )
    end
end

function PlayerCtrl:PlayerEntiretyEffectUpdate(_effectList)
    for k, v in pairs(localPlayer.Avatar.EntiretyEffect:GetChildren()) do
        v:Destroy()
    end
    for k, v in pairs(_effectList) do
        world:CreateInstance(
            v,
            v,
            localPlayer.Avatar.EntiretyEffect,
            localPlayer.Avatar.EntiretyEffect.Position,
            localPlayer.Avatar.EntiretyEffect.Rotation
        )
    end
end

-- 更新金币
function PlayerCtrl:UpdateCoinEventHandler(_num, _fromBag, _origin)
    if _num ~= 0 then
        if _num > 0 and _fromBag then
            CloudLogUtil.UploadLog(
                'game_item_flow',
                'getCoin',
                {coin_orgin = _origin, item_after = Data.Player.coin, item_count = Data.Player.coin + _num}
            )
            SoundUtil.Play2DSE(localPlayer.UserId, 111)
        elseif _num > 0 then
            CloudLogUtil.UploadLog(
                'game_item_flow',
                'getCoin',
                {coin_orgin = _origin, item_after = Data.Player.coin, item_count = Data.Player.coin + _num}
            )
            SoundUtil.Play2DSE(localPlayer.UserId, 4)
        end
        Data.Player.coin = Data.Player.coin + _num
        GuiControl:UpdateCoinNum(_num)
    end
end

-- 角色受伤
function PlayerCtrl:CPlayerHitEventHandler(_data)
    FsmMgr:FsmTriggerEventHandler('Hit')
    FsmMgr:FsmTriggerEventHandler('BowHit')
    FsmMgr:FsmTriggerEventHandler('OneHandedSwordHit')
    FsmMgr:FsmTriggerEventHandler('TwoHandedSwordHit')
    --print('角色受伤', table.dump(_data))
    BuffMgr:GetBuffEventHandler(_data.addBuffID, _data.addDur)
    BuffMgr:RemoveBuffEventHandler(_data.removeBuffID)
end

-- 角色重置
function PlayerCtrl:PlayerReset()
    CloudLogUtil.UploadLog('pannel_actions', 'movement_reset')
    BuffMgr:BuffClear()
    for k, v in pairs(Config.Interact) do
        NetUtil.Fire_S('LeaveInteractSEvent', localPlayer, k)
        NetUtil.Fire_C('LeaveInteractCEvent', localPlayer, k)
    end
    localPlayer.LinearVelocity = Vector3.Zero
    localPlayer.Position = world.SpawnLocations.StartPortal00.Position
    if ItemMgr.curWeaponID ~= 0 then
        NetUtil.Fire_C('UnequipCurEquipmentEvent', localPlayer)
    end
end

-- 碰到场景交互
function PlayerCtrl:ColFunc(_hitObject, _isBegin)
    if _hitObject.InteractID then
        if _isBegin then
            NetUtil.Fire_S('SInteractOnPlayerColBeginEvent', localPlayer, _hitObject, _hitObject.InteractID.Value)
            NetUtil.Fire_C('CInteractOnPlayerColBeginEvent', localPlayer, _hitObject, _hitObject.InteractID.Value)
        else
            NetUtil.Fire_S('SInteractOnPlayerColEndEvent', localPlayer, _hitObject, _hitObject.InteractID.Value)
            NetUtil.Fire_C('CInteractOnPlayerColEndEvent', localPlayer, _hitObject, _hitObject.InteractID.Value)
        end
    end
end

-- 埋需要明确子节点名的交互点
function PlayerCtrl:SInteractUploadEventHandler(_interId,_subinterId)
    CloudLogUtil.UploadLog(
        'pannel_actions',
        'dialog_icon_'.._interId..'_click',
        {subinter_id = _subinterId}
    )
end



function PlayerCtrl:Update(dt)
    if this.isControllable then
        GetMoveDir()
    end
    this:PlayerSwim()
end

return PlayerCtrl
