---@module CookC
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local CookC, this = ModuleUtil.New('CookC', ClientBase)

---初始化函数
function CookC:Init()
    this:DataInit()
    this:EventBind()
end

function CookC:DataInit()
end

function CookC:EventBind()
    this.foodDestroyTime = localPlayer.Avatar:AddAnimationEvent('Drink', 0.3)
    this.foodDestroyTime:Connect(
        function()
            this:DestroyFood()
            NetUtil.Fire_C('ChangeMiniGameUIEvent', localPlayer)
        end
    )
end

--根据食材处理最后做出的菜
function CookC:PlayerCookEventHandler(_materialList)
    for k, v in pairs(Config.CookMenu) do
        if this:JudgeMaterialInMenu(_materialList, v.Menu) then
            NetUtil.Fire_C('GetFinalFoodEvent', localPlayer, v.Id)
            return
        end
    end
    NetUtil.Fire_C('GetFinalFoodEvent', localPlayer, 5)
	local foodList = {}
	for k,v in pairs(_materialList) do
		table.insert(foodList, v.id)
	end
	CloudLogUtil.UploadLog('cook', 'cook_main_confirm',{meal_id = 5,menu = foodList})
end

function CookC:JudgeMaterialInMenu(_materialList, _menu)
    for k, v in pairs(_materialList) do
        if table.indexof(_menu, v.id, 1) == 0 then
            return false
        end
    end
    return true
end

local foodModel
function CookC:EatFoodEventHandler(_foodId)
    foodModel =
        world:CreateInstance(Config.CookMenu[_foodId].Model, 'Food', localPlayer.Avatar.Bone_R_Hand.RHandWeaponNode)
    foodModel.LocalPosition = Vector3.Zero
    foodModel.LocalRotation = EulerDegree(3.0258, 12.924, -4.0823)
    localPlayer.Avatar:PlayAnimation('Drink', 2, 1, 0, true, false, 1)
end

function CookC:DestroyFood()
    if foodModel then
        foodModel:Destroy()
    end
end

return CookC
