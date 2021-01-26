---@module SceneInter
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local SceneInter, this = ModuleUtil.New("SceneInter", ServerBase)
local folder = {
    Grass = nil,
    Bush = nil,
    Tree = nil,
    Stone = nil,
    Fish = nil
} --场景路径

---初始化函数
function SceneInter:Init()
    --this:CreateInterManager()
end

function SceneInter:CreateInterManager()
    for k, v in pairs(folder) do
        for _, n in pairs(v:GetChildren()) do
            n.OnCollisionBegin:Connect(
                function(_hitObject)
                    this[k .. "Inter"](_hitObject, n, self)
                end
            )
        end
    end
end

function SceneInter:GrassInter(_hitObject, _Object)
end

return SceneInter
