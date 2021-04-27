--- 任务型道具类
-- @module TaskItem
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
local TaskItem = class('TaskItem', ItemBase)

function TaskItem:initialize(_baseData, _derivedData)
    ItemBase.initialize(self, _baseData, _derivedData)
    print('TaskItem:initialize()')
end

--放入背包
function TaskItem:PutIntoBag()
    ItemBase.PutIntoBag(self)
end

--从背包里扔掉
function TaskItem:ThrowOutOfBag()
    ItemBase.ThrowOutOfBag(self)
end

--获得任务奖励
function TaskItem:GetTaskReward()
    if self.derivedData.RewardItem and self.derivedData.RewardItem ~= 0 then
        NetUtil.Fire_C('GetItemEvent', localPlayer, self.derivedData.RewardItem)
    end
    NetUtil.Fire_C('UpdateCoinEvent', localPlayer, self.derivedData.RewardGold, false, 6)
    NetUtil.Fire_C('RemoveItemEvent', localPlayer, self.baseData.ItemID)
end

--CD消退
function TaskItem:CDRun(dt)
    ItemBase.CDRun(self, dt)
end

return TaskItem
