--- 角色镜头模块
--- @module Player Cam Module
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local PlayerCam, this = ModuleUtil.New("PlayerCam", ClientBase)

-- 触屏的手指数
local touchNumber = 0

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

-- 检测触屏的手指数
function PlayerCam:CountTouch(container)
    touchNumber = #container
end

-- 滑屏转向
function PlayerCam:CameraMove(_pos, _dis, _deltapos, _speed)
    if touchNumber == 1 then
        if this:IsFreeMode() then
            this.curCamera:CameraMove(_deltapos)
        else
            localPlayer:RotateAround(localPlayer.Position, Vector3.Up, _deltapos.x)
            this.curCamera:CameraMove(Vector2(0, _deltapos.y))
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
    local hitResult = Physics:Raycast(this.tpsCam.Position, this.tpsCam.Forward * 50, true)
    if hitResult.Hitobject then
        return hitResult.Hitobject.Position
    else
        return this.tpsCam.Forward * 20
    end
end

-- 修改玩家当前相机
function PlayerCam:SetCurCamEventHandler(_cam, _lookAt)
    this.curCamera = _cam or this.playerGameCam
    this.curCamera.LookAt = _lookAt or localPlayer
    world.CurrentCamera = this.curCamera
end

return PlayerCam
