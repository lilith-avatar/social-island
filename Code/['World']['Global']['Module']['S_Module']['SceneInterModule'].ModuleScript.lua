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
            --表现
        end)
    end
end

return SceneInter