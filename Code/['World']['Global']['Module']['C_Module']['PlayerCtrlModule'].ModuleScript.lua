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
--- 初始化
function PlayerCtrl:Init()
    print('[PlayerCtrl] Init()')
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--- 节点引用
function PlayerCtrl:NodeRef()
end

--- 数据变量初始化
function PlayerCtrl:DataInit()
    SoundUtil.Init(Config.Sound)
    SoundUtil.InitAudioSource(localPlayer.UserId)
    SoundUtil.Play2DSE(localPlayer.UserId, 2)
    this.finalDir = Vector3.Zero
    this.isControllable = true
    localPlayer.Avatar:SetBlendSubtree(Enum.BodyPart.UpperBody, 8)
    localPlayer.Avatar:SetBlendSubtree(Enum.BodyPart.LowerBody, 9)
    for k, v in pairs(world.SenceAudio:GetChildren()) do
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
                PlayerCtrl:OnScenesInteractCol(_hitObject, true)
            end
        end
    )
    localPlayer.PlayerCol.OnCollisionEnd:Connect(
        function(_hitObject)
            if _hitObject then
                PlayerCtrl:OnScenesInteractCol(_hitObject, false)
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
        else
            if _dir == 'R' then
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
            0.5
        )
    end
end

--游泳检测
function PlayerCtrl:PlayerSwim()
    if FsmMgr.playerActFsm.curState.stateName ~= 'SwimIdle' and FsmMgr.playerActFsm.curState.stateName ~= 'Swimming' then
        --print(localPlayer.Position, world.water.DeepWaterCol.Position)
        if
            localPlayer.Position.x < world.Water.DeepWaterCol.Position.x + world.Water.DeepWaterCol.Size.x / 2 and
                localPlayer.Position.x > world.Water.DeepWaterCol.Position.x - world.Water.DeepWaterCol.Size.x / 2 and
                localPlayer.Position.z < world.Water.DeepWaterCol.Position.z + world.Water.DeepWaterCol.Size.z / 2 and
                localPlayer.Position.z > world.Water.DeepWaterCol.Position.z - world.Water.DeepWaterCol.Size.z / 2 and
                localPlayer.Position.y < -15.4
         then
            --print("游泳检测")
            NetUtil.Fire_C('GetBuffEvent', localPlayer, 5, -1)
            SoundUtil.Play2DSE(localPlayer.UserId, 20)
            FsmMgr:FsmTriggerEventHandler('SwimIdle')
        end
    else
        if
            localPlayer.Position.x > world.Water.DeepWaterCol.Position.x + world.Water.DeepWaterCol.Size.x / 2 or
                localPlayer.Position.x < world.Water.DeepWaterCol.Position.x - world.Water.DeepWaterCol.Size.x / 2 or
                localPlayer.Position.z > world.Water.DeepWaterCol.Position.z + world.Water.DeepWaterCol.Size.z / 2 or
                localPlayer.Position.z < world.Water.DeepWaterCol.Position.z - world.Water.DeepWaterCol.Size.z / 2 or
                localPlayer.Position.y > -15.4
         then
            NetUtil.Fire_C('RemoveBuffEvent', localPlayer, 5)
            FsmMgr:FsmTriggerEventHandler('Idle')
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
        --localPlayer.Avatar.Bone_R_Foot.FootEffect[v]:SetActive(true)
        --localPlayer.Avatar.Bone_L_Foot.FootEffect[v]:SetActive(true)
    end
end

-- 更新金币
function PlayerCtrl:UpdateCoinEventHandler(_num, _fromBag)
    if _num ~= 0 then
        if _num > 0 and _fromBag then
            SoundUtil.Play2DSE(localPlayer.UserId, 111)
        elseif _num > 0 then
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
    print('角色受伤', table.dump(_data))
    BuffMgr:GetBuffEventHandler(_data.addBuffID, _data.addDur)
    BuffMgr:RemoveBuffEventHandler(_data.removeBuffID)
end

