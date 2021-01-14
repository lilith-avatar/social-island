---@module SceneInter
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local SceneInter,this = ModuleUtil.New('SceneInter',ServerBase)
local folder = nil -- 或者路径

---初始化函数
function SceneInter:Init()
    --this:CreateInterManager()
end

function SceneInter:CreateInterManager()
    for k,v in pairs(folder:GetChildren()) do
        v.OnCollisionBegin:Connect(function()
            this:GrassMove(v)
        end)
    end
end

function SceneInter:GrassMove(_obj)
    local tweener = Tween:ShakeProperty(_obj,{Rotation},0.15,8)
    tweener:Play()
end

return SceneInter