--- 人间大炮交互模块
--- @module Cannon Module
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local Cannon, this = ModuleUtil.New("Cannon", ServerBase)

--- 变量声明
-- 炮筒
local barrel = {}

--- 初始化
function Cannon:Init()
    print("[Cannon] Init()")
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--- 节点引用
function Cannon:NodeRef()
    for i = 1, 3 do
        barrel[i] = {
            obj = world.MiniGames.Game_04_Cannon["Barrel" .. i],
            cam = world.MiniGames.Game_04_Cannon["Barrel" .. i].Cam.Camera,
            closePlayer = nil,
            insidePlayer = nil,
            cannonDir = {
                Up = 0,
                Right = 0,
                Range = 5
            },
            cannonDefRot = world.MiniGames.Game_04_Cannon["Barrel" .. i].Rotation,
            spinTweener = nil
        }
    end
end

--- 数据变量初始化
function Cannon:DataInit()
end

--- 节点事件绑定
function Cannon:EventBind()
    for k, v in pairs(barrel) do
        v.obj.Base.OnCollisionBegin:Connect(
            function(_hitObject)
                if _hitObject.ClassName == "PlayerInstance" then
                    if v.closePlayer == nil and v.insidePlayer == nil then
                        v.closePlayer = _hitObject
                        NetUtil.Fire_C("OpenDynamicEvent", _hitObject, "Interact", 4)
                    end
                end
            end
        )
        v.obj.Base.OnCollisionEnd:Connect(
            function(_hitObject)
                if _hitObject.ClassName == "PlayerInstance" then
                    NetUtil.Fire_C("ResetDefUIEvent", _hitObject)
                end
            end
        )
    end
end

--- 进入人间大炮
function Cannon:GetOnCannon(_player)
    for k, v in pairs(barrel) do
        if v.closePlayer == _player then
            v.closePlayer = nil
            v.insidePlayer = _player
            _player.Position = v.obj.InsidePoint.Position
            NetUtil.Fire_C("ChangeMiniGameUIEvent", _player, 4)
            NetUtil.Fire_C("SetCurCamEvent", _player, v.cam)
            NetUtil.Fire_C("InsertInfoEvent", _player, "点击发射按钮射出", 5, true)
        end
    end
end

function Cannon:InteractSEventHandler(_player, _id)
    if _id == 4 then
        this:GetOnCannon(_player)
    end
end

--- 大炮发射
function Cannon:CannonFireEventHandler(_player, _force)
    for k, v in pairs(barrel) do
        if v.insidePlayer == _player then
            v.insidePlayer.Rotation = v.obj.Rotation
            v.insidePlayer.Position = v.insidePlayer.Position + Vector3(0, 0.5, 0)
            v.insidePlayer.LinearVelocity =
                (v.obj.OutsidePoint.Position - v.obj.InsidePoint.Position).Normalized * (10 + 60 * _force)
            NetUtil.Fire_C("ChangeMiniGameUIEvent", v.insidePlayer)
            NetUtil.Fire_C("SetCurCamEvent", v.insidePlayer)
            NetUtil.Fire_C("FsmTriggerEvent", v.insidePlayer, "Fly")
            invoke(
                function()
                    v.insidePlayer = nil
                end,
                1
            )
        end
    end
end

--- 大炮方向调整
function Cannon:SetCannonDirEventHandler(_player, _dir)
    for k, v in pairs(barrel) do
        if v.insidePlayer == _player then
            if _dir == "Up" then
                if v.cannonDir.Up < v.cannonDir.Range then
                    v.cannonDir.Up = v.cannonDir.Up + 1
                end
            elseif _dir == "Down" then
                if v.cannonDir.Up > -1 * v.cannonDir.Range then
                    v.cannonDir.Up = v.cannonDir.Up - 1
                end
            elseif _dir == "Right" then
                if v.cannonDir.Right < v.cannonDir.Range then
                    v.cannonDir.Right = v.cannonDir.Right + 1
                end
            elseif _dir == "Left" then
                if v.cannonDir.Right > -1 * v.cannonDir.Range then
                    v.cannonDir.Right = v.cannonDir.Right - 1
                end
            end
            this:PlaySpinTween(v)
        end
    end
end

--- 大炮旋转tween动画
function Cannon:PlaySpinTween(_barrel)
    if _barrel.spinTweener then
        _barrel.spinTweener:Destroy()
    end
    local dirRot = _barrel.cannonDefRot + EulerDegree(-6 * _barrel.cannonDir.Up, 15 * _barrel.cannonDir.Right, 0)
    _barrel.spinTweener = Tween:TweenProperty(_barrel.obj, {Rotation = dirRot}, 1, Enum.EaseCurve.Linear)
    _barrel.spinTweener:Play()
end

--- 离开人间大炮
function Cannon:LeaveCannonEventHandler(_player)
end

function Cannon:Update(dt)
    for k, v in pairs(barrel) do
        v.cam.Rotation = EulerDegree(v.cam.Rotation.x, v.obj.Rotation.y, v.cam.Rotation.z)
    end
end

return Cannon
