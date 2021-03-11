--- 角色镜头模块
--- @module Player Cam Module
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local PlayerCam, this = ModuleUtil.New("PlayerCam", ClientBase)

--滤镜开关
local filterSwitch = false

--- 初始化
function PlayerCam:Init()
    print("[PlayerCam] Init()")
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

    -- 迷宫中的相机
    this.mazeCam = localPlayer.Local.Independent.MazeCam

    this.chairCam = localPlayer.Local.Independent.ChairCam
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
        this.curCamera.CameraMode == Enum.CameraMode.Custom
end

-- 滑屏转向
function PlayerCam:CameraMove(touchInfo)
    if #touchInfo == 1 then
        if this:IsFreeMode() then
            this.curCamera:CameraMove(touchInfo[1].DeltaPosition)
        else
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
    local hitResult = Physics:RaycastAll(this.tpsCam.Position, this.tpsCam.Position + this.tpsCam.Forward * 100, true)
    for i, v in ipairs(hitResult:GetHitPosAll()) do --获取所有碰到的物体
        if
            (v - localPlayer.Position).Magnitude > 4 and
                Vector3.Angle(localPlayer.Forward, (v - localPlayer.Position)) < 90 and
                hitResult:GetHitObjAll()[i].Name ~= "water"
         then
            --print(hitResult:GetHitObjAll()[i])
            return v
        end
    end
    return this.tpsCam.Position + this.tpsCam.Forward * 100
end

---开关游泳滤镜
function PlayerCam:SwitchSwimFilter(_switch)
    filterSwitch = _switch
    if _switch then
        this.playerGameCam.WaterEffect:SetActive(true)
        this.playerGameCam.WaterVignette:SetActive(true)
        this.playerGameCam.WaterGaussionBlur:SetActive(true)
        this.playerGameCam.WaterAmbientOcclusion:SetActive(true)
        this.playerGameCam.WaterGrain:SetActive(true)
        this.playerGameCam.WaterColorGrading:SetActive(true)
    else
        this.playerGameCam.WaterEffect:SetActive(false)
        this.playerGameCam.WaterVignette:SetActive(false)
        this.playerGameCam.WaterGaussionBlur:SetActive(false)
        this.playerGameCam.WaterAmbientOcclusion:SetActive(false)
        this.playerGameCam.WaterGrain:SetActive(false)
        this.playerGameCam.WaterColorGrading:SetActive(false)
    end
end

---游泳滤镜检测
function PlayerCam:UpdateSwimFilter()
    if FsmMgr.playerActFsm.curState.stateName ~= "SwimIdle" and FsmMgr.playerActFsm.curState.stateName ~= "Swimming" then
        if filterSwitch == true then
            this:SwitchSwimFilter(false)
        end
    else
        if localPlayer.Position.y - this.playerGameCam.Forward.y < -16 then
            if filterSwitch == false then
                this:SwitchSwimFilter(true)
            end
        else
            if filterSwitch == true then
                this:SwitchSwimFilter(false)
            end
        end
    end
end

-- 修改玩家当前相机
function PlayerCam:SetCurCamEventHandler(_cam, _lookAt)
    this.curCamera = _cam or this.playerGameCam
    this.curCamera.LookAt = _lookAt or localPlayer
    world.CurrentCamera = this.curCamera
end

function PlayerCam:Update(dt)
    this:UpdateSwimFilter()
end

return PlayerCam