-- 角色重置
function PlayerCtrl:PlayerReset()
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
function PlayerCtrl:OnScenesInteractCol(_hitObject, _isBegin)
    if _hitObject then
        if _hitObject.ScenesInteractUID then
            if _isBegin then
                _hitObject.ScenesInteractUID.Value = localPlayer.UserId
                NetUtil.Fire_C('OpenDynamicEvent', localPlayer, 'Interact', 13, _hitObject.ScenesInteractID.Value)
            else
                _hitObject.ScenesInteractUID.Value = ''
                NetUtil.Fire_C('CloseDynamicEvent', localPlayer)
            end
        end
        if _hitObject.TelescopeInteractUID then
            if _isBegin and _hitObject.TelescopeInteractUID.Value == '' then
                _hitObject.TelescopeInteractUID.Value = localPlayer.UserId
                NetUtil.Fire_C('OpenDynamicEvent', localPlayer, 'Interact', 14)
            else
                _hitObject.TelescopeInteractUID.Value = ''
                NetUtil.Fire_C('CloseDynamicEvent', localPlayer)
            end
        end
        if _hitObject.SeatInteractUID then
            if _isBegin and _hitObject.SeatInteractUID.Value == '' then
                _hitObject.SeatInteractUID.Value = localPlayer.UserId
                NetUtil.Fire_C('OpenDynamicEvent', localPlayer, 'Interact', 15)
            else
                _hitObject.SeatInteractUID.Value = ''
                NetUtil.Fire_C('CloseDynamicEvent', localPlayer)
            end
        end
        if _hitObject.BonfireInteractUID then
            if _isBegin and _hitObject.BonfireInteractUID.Value == '' then
                _hitObject.BonfireInteractUID.Value = localPlayer.UserId
                NetUtil.Fire_C('OpenDynamicEvent', localPlayer, 'Interact', 16)
            else
                _hitObject.BonfireInteractUID.Value = ''
                NetUtil.Fire_C('CloseDynamicEvent', localPlayer)
            end
        end
        if _hitObject.BounceInteractUID then
            if _isBegin then
                _hitObject.BounceInteractUID.Value = localPlayer.UserId
                NetUtil.Fire_S('InteractSEvent', localPlayer, 17)
            end
        end
        if _hitObject.GrassInteractUID then
            if _isBegin and _hitObject.GrassInteractUID.Value == '' then
                _hitObject.GrassInteractUID.Value = localPlayer.UserId
                NetUtil.Fire_S('InteractSEvent', localPlayer, 18)
            else
                _hitObject.GrassInteractUID.Value = ''
            end
        end
        if _hitObject.AnimalCaughtEvent then
            if _isBegin then
                Catch:TouchPrey(_hitObject, true)
                NetUtil.Fire_C('OpenDynamicEvent', localPlayer, 'Interact', 19)
            else
                --NetUtil.Fire_C("ChangeMiniGameUIEvent", localPlayer)
            end
        end
        if _hitObject.Parent.TrojanUID then
            if _isBegin and _hitObject.Parent.TrojanUID.Value == '' then
                _hitObject.Parent.TrojanUID.Value = localPlayer.UserId
                NetUtil.Fire_C('OpenDynamicEvent', localPlayer, 'Interact', 20)
            else
                _hitObject.Parent.TrojanUID.Value = ''
                NetUtil.Fire_C('CloseDynamicEvent', localPlayer)
            end
        end
        if _hitObject.GuitarUID then
            if _isBegin and _hitObject.GuitarUID.Value == '' then
                _hitObject.GuitarUID.Value = localPlayer.UserId
                NetUtil.Fire_C('OpenDynamicEvent', localPlayer, 'Interact', 21)
            else
                _hitObject.GuitarUID.Value = ''
                NetUtil.Fire_C('CloseDynamicEvent', localPlayer)
            end
        end
        if _hitObject.TentUID1 then
            if _isBegin then
                if _hitObject.TentUID1.Value == localPlayer.UserId or _hitObject.TentUID1.Value == '' then
                    _hitObject.TentUID1.Value = localPlayer.UserId
                    NetUtil.Fire_C('OpenDynamicEvent', localPlayer, 'Interact', 22)
                    return
                end
                if _hitObject.TentUID2.Value == localPlayer.UserId or _hitObject.TentUID2.Value == '' then
                    _hitObject.TentUID2.Value = localPlayer.UserId
                    NetUtil.Fire_C('OpenDynamicEvent', localPlayer, 'Interact', 22)
                    return
                end
            else
                NetUtil.Fire_C('CloseDynamicEvent', localPlayer)
                if _hitObject.TentUID1.Value == localPlayer.UserId then
                    _hitObject.TentUID1.Value = ''
                elseif _hitObject.TentUID2.Value == localPlayer.UserId then
                    _hitObject.TentUID2.Value = ''
                end
            end
        end
        if _hitObject.BombUID then
            if _isBegin and _hitObject.BombUID.Value == '' then
                _hitObject.BombUID.Value = localPlayer.UserId
                NetUtil.Fire_C('OpenDynamicEvent', localPlayer, 'Interact', 23)
            else
                _hitObject.BombUID.Value = ''
                NetUtil.Fire_C('CloseDynamicEvent', localPlayer)
            end
        end
        if _hitObject.RadioUID then
            if _isBegin and _hitObject.RadioUID.Value == '' then
                _hitObject.RadioUID.Value = localPlayer.UserId
                NetUtil.Fire_C('OpenDynamicEvent', localPlayer, 'Interact', 24)
            else
                _hitObject.RadioUID.Value = ''
                NetUtil.Fire_C('CloseDynamicEvent', localPlayer)
            end
        end
        if _hitObject.PotUID then
            if _isBegin and _hitObject.PotUID.Value == '' then
                _hitObject.PotUID.Value = localPlayer.UserId
                NetUtil.Fire_C('OpenDynamicEvent', localPlayer, 'Interact', 26)
            else
                _hitObject.PotUID.Value = ''
                NetUtil.Fire_C('CloseDynamicEvent', localPlayer)
            end
        end
    end
end

function PlayerCtrl:Update(dt)
    if this.isControllable then
        GetMoveDir()
    end
    this:PlayerSwim()
end

return PlayerCtrl
