---@module SceneInter
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local SceneInter, this = ModuleUtil.New("SceneInter", ServerBase)
local folder = {
    Grass = world.Grass,
    --Bush = nil,
    --Tree = nil,
    --Stone = nil,
    --Fish = nil
} --场景路径

---初始化函数
function SceneInter:Init()
    this:CreateInterManager()
end

function SceneInter:CreateInterManager()
    for k, v in pairs(folder) do
        for m, n in pairs(v:GetDescendants()) do
            if not n:IsA("NodeObject") then
                n.OnCollisionBegin:Connect(
                    function(_hitObject)
                        this[k .. "Inter"](self,_hitObject, n)
                    end
                )
            end
        end
    end
end

function SceneInter:GrassInter(_hitObject, _Object)
    if _hitObject.ClassName == "PlayerInstance" then
		local swayTweenerl=Tween:TweenProperty(_Object,{Rotation=EulerDegree(_Object.Rotation.x,_Object.Rotation.y,_Object.Rotation.z + 20)},0.15,Enum.EaseCurve.Linear)
		local swayTweener2=Tween:TweenProperty(_Object,{Rotation=EulerDegree(_Object.Rotation.x,_Object.Rotation.y,_Object.Rotation.z - 30)},0.3,Enum.EaseCurve.Linear)
		local swayTweener3=Tween:TweenProperty(_Object,{Rotation=EulerDegree(_Object.Rotation.x,_Object.Rotation.y,_Object.Rotation.z)},0.15,Enum.EaseCurve.Linear)
		swayTweenerl.OnComplete:Connect(function()
		swayTweener2:Play()
		swayTweenerl:Destroy()
		end)
		swayTweener2.OnComplete:Connect(function()
		swayTweener3:Play()
		swayTweener2:Destroy()
		end)
		swayTweener3.OnComplete:Connect(function()
		swayTweener3:Destroy()
		end)
	
		swayTweenerl:Play()
    end
end

return SceneInter