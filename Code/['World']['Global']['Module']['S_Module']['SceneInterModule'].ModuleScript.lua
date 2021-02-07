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
        print(_hitObject.ClassName)
        local tweener = Tween:ShakeProperty(_Object, {"Rotation"}, 0.15, 8)
        tweener:Play()
        tweener:WaitForComplete()
        tweener = nil
    end
end

return SceneInter