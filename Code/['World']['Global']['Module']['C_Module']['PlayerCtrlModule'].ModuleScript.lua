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
    ------print('[PlayerCtrl] Init()')
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
    forwardDir = PlayerCam:IsFreeMode() and PlayerCam.curCamera:GetDeferredForward() or localPlayer.Forward
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
    FsmMgr:FsmTriggerEventHandler('JumpBeginState')
    FsmMgr:FsmTriggerEventHandler('BowJumpBeginState')
end

-- 鼓掌逻辑
function PlayerCtrl:PlayerHello()
    CloudLogUtil.UploadLog('pannel_actions', 'movement_sayhi')
    --localPlayer.Avatar:PlayAnimation('SocialHello', 8, 1, 0, true, false, 1)
    PlayerAnimMgr:CreateSingleClipNode('SocialHello', 1, 'SocialHello')
    PlayerAnimMgr:Play('SocialHello', 0, 1, 0.2, 0.2, true, false, 1)
end

--脚步声
function PlayerCtrl:FeetStepEffect(_dir, _hitObject, _hitPoint)
    if _hitPoint.y < localPlayer.Position.y + 0.1 then
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
    localPlayer.MaxWalkSpeed = Data.Player.attr.MaxWalkSpeed
    localPlayer.JumpUpVelocity = Data.Player.attr.JumpUpVelocity
    localPlayer.CharacterGravityScale = Data.Player.attr.CharacterGravityScale
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
    if GameFlow.inGame == false then
        FsmMgr:FsmTriggerEventHandler('HitState')
        FsmMgr:FsmTriggerEventHandler('BowHitState')
        ------print('角色受伤', table.dump(_data))
        BuffMgr:GetBuffEventHandler(_data.addBuffID, _data.addDur)
        BuffMgr:RemoveBuffEventHandler(_data.removeBuffID)
    end
end

-- 角色传送
function PlayerCtrl:PlayerTeleportEventHandler(_pos, _isEnterUFO)
    NetUtil.Fire_C('ChangeMiniGameUIEvent', localPlayer, 31)
    local effect1 = world:CreateInstance('TeleportEffect', 'TeleportEffect', localPlayer, localPlayer.Position)
    SoundUtil.Play3DSE(localPlayer.Position, 108)
    if _isEnterUFO then
        CloudLogUtil.UploadLog('inter', 'ufo_enter')
    end
    invoke(
        function()
            NetUtil.Fire_C('SwitchTeleportFilterEvent', localPlayer, true)
            localPlayer.Avatar:SetActive(false)
            wait(1)
            localPlayer.Position = _pos
            local effect2 = world:CreateInstance('TeleportEffect', 'TeleportEffect', localPlayer, localPlayer.Position)
            SoundUtil.Play3DSE(_pos, 108)
            effect1:Destroy()
            wait(1)
            NetUtil.Fire_C('SwitchTeleportFilterEvent', localPlayer, false)
            localPlayer.Avatar:SetActive(true)
            NetUtil.Fire_C('ChangeMiniGameUIEvent', localPlayer)
            wait(1)
            effect2:Destroy()
        end,
        1
    )
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

-- 进入桌游的3C处理
function PlayerCtrl:EnterRoomEventHandler(_uuid, _player)
    if _player == localPlayer then
        BuffMgr:BuffClear()
        for k, v in pairs(Config.Interact) do
            NetUtil.Fire_S('LeaveInteractSEvent', localPlayer, k)
            NetUtil.Fire_C('LeaveInteractCEvent', localPlayer, k)
        end
        localPlayer.LinearVelocity = Vector3.Zero
        if ItemMgr.curWeaponID ~= 0 then
            NetUtil.Fire_C('UnequipCurEquipmentEvent', localPlayer)
        end
        invoke(
            function()
                NetUtil.Fire_C('ChangeMiniGameUIEvent', localPlayer, 32)
				wait(0.5)
				localPlayer.Local.ControlGui.TouchFig:SetActive(false)
				localPlayer.Local.ControlGui.Ctrl:SetActive(false)
            end,
            0.5
        )

        --挂起碰撞检测
        localPlayer.PlayerCol.OnCollisionBegin:Clear()
        localPlayer.PlayerCol.OnCollisionEnd:Clear()
    end
