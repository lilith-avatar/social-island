--- 服装道具类
---@module ClothingItem:ItemBase
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
local ClothingItem = class('ClothingItem', ItemBase)

function ClothingItem:initialize(_baseData, _derivedData)
    ItemBase.initialize(self, _baseData, _derivedData)
    print('ClothingItem:initialize()')
end

--在背包中使用
function ClothingItem:UseInBag()
    print('使用', self.id)
    ItemBase.UseInBag(self)
    NetUtil.Fire_C('GetBuffEvent', localPlayer, self.derivedData.UseAddBuffID, self.derivedData.UseAddBuffDur)
    NetUtil.Fire_C('RemoveBuffEvent', localPlayer, self.derivedData.UseRemoveBuffID)
    NetUtil.Fire_C('PlayerSkinUpdateEvent', localPlayer, self.derivedData.SkinID)
end

return ClothingItem
