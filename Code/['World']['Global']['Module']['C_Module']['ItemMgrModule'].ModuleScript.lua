---  物品管理模块：
-- @module  ItemMgr
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
---@module ItemMgr

local ItemMgr, this = ModuleUtil.New('ItemMgr', ClientBase)

local coin = 0

function ItemMgr:Init()
    print('ItemMgr:Init')
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--节点引用
function ItemMgr:NodeRef()
end

--数据变量声明
function ItemMgr:DataInit()
    this.itemInstance = {}
    for k, v in pairs(Config.Item) do
        this.itemInstance[k] = this:InstantiateItem(k)
    end
    this.curWeaponID = 0

    this.curWeapon = nil
    invoke(
        function()
            this:InitBagData()
            wait(.5)
            NetUtil.Fire_C('GetItemEvent', localPlayer, 5001)
        end
    )
end

--节点事件绑定
function ItemMgr:EventBind()
end

--初始化背包数据
function ItemMgr:InitBagData()
    local tempBagData = {}
    for k, v in pairs(Config.Item) do
        tempBagData[k] = {
            id = k,
            type = string.sub(tostring(k), 1, 1),
            count = 0,
            lastestTime = 0,
            isNew = true,
            isConst = true
        }
    end
    Data.Player.bag = tempBagData
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
    return TaskItem:new(Config.Item[_id], Config.TaskItem[_id])
end

--实例化奖励型道具
function ItemMgr:Instantiate6(_id)
    return RewardItem:new(Config.Item[_id], Config.RewardItem[_id])
end

--实例化物品
function ItemMgr:InstantiateItem(_id)
    return this['Instantiate' .. string.sub(tostring(_id), 1, 1)](self, _id)
end

--兑换任务奖励
function ItemMgr:RedeemTaskItemReward(_id)
    this.itemInstance[_id]:GetTaskReward()
end

--获得道具
function ItemMgr:GetItemEventHandler(_id)
    print('获得道具', _id)
    Data.Player.bag[_id].count = Data.Player.bag[_id].count + 1
    this.itemInstance[_id]:PutIntoBag()
end

--移除道具
function ItemMgr:RemoveItemEventHandler(_id)
    print('移除道具', _id)
    Data.Player.bag[_id].count = Data.Player.bag[_id].count - 1
    this.itemInstance[_id]:ThrowOutOfBag()
end

--获取满足条件的任务道具
function ItemMgr:GetTaskItem(_npcID)
    local npcTable
    for k1, v1 in pairs(Data.Player.bag) do
        if string.sub(tostring(k1), 1, 1) == '5' and v1.count > 0 then
            npcTable = this.itemInstance[k1].config.Npc
            for k2, v2 in pairs(npcTable) do
                if v2 == _npcID then
                    return k1
                end
            end
        end
    end
    return 0
end

--获得NPC对话文本
function ItemMgr:GetNpcText(_id)
    return LanguageUtil.GetText(ItemMgr.itemInstance[_id].config.NpcText)
end

---服务器结算处理
function ItemMgr:GetCoinEventHandler(_CoinNum, _itemId)
    this:GetCoin(_CoinNum)
    this:Get5(_itemId)
end

function ItemMgr:Update(dt, tt)
end

return ItemMgr