end

-- 离开桌游的3C处理
function PlayerCtrl:LeaveRoomEventHandler(_uuid, _playerUid)
    if _playerUid == localPlayer.UserId then
        NetUtil.Fire_C('ChangeMiniGameUIEvent', localPlayer)
        localPlayer.Local.ControlGui.TouchFig:SetActive(true)
		localPlayer.Local.ControlGui.Ctrl:SetActive(true)
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
    end
end

-- 碰到场景交互
function PlayerCtrl:ColFunc(_hitObject, _isBegin)
    if _hitObject.InteractID then
        if _isBegin then
            NetUtil.Fire_C('OutlineCtrlEvent', localPlayer, _hitObject, true)
            NetUtil.Fire_S('SInteractOnPlayerColBeginEvent', localPlayer, _hitObject, _hitObject.InteractID.Value)
            NetUtil.Fire_C('CInteractOnPlayerColBeginEvent', localPlayer, _hitObject, _hitObject.InteractID.Value)
        else
            NetUtil.Fire_C('OutlineCtrlEvent', localPlayer, _hitObject, false)
            NetUtil.Fire_S('SInteractOnPlayerColEndEvent', localPlayer, _hitObject, _hitObject.InteractID.Value)
            NetUtil.Fire_C('CInteractOnPlayerColEndEvent', localPlayer, _hitObject, _hitObject.InteractID.Value)
        end
    end
end

-- 描边的开关
function PlayerCtrl:OutlineCtrlEventHandler(_hitObject, _switch)
    if _switch == true then
        if _hitObject.isModel then
            _hitObject:ShowOutline(Color(255, 255, 0, 255), 5, false, true)
            return
        end
        if _hitObject.Parent and _hitObject.Parent.NpcAvatar then
            _hitObject.Parent.NpcAvatar:ShowOutline(Color(255, 255, 0, 255), 5, false, true)
            return
        end
        for k, v in pairs(_hitObject:GetDescendants()) do
            if v.isModel then
                v:ShowOutline(Color(255, 255, 0, 255), 5, true, true)
                return
            end
        end
    else
        if _hitObject.isModel then
            _hitObject:HideOutline(Color(255, 255, 0, 255), 5, false)
            return
        end
        if _hitObject.Parent.NpcAvatar then
            _hitObject.Parent.NpcAvatar:HideOutline(Color(255, 255, 0, 255), 5, false)
            return
        end
        for k, v in pairs(_hitObject:GetDescendants()) do
            if v.isModel then
                v:HideOutline(Color(255, 255, 0, 255), 5, true)
                return
            end
        end
    end
end

-- 埋需要明确子节点名的交互点
function PlayerCtrl:SInteractUploadEventHandler(_interId, _subinterId)
    CloudLogUtil.UploadLog('pannel_actions', 'dialog_icon_' .. _interId .. '_click', {subinter_id = _subinterId})
end

function PlayerCtrl:Update(dt)
    if this.isControllable then
        GetMoveDir()
    end
end

function PlayerCtrl:StartTTS()
    --localPlayer.Avatar:SetActive(false)
    Input.OnKeyDown:Clear()
    world.OnRenderStepped:Disconnect(this.Update)
    --localPlayer.Local.ControlGUI:SetActive(false)
end

function PlayerCtrl:QuitTTS()
    --localPlayer.Avatar:SetActive(true)
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
    world.OnRenderStepped:Connect(this.Update)
    --localPlayer.Local.ControlGUI:SetActive(true)
end

return PlayerCtrl
