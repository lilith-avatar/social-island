---  物品管理模块：
-- @module  ItemMgr
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
---@module ItemMgr

local ItemMgr, this = ModuleUtil.New("ItemMgr", ClientBase)

local itemObjList = {}

local coin = 0

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
			this:Get5(5001)
			
            ItemMgr:CreateItemObj(5022, Vector3(-39.4065, -11.6012, -0.4372))
			ItemMgr:CreateItemObj(5023, Vector3(-20.9087, -14.2145, -1.6095))
			ItemMgr:CreateItemObj(5022, Vector3(-103.577, -9.1927, 2.7578))
			ItemMgr:CreateItemObj(5022, Vector3(-86.3498, -9.1927, -11.2409))
			ItemMgr:CreateItemObj(5017, Vector3(-84.8463, -9.4947, 0.2409))
			ItemMgr:CreateItemObj(5017, Vector3(-60.9962, -13.4307, 27.1079))
			ItemMgr:CreateItemObj(5024, Vector3(-83.8917, -5.5198, -15.8766))
			ItemMgr:CreateItemObj(5018, Vector3(31.6175, -12.8839, 127.295))
			ItemMgr:CreateItemObj(5025, Vector3(106.888, -10.4713, 0.1005))
			ItemMgr:CreateItemObj(5026, Vector3(-150.064, -13.1113, 69.8964))
			ItemMgr:CreateItemObj(5027, Vector3(-158.677, -1.1168, 53.8572))
			ItemMgr:CreateItemObj(5027, Vector3(-158.677, -3.0511, 116.602))
			ItemMgr:CreateItemObj(5026, Vector3(-83.8917, -5.5198, -15.8766))
			ItemMgr:CreateItemObj(5028, Vector3(40.8512, -11.2896, 28.5415))
			ItemMgr:CreateItemObj(5019, Vector3(-62.5168, -6.5986, -59.9787))
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
    this.weaponList[_id]:ThrowOutOfBag()
    this.weaponList[_id] = nil
end

--移除远程武器
function ItemMgr:Remove2(_id)
    this.weaponList[_id]:ThrowOutOfBag()
    this.weaponList[_id] = nil
end

--移除即时使用型道具
function ItemMgr:Remove3(_id)
    this.usableItemList[_id]:ThrowOutOfBag()
    this.usableItemList[_id] = nil
end

--移除化放置型道具
function ItemMgr:Remove4(_id)
    this.placeableItemList[_id]:ThrowOutOfBag()
    this.placeableItemList[_id] = nil
end

--移除任务道具
function ItemMgr:Remove5(_id)
    this.taskItemList[_id]:ThrowOutOfBag()
    this.taskItemList[_id] = nil
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
    local item = this.taskItemList[_taskItemID]
    this:RemoveItem(_taskItemID)
    item:GetTaskReward()
end

---服务器结算处理
function ItemMgr:GetCoinEventHandler(_CoinNum,_itemId)
	this:GetCoin(_CoinNum)
	this:Get5(_itemId)
end

--获得金币
function ItemMgr:GetCoin(_num)
    if _num and _num > 0 then
        coin = coin + _num
        localPlayer.Local.CoinGui.CoinNum.Text = "金币：" .. coin
        localPlayer.Local.CoinGui.Info.Text = "获得" .. coin .. "金币"
        invoke(
            function()
                localPlayer.Local.CoinGui.Info.Text = ""
            end,
            1
        )
    end
end

function ItemMgr:Update(dt, tt)
end

return ItemMgr
