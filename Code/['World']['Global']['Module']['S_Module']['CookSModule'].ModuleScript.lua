---@module CookS
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local CookS, this = ModuleUtil.New("CookS", ServerBase)

---初始化函数
function CookS:Init()
    this:DataInit()
end

function CookS:DataInit()
    this.foodNum = #world.FoodLocation:GetChildren()
    this.curFoodNum = 0
    this.foodList = {}
    for i = 1, this.foodNum do
        this.foodList[i] = nil
    end
end

function CookS:FoodOnDeskEventHandler(_foodId, _player)
    if this.curFoodNum >= this.foodNum then
        return
    end
    this.curFoodNum = this.curFoodNum + 1
    this:PutFood(_foodId, _player)
    NetUtil.Broadcast("SycnDeskFoodNumEvent", this.curFoodNum, this.foodNum)
end

--桌上放菜
function CookS:PutFood(_foodId, _player)
    for i = 1, this.foodNum do
        if this.foodList[i] == nil then
            this.foodList[i] = {
                foodId = _foodId,
                cook = _player.UserId,
                index = i
            }
            -- 摆上食物
            --[[Config.CookMenu[_foodId].Model]]
            world:CreateInstance('Meal1','Food',world.FoodLocation['Location'..i],world.FoodLocation['Location'..i].Position)
            return
        end
    end
end

function CookS:OnPlayerJoinEventHandler(_player)
    NetUtil.Fire_C("SycnDeskFoodNumEvent", _player, this.curFoodNum, this.foodNum)
end

return CookS
