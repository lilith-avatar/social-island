--- 武器基类
-- @module PlaceableItem
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
local PlaceableItem = class("PlaceableItem", ItemBase)

function PlaceableItem:initialize(_data)
    ItemBase.initialize(self, _data)
    print("PlaceableItem:initialize()")
    self.isUsable = true
    self.isEquipable = false
end

--放入背包
function PlaceableItem:PutIntoBag()
end

--从背包里扔掉
function PlaceableItem:ThrowOutOfBag()
end

--使用
function PlaceableItem:Use()
    if self.useCT == 0 then
        ItemBase.Use(self)
    end
end

--CD消退
function PlaceableItem:CDRun(dt)
    ItemBase.CDRun(self, dt)
end

return PlaceableItem
