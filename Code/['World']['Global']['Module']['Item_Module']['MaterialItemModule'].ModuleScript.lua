--- 材料道具类
-- @module MaterialItem
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
local MaterialItem = class("MaterialItem", ItemBase)

function MaterialItem:initialize(_baseData, _derivedData)
    ItemBase.initialize(self, _baseData, _derivedData)
    print("MaterialItem:initialize()")
end

--在背包中使用
function MaterialItem:UseInBag()
    print("使用", self.id)
    ItemBase.UseInBag(self)
    NetUtil.Fire_C("UpdateCoinEvent", localPlayer, self.baseData.GetCoin, true)
end

return MaterialItem
