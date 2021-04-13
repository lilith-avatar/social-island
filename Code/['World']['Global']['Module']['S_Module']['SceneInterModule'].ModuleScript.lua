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
end

function SceneInter:GrassInter(_hitObject, _object)
end

function SceneInter:GrassSwayTween(_obj, _property, _duration)
end

return SceneInter
