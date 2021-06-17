--- 角色镜头模块
--- @module Player Cam Module
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local PlayerCam, this = ModuleUtil.New('PlayerCam', ClientBase)

--滤镜开关
local swimFilterSwitch = false

--- 初始化
function PlayerCam:Init()
    --print('[PlayerCam] Init()')
    this:NodeRef()
    this:DataInit()
    this:EventBind()
    this:InitCamera()
end

--- 节点引用
function PlayerCam:NodeRef()
end

--- 数据变量初始化
function PlayerCam:DataInit()
    -- 当前的相机
    this.curCamera = nil

    -- 玩家跟随相机
    this.playerGameCam = localPlayer.Local.Independent.GameCam

    -- TPS相机
    this.tpsCam = localPlayer.Local.Independent.TPSCam

    -- FPS相机
    this.fpsCam = localPlayer.Local.Independent.FPSCam

    this.actionCam = localPlayer.Local.Independent.ActionCam

    --* 存储相机tweener
    this.distanceTweener = nil
end

--- 节点事件绑定
function PlayerCam:EventBind()
end

function PlayerCam:InitCamera()
    if not this.curCamera and this.playerGameCam then
        this.curCamera = this.playerGameCam
    end
    this.playerGameCam.LookAt = localPlayer
    world.CurrentCamera = this.curCamera
end

-- 玩家移动方向是否遵循玩家摄像机方向
function PlayerCam:IsFreeMode()
    return (this.curCamera.CameraMode == Enum.CameraMode.Social and this.curCamera.Distance >= 0) or
        this.curCamera.CameraMode == Enum.CameraMode.Orbital or
        this.curCamera.CameraMode == Enum.CameraMode.Custom or
        this.curCamera.CameraMode == Enum.CameraMode.Smart
end

-- 滑屏转向
function PlayerCam:CameraMove(touchInfo)
    if #touchInfo == 1 and not (GameFlow.inGame) then
        if this:IsFreeMode() then
            this.curCamera:CameraMove(touchInfo[1].DeltaPosition)
        else
            print(this.curCamera)
            this.curCamera.LookAt:Rotate(0, touchInfo[1].DeltaPosition.x * 0.2, 0)
            this.curCamera:CameraMove(Vector2(0, touchInfo[1].DeltaPosition.y))
        end
    end
end

-- 双指缩放摄像机距离
function PlayerCam:CameraZoom(_pos1, _pos2, _dis, _speed)
    if this.curCamera.CameraMode == Enum.CameraMode.Social then
        this.curCamera.Distance = this.curCamera.Distance - _dis / 50
    end
end

--- TPS相机射线检测目标
function PlayerCam:TPSGetRayDir()
    local hitResult = Physics:RaycastAll(this.tpsCam.Position, this.tpsCam.Position + this.tpsCam.Forward * 100, false)
    for i, v in ipairs(hitResult:GetHitPosAll()) do --获取所有碰到的物体
        if
            (v - localPlayer.Position).Magnitude > 4 and
                Vector3.Angle(localPlayer.Forward, (v - localPlayer.Position)) < 90 and
                hitResult:GetHitObjAll()[i].Parent.Name ~= 'Water' and
                hitResult:GetHitObjAll()[i].Parent.Name ~= 'ColBox'
         then
            ----print(hitResult:GetHitObjAll()[i])
            return v
        end
    end
    return this.tpsCam.Position + this.tpsCam.Forward * 100
end

-- Fov缩放
function PlayerCam:CameraFOVZoom(_fovChange, _maxFov)
    if _fovChange > 0 and this.curCamera.FieldOfView > _maxFov + 1 then
        _fovChange = -0.2
    elseif _fovChange > 0 and this.curCamera.FieldOfView > _maxFov then
        _fovChange = 0
    end
    this.curCamera.FieldOfView = math.clamp(this.curCamera.FieldOfView + _fovChange, 60, 90)
end

---开关游泳滤镜
function PlayerCam:SwitchSwimFilter(_switch)
    swimFilterSwitch = _switch
    if _switch then
        this.playerGameCam.WaterVignette:SetActive(true)
        this.playerGameCam.WaterGaussionBlur:SetActive(true)
        this.playerGameCam.WaterAmbientOcclusion:SetActive(true)
        this.playerGameCam.WaterGrain:SetActive(true)
        this.playerGameCam.WaterColorGrading:SetActive(true)
        this.playerGameCam.WaterEffect:SetActive(true)
    else
        this.playerGameCam.WaterVignette:SetActive(false)
        this.playerGameCam.WaterGaussionBlur:SetActive(false)
        this.playerGameCam.WaterAmbientOcclusion:SetActive(false)
        this.playerGameCam.WaterGrain:SetActive(false)
        this.playerGameCam.WaterColorGrading:SetActive(false)
        this.playerGameCam.WaterEffect:SetActive(false)
    end
end

---开关传送滤镜
function PlayerCam:SwitchTeleportFilterEventHandler(_switch)
    if _switch then
        this.playerGameCam.TeleportGlitch:SetActive(true)
    else
        this.playerGameCam.TeleportGlitch:SetActive(false)
    end
end

---TPS相机缩放
function PlayerCam:TPSCamZoom(_force)
    this.tpsCam.FieldOfView = 60 - 10 * _force
    this.tpsCam.Distance = 3 - 1 * _force
end

---游泳滤镜检测
function PlayerCam:UpdateSwimFilter()
    if not localPlayer:IsSwimming() then
        if swimFilterSwitch == true then
            this:SwitchSwimFilter(false)
        end
    else
        if this.playerGameCam.Position.y < -14.5 then
            if swimFilterSwitch == false then
                this:SwitchSwimFilter(true)
            end
        else
            if swimFilterSwitch == true then
                this:SwitchSwimFilter(false)
            end
        end
    end
end

-- 修改玩家当前相机
function PlayerCam:SetCurCamEventHandler(_cam, _lookAt)
    if not (GameFlow.inGame) and this.curCamera then
        this.curCamera = _cam or this.playerGameCam
        this.curCamera.LookAt = _lookAt or localPlayer
        world.CurrentCamera = this.curCamera
    end
end

-- 转变为FPS相机
function PlayerCam:SetFPSCamEventHandler(_lookAt)
    this.curCamera = this.fpsCam
    this.curCamera.LookAt = _lookAt
    world.CurrentCamera = this.curCamera
end

-- 推远或推近玩家镜头
function PlayerCam:SetCamDistanceEventHandler(_distance, _duration, _triggerBlock)
    if this.distanceTweener then
        this.distanceTweener:Pause()
        this.distanceTweener:Destroy()
    end
    this.curCamera.PhysicalBlock = false
    this.distanceTweener = Tween:TweenProperty(this.curCamera, {Distance = _distance}, _duration, 1)
    this.distanceTweener:Play()
    this.distanceTweener:WaitForComplete()
    this.curCamera.PhysicalBlock = _triggerBlock or false
end

local actionFovTweener
function PlayerCam:FoodOnDeskActionEventHandler(_foodId)
    this.actionCam.FieldOfView = 60
    NetUtil.Fire_C('SetCurCamEvent', localPlayer, this.actionCam)
    actionFovTweener = Tween:TweenProperty(this.actionCam, {FieldOfView = 50}, 1.5, 1)
    actionFovTweener:Play()
    actionFovTweener:WaitForComplete()
    NetUtil.Fire_S('FoodOnDeskEvent', _foodId, localPlayer)
end

function PlayerCam:ResetTentCamEventHandler(_distance)
    this.curCamera.LookAt = localPlayer
    wait()
    this.curCamera:CameraMoveInDegree(Vector2(180, 0))
    NetUtil.Fire_C('SetCamDistanceEvent', localPlayer, _distance, 1, true)
end

function PlayerCam:Update(dt)
    this:UpdateSwimFilter()
end

return PlayerCam
