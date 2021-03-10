--- 弓箭射击目标模块
--- @module ArrowTarget Module
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman.Yen Yuan
local ArrowTarget, this = ModuleUtil.New("ArrowTarget", ServerBase)

--- 变量声明
local arrowTargetOBJ = {}

local HitReactionFunc = {}

--飞行宝箱中心
local flyChestCenter = Vector3(-50.6899, 45.5741, 34.2672)
--飞行宝箱半径
local flyChestRad = 50

--- 初始化
function ArrowTarget:Init()
    print("[ArrowTarget] Init()")
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--- 节点引用
function ArrowTarget:NodeRef()
    for k, v in pairs(world.ArrowTarget:GetChildren()) do
        arrowTargetOBJ[v.ArrowTargetID.Value] = arrowTargetOBJ[v.ArrowTargetID.Value] or {}
        arrowTargetOBJ[v.ArrowTargetID.Value][#arrowTargetOBJ[v.ArrowTargetID.Value] + 1] = {
            obj = v,
            resetTime = Config.ArrowTarget[v.ArrowTargetID.Value].ResetTime,
            resetCD = Config.ArrowTarget[v.ArrowTargetID.Value].ResetTime
        }
    end
end

--- 数据变量初始化
function ArrowTarget:DataInit()
    for i = 1, 3 do
        HitReactionFunc[i] = function(_target)
            this["HitReaction" .. i](self, _target)
        end
    end
end

--- 节点事件绑定
function ArrowTarget:EventBind()
    for k1, v1 in pairs(arrowTargetOBJ) do
        for k2, v2 in pairs(v1) do
            v2.obj.ArrowTargetEvent:Connect(
                function(_pos)
                    this:HitTarget(_pos, v2)
                end
            )
        end
    end
end

--- 被击中
function ArrowTarget:HitTarget(_pos, _target)
    local config = Config.ArrowTarget[_target.obj.ArrowTargetID.Value]
    local effect = world:CreateInstance(config.HitEffect, config.HitEffect, world, _pos)
    HitReactionFunc[_target.obj.ArrowTargetID.Value](_target)
    NetUtil.Fire_S("SpawnCoinEvent", "P", _pos, config.RewardCoin)
    invoke(
        function()
            effect:Destroy()
        end,
        1.5
    )
end

--- 击中效果
function ArrowTarget:HitReaction1(_target)
    _target.obj.ArrowTargetCol:SetActive(false)
    local objTweener =
        Tween:TweenProperty(
        _target.obj,
        {Rotation = EulerDegree(90, _target.obj.Rotation.y, _target.obj.Rotation.z)},
        1,
        Enum.EaseCurve.Linear
    )
    objTweener:Play()
    objTweener.OnComplete:Connect(
        function()
            _target.obj.ArrowTargetCol:SetActive(true)
            _target.obj:SetActive(false)
            _target.obj.Rotation = EulerDegree(0, _target.obj.Rotation.y, _target.obj.Rotation.z)
            _target.resetCD = 0
            objTweener:Destroy()
        end
    )
end

function ArrowTarget:HitReaction2(_target)
    _target.obj:SetActive(false)
    ScenesInteract:InstanceInteractOBJ(59, _target.obj.Position)
    _target.resetCD = 0
end

function ArrowTarget:HitReaction3(_target)
    _target.obj:SetActive(false)
    ScenesInteract:InstanceInteractOBJ(60, _target.obj.Position)
    _target.resetCD = 0
end

---宝箱飞行
function ArrowTarget:FlyChestMove()
    for k, v in pairs(arrowTargetOBJ[3]) do
        if (v.obj.Position - flyChestCenter).Magnitude > flyChestRad then
            v.obj.LinearVelocity =
                ((flyChestCenter - v.obj.Position).Normalized +
                Vector3(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50)) / 100).Normalized *
                math.random(10, 25) /
                10
        end
    end
end

--- 重置目标
function ArrowTarget:ResetTarget(dt)
    for k1, v1 in pairs(arrowTargetOBJ) do
        for k2, v2 in pairs(v1) do
            if v2.obj.ActiveSelf == false and v2.resetTime > 0 then
                if v2.resetCD < v2.resetTime then
                    v2.resetCD = v2.resetCD + dt
                else
                    v2.obj:SetActive(true)
                end
            end
        end
    end
end

function ArrowTarget:Update(dt)
    this:ResetTarget(dt)
    this:FlyChestMove()
end

return ArrowTarget
