---  物品管理模块：
-- @module  ItemMgr
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
---@module ItemMgr

local ItemMgr, this = ModuleUtil.New("ItemMgr", ClientBase)

local instantiateItemFunc = {}

local itemObjList = {}

function ItemMgr:Init()
    print("ItemMgr:Init")
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--节点引用
function ItemMgr:NodeRef()
end

--数据变量声明
function ItemMgr:DataInit()
    this.weaponList = {}
    this.usableItemList = {}
    this.placeableItemList = {}
    this.rewardItemList = {}
    this.taskItemList = {}
    invoke(
        function()
            ItemMgr:CreateItemObj(5001, Vector3(-83.8917, -5.5198, -15.8766))

            --this:Get5(5001)
        end
    )
end

--节点事件绑定
function ItemMgr:EventBind()
end

--实例化近战武器
function ItemMgr:Instantiate1(_id)
    return MeleeWeapon:new(Config.Item[_id], Config.MeleeWeapon[_id])
end

--实例化远程武器
function ItemMgr:Instantiate2(_id)
    return LongRangeWeapon:new(Config.Item[_id], Config.LongRangeWeapon[_id])
end

--实例化即时使用型道具
function ItemMgr:Instantiate3(_id)
    return UsableItem:new(Config.Item[_id], Config.UsableItem[_id])
end

--实例化放置型道具
function ItemMgr:Instantiate4(_id)
    return PlaceableItem:new(Config.Item[_id], Config.PlaceableItem[_id])
end

--实例化任务型道具
function ItemMgr:Instantiate5(_id)
    print("实例化任务型道具", _id)
    print(table.dump(Config.Item[_id]))
    return TaskItem:new(Config.Item[_id], Config.TaskItem[_id])
end

--实例化奖励型道具
function ItemMgr:Instantiate6(_id)
    return RewardItem:new(Config.Item[_id], Config.RewardItem[_id])
end

--实例化物品
function ItemMgr:InstantiateItem(_id)
    print("实例化物品", _id)
    return this["Instantiate" .. string.sub(tostring(_id), 1, 1)](self, _id)
end

--获得近战武器
function ItemMgr:Get1(_id)
    this.weaponList[_id] = this:InstantiateItem(_id)
    this.weaponList[_id]:PutIntoBag()
end

--获得远程武器
function ItemMgr:Get2(_id)
    this.weaponList[_id] = this:InstantiateItem(_id)
    this.weaponList[_id]:PutIntoBag()
end

--获得即时使用型道具
function ItemMgr:Get3(_id)
    this.usableItemList[_id] = this:InstantiateItem(_id)
    this.usableItemList[_id]:PutIntoBag()
end

--获得化放置型道具
function ItemMgr:Get4(_id)
    this.placeableItemList[_id] = this:InstantiateItem(_id)
    this.placeableItemList[_id]:PutIntoBag()
end

--获得任务道具
function ItemMgr:Get5(_id)
    this.taskItemList[_id] = this:InstantiateItem(_id)
    this.taskItemList[_id]:PutIntoBag()
end

--移除近战武器
function ItemMgr:Remove1(_id)
    this.weaponList[_id] = nil
    this.weaponList[_id]:ThrowOutOfBag()
end

--移除远程武器
function ItemMgr:Remove2(_id)
    this.weaponList[_id] = nil
    this.weaponList[_id]:ThrowOutOfBag()
end

--移除即时使用型道具
function ItemMgr:Remove3(_id)
    this.usableItemList[_id] = nil
    this.usableItemList[_id]:ThrowOutOfBag()
end

--移除化放置型道具
function ItemMgr:Remove4(_id)
    this.placeableItemList[_id] = nil
    this.placeableItemList[_id]:ThrowOutOfBag()
end

--移除任务道具
function ItemMgr:Remove5(_id)
    this.taskItemList[_id] = nil
    this.taskItemList[_id]:ThrowOutOfBag()
end

--获得道具
function ItemMgr:GetItem(_id)
    print("获得道具", _id)
    this["Get" .. string.sub(tostring(_id), 1, 1)](self, _id)
end

--移除道具
function ItemMgr:RemoveItem(_id)
    print("移除道具", _id)
    this["Remove" .. string.sub(tostring(_id), 1, 1)](self, _id)
end

--在地图上生成一个道具物体
function ItemMgr:CreateItemObj(_id, _pos)
    local item =
        world:CreateInstance("Item", "Item" .. _id .. "_" .. #itemObjList + 1, world.Item, _pos, EulerDegree(0, 0, 0))
    item.ID.Value = _id
    item.col.OnCollisionBegin:Connect(
        function(_hitObject)
            if _hitObject.ClassName == "PlayerInstance" then
                NetUtil.Fire_C("OpenDynamicEvent", localPlayer, "Pick", item)
            end
        end
    )
    itemObjList[#itemObjList + 1] = item
end

--检查是否有满足条件的任务道具
function ItemMgr:CheckTaskItem()
    for k, v in pairs(this.taskItemList) do
        v:ContactNPCTask()
    end
end

--执行任务反馈
function ItemMgr:GetTaskFeedback(_taskItemID)
    this.taskItemList[_taskItemID]:GetTaskReward()
    this:RemoveItem(_taskItemID)
end

function ItemMgr:Update(dt, tt)
end

return ItemMgr
