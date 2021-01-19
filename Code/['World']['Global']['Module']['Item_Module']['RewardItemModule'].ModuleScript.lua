--- 奖励型道具类
-- @module RewardItem
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
local RewardItem = class("RewardItem", ItemBase)

function RewardItem:initialize(_data, _config)
    ItemBase.initialize(self, _data, _config)
    print("RewardItem:initialize()")
    self.isUsable = true
    self.isEquipable = false
end

--放入背包
function RewardItem:PutIntoBag()
end

--从背包里扔掉
function RewardItem:ThrowOutOfBag()
end

--使用
function RewardItem:Use()
    if self.useCT == 0 then   
        ItemBase.Use(self)
        self:GetReward()
        self:DestroyItem()
    end
end

--获取奖励
function RewardItem:GetReward()
end

--CD消退
function RewardItem:CDRun(dt)
    ItemBase.CDRun(self, dt)
end

return RewardItem
