---@module CookC
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local CookC, this = ModuleUtil.New("CookC", ClientBase)

---初始化函数
function CookC:Init()
    this:DataInit()
    this:EventBind()
end

function CookC:DataInit()
end

--根据食材处理最后做出的菜
function CookC:PlayerCookEventHandler(_materialList)
    for k, v in pairs() do
        if this:JudgeMaterialInMenu(_materialList, v) then
            NetUtil.Fire_C("", localPlayer, v.ID)
        end
    end
end

function CookC:JudgeMaterialInMenu(_materialList, _menu)
    for k, v in pairs(_materialList) do
        if table.indexof(_menu, v, 1) == 0 then
            return false
        end
    end
    return true
end

function CookC:EventBind()
end

return CookC
