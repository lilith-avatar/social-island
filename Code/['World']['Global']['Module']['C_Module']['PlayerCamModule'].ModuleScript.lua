--- 角色镜头模块
--- @module Player Cam Module
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local PlayerCam, this = ModuleUtil.New("PlayerCam", ClientBase)

-- 触屏的手指数
local touchNumber = 0

--- 初始化
function PlayerCam:Init()
    print("PlayerCam:Init")
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
    return (this.playerGameCam.CameraMode == Enum.CameraMode.Social and this.playerGameCam.Distance >= 0) or
        this.playerGameCam.CameraMode == Enum.CameraMode.Orbital or
        this.playerGameCam.CameraMode == Enum.CameraMode.Custom
end

-- 检测触屏的手指数
function PlayerCam:CountTouch(container)
    touchNumber = #container
end

-- 滑屏转向
function PlayerCam:CameraMove(_pos, _dis, _deltapos, _speed)
    if touchNumber == 1 then
        if this:IsFreeMode() then
            this.playerGameCam:CameraMove(_deltapos)
        else
            localPlayer:RotateAround(localPlayer.Position, Vector3.Up, _deltapos.x)
            this.playerGameCam:CameraMove(Vector2(0, _deltapos.y))
        end
    end
end

-- 双指缩放摄像机距离
function PlayerCam:CameraZoom(_pos1, _pos2, _dis, _speed)
    if this.playerGameCam.CameraMode == Enum.CameraMode.Social then
        this.playerGameCam.Distance = this.playerGameCam.Distance - _dis / 50
    end
end

-- 修改玩家当前相机
function PlayerCam:SetCurCamEventHandler(_cam)
    this.curCamera = _cam or this.playerGameCam
    world.CurrentCamera = this.curCamera
end

function PlayerCam:Update(dt)
end

return PlayerCam
