---@module SceneInter
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local SceneInter, this = ModuleUtil.New("SceneInter", ServerBase)
local folder = {
    Grass = world.Grass
    --Bush = nil,
    --Tree = nil,
    --Stone = nil,
    --Fish = nil
} --场景路径

---初始化函数
function SceneInter:Init()
    --this:CreateInterManager()
end

function SceneInter:CreateInterManager()
    for k, v in pairs(folder) do
        for _, n in pairs(v:GetDescendants()) do
            if not n:IsA("NodeObject") then
                n.OnCollisionBegin:Connect(
                    function(_hitObject)
                        this[k .. "Inter"](self, _hitObject, n)
                    end
                )
            end
        end
    end
end

function SceneInter:GrassInter(_hitObject, _object)
    if _hitObject.ClassName == "PlayerInstance" then
        local swayTweenerl = self:GrassSwayTween(_object, 20, 0.15)
        local swayTweener2 = self:GrassSwayTween(_object, -30, 0.3)
        local swayTweener3 = self:GrassSwayTween(_object, 0, 0.15)
        swayTweenerl.OnComplete:Connect(
            function()
                swayTweener2:Play()
                swayTweenerl:Destroy()
            end
        )
        swayTweener2.OnComplete:Connect(
            function()
                swayTweener3:Play()
                swayTweener2:Destroy()
            end
        )
        swayTweener3.OnComplete:Connect(
            function()
                swayTweener3:Destroy()
            end
        )

        swayTweenerl:Play()
    end
end

function SceneInter:GrassSwayTween(_obj, _property, _duration)
    return Tween:TweenProperty(
        _obj,
        {Rotation = EulerDegree(_obj.Rotation.x, _obj.Rotation.y, _obj.Rotation.z + _property)},
        _duration,
        Enum.EaseCurve.Linear
    )
end

return SceneInter
