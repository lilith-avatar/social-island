---  物品管理模块：
-- @module  ItemMgr
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
---@module ItemMgr

local ItemMgr, this = ModuleUtil.New('ItemMgr', ClientBase)

local coin = 0

function ItemMgr:Init()
    print('[ItemMgr] ItemMgr:Init')
    this:NodeRef()
    this:DataInit()
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
end

--  初始化默认背包数据
function ItemMgr:InitBagData()
    print('[ItemMgr] 初始化背包')
    local defaultItems = {
        5001,
        5002,
        5003,
        5004,
        5005,
        5006
    }
    for _, v in pairs(defaultItems) do
        NetUtil.Fire_C('GetItemEvent', localPlayer, v)
    end
end

--新建背包数据
function ItemMgr:NewBagData(_id)
    local tempBag = {
        id = _id,
        type = string.sub(tostring(_id), 1, 1),
        count = 0,
        lastestTime = 0,
        isNew = true,
        isConst = tonumber(string.sub(tostring(_id), 1, 1)) < 6
    }
    Data.Player.bag[_id] = tempBag
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
    -- 初始化默认背包数据
    if Data.Player.bag[_id] == nil then
        print('[ItemMgr] 新建道具', _id)
        this:NewBagData(_id)
    end

    if tonumber(string.sub(tostring(_id), 1, 1)) < 6 and Data.Player.bag[_id].count > 0 then
        print('[ItemMgr] 已有道具', _id)
        return
    end
    Data.Player.bag[_id].count = Data.Player.bag[_id].count + 1
    this.itemInstance[_id]:PutIntoBag()
    GuiNoticeInfo:ShowGetItem(_id)
    print('[ItemMgr] 获得道具', _id)
    return
end

--移除道具
function ItemMgr:RemoveItemEventHandler(_id)
    print('[ItemMgr] 移除道具', _id)
    Data.Player.bag[_id].count = Data.Player.bag[_id].count - 1
    this.itemInstance[_id]:ThrowOutOfBag()
end

--使用道具
function ItemMgr:UseItemEventHandler(_id)
    print('[ItemMgr] 使用道具', _id)
    this.itemInstance[_id]:Use()
end

--解除当前武器
function ItemMgr:UnequipCurWeaponEventHandler()
    if this.curWeaponID ~= 0 then
        this.itemInstance[this.curWeaponID]:Unequip()
    end
end

--交互掉落道具
function ItemMgr:GetItemFromPoolEventHandler(_poolID, _coin)
    if _poolID ~= 0 then
        local weightSum = 0
        for k, v in pairs(Config.ItemPool[_poolID]) do
            weightSum = weightSum + v.Weight
        end
        local randomNum = math.random(weightSum)
        for k, v in pairs(Config.ItemPool[_poolID]) do
            if randomNum < v.Weight then
                if Data.Player.bag[v.ItemId] then
                    if tonumber(string.sub(tostring(v.ItemId), 1, 1)) >= 6 then
                        Data.Player.bag[v.ItemId].count = Data.Player.bag[v.ItemId].count + 1
                        this.itemInstance[v.ItemId]:PutIntoBag()
                    else
                        NetUtil.Fire_C('GetItemFromPoolEvent', localPlayer, _poolID, 0)
                    end
                else
                    NetUtil.Fire_C('GetItemEvent', localPlayer, v.ItemId)
                end
                break
            end
        end
    end
    if _coin and _coin ~= 0 then
        NetUtil.Fire_C('UpdateCoinEvent', localPlayer, _coin)
    end
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

--- 长期存储成功读取后
function ItemMgr:LoadPlayerDataSuccessEventHandler()
    print('[ItemMgr] 读取长期存储成功')
    this:InitBagData()
end

return ItemMgr
