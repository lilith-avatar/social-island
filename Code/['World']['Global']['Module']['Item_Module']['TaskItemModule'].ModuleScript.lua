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
