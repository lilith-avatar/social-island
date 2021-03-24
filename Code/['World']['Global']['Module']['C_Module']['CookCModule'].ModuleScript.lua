---@module CookC
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local CookC,this = ModuleUtil.New('CookC',ClientBase)

---初始化函数
function CookC:Init()
    this:DataInit()
    this:EventBind()
end

function CookC:DataInit()
end

---Update函数
function CookC:Update()
end

--根据食材处理最后做出的菜
function CookC:PlayerCookEventHandler(_materialList)
    -- for k,v in pairs() do
    -- end
end

return CookC