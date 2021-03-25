---@module CookC
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local CookC, this = ModuleUtil.New("CookC", ClientBase)

---初始化函数
function CookC:Init()
    this:DataInit()
end

function CookC:DataInit()
end

--根据食材处理最后做出的菜
function CookC:PlayerCookEventHandler(_materialList)
    for k, v in pairs(Config.CookMenu) do
        if this:JudgeMaterialInMenu(_materialList, v.Menu) then
            NetUtil.Fire_C("GetFinalFoodEvent", localPlayer, v.Id)
        else
            NetUtil.Fire_C("GetFinalFoodEvent", localPlayer, 5)
        end
    end
end

function CookC:JudgeMaterialInMenu(_materialList, _menu)
    for k, v in pairs(_materialList) do
        if table.indexof(_menu, v.id, 1) == 0 then
            return false
        end
    end
    return true
end

return CookC
