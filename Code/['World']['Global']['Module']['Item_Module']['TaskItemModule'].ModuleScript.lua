--- 任务型道具类
-- @module TaskItem
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
local TaskItem = class("TaskItem", ItemBase)

function TaskItem:initialize(_data, _config)
    ItemBase.initialize(self, _data, _config)
    print("TaskItem:initialize()")
    self.isUsable = false
    self.isEquipable = false
end

--放入背包
function TaskItem:PutIntoBag()
    GuiControl:ShowInfo("获得" .. Config.Item[self.id].Name, 1)
end

--从背包里扔掉
function TaskItem:ThrowOutOfBag()
end

--使用
function TaskItem:Use()
    if self.useCT == 0 then
        ItemBase.Use(self)
    end
end

--获得任务奖励
function TaskItem:GetTaskReward()
    if self.config.RewardItem then
        ItemMgr:GetTaskItem(self.config.RewardItem)
    end
end

--触发NPC任务
function TaskItem:ContactNPCTask()
    for k, v in pairs(self.config.Npc) do
        GuiNpc:ContactTask(v, self.id, self:GetNPCText())
    end
end

--获取NPC对话文本
function TaskItem:GetNPCText()
    return self.config.NpcText
end

--CD消退
function TaskItem:CDRun(dt)
    ItemBase.CDRun(self, dt)
end

return TaskItem
