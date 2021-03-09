--- 任务型道具类
-- @module TaskItem
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
local TaskItem = class('TaskItem', ItemBase)

function TaskItem:initialize(_data, _config)
    ItemBase.initialize(self, _data, _config)
    print('TaskItem:initialize()')
    self.isUsable = false
    self.isEquipable = false
end

--放入背包
function TaskItem:PutIntoBag()
    ItemBase.PutIntoBag(self)
    GuiControl:InsertInfoEventHandler(LanguageUtil.GetText(Config.Item[self.id].Des), 3, true)
end

--从背包里扔掉
function TaskItem:ThrowOutOfBag()
	ItemBase.ThrowOutOfBag(self)
end

--使用
function TaskItem:Use()
    if self.useCT == 0 then
        ItemBase.Use(self)
    end
end

--获得任务奖励
function TaskItem:GetTaskReward()
    if self.config.RewardItem and self.config.RewardItem ~= 0 then
        NetUtil.Fire_C('GetItemEvent', localPlayer, self.config.RewardItem)
    end
    NetUtil.Fire_C("UpdateCoinEvent",localPlayer,self.config.RewardGold)
    NetUtil.Fire_C('RemoveItemEvent', localPlayer, self.id)
end

--CD消退
function TaskItem:CDRun(dt)
    ItemBase.CDRun(self, dt)
end

return TaskItem
