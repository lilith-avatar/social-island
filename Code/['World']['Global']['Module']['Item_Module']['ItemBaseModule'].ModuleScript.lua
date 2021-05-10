--- 物品基类
--- @module ItemBase
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
local ItemBase = class('ItemBase')

function ItemBase:initialize(_baseData, _derivedData)
    print('ItemBase:initialize()')
    self.baseData = _baseData
    self.typeConfig = Config.ItemType[_baseData.Type]
    self.derivedData = _derivedData
    self.equipObj = nil
end

--放入背包
function ItemBase:PutIntoBag()
    NetUtil.Fire_C('GetItemEvent', localPlayer, self.baseData.ItemID)
end

--从背包里扔掉
function ItemBase:ThrowOutOfBag()
    NetUtil.Fire_C('RemoveItemEvent', localPlayer, self.baseData.ItemID)
end

--在背包中使用
function ItemBase:UseInBag()
end

--拿在手中使用
function ItemBase:UseInHand()
    SoundUtil.Play3DSE(localPlayer.Position, self.baseData.UseSoundID)

    NetUtil.Fire_C('CUseItemEvent', localPlayer, self.baseData.ItemID)
    NetUtil.Fire_S('SUseItemEvent', localPlayer, self.baseData.ItemID)
end

--装备
function ItemBase:Equip()
    print('装备')
    NetUtil.Fire_C('UnequipCurEquipmentEvent', localPlayer)
    NetUtil.Fire_C('FsmTriggerEvent', localPlayer, 'TakeOutItem')
    wait(0.1)
    localPlayer.Avatar:PlayAnimation(self.baseData.TakeOutAniName, 8, 1, 0.2, true, false, 1)
    GuiControl:UpdateUseBtnIcon(self.baseData.UseBtnIcon)

    invoke(
        function()
            NetUtil.Fire_C('FsmTriggerEvent', localPlayer, self.typeConfig.FsmMode)

            SoundUtil.Play3DSE(localPlayer.Position, self.baseData.TakeOutSoundID)
            NetUtil.Fire_C('RemoveItemEvent', localPlayer, self.baseData.ItemID)
            Data.Player.curEquipmentID = self.baseData.ItemID

            NetUtil.Fire_C('CTakeOutItemEvent', localPlayer, self.baseData.ItemID)
            NetUtil.Fire_S('STakeOutItemEvent', localPlayer, self.baseData.ItemID)

            local node1, node2 = string.match(self.derivedData.ParentNode, '([%w_]+).([%w_]+)')
            --print(node1, node1)
            local pNode = localPlayer.Avatar[node1][node2]
            self.equipObj =
                world:CreateInstance(
                self.derivedData.ModelName,
                self.derivedData.ModelName .. 'Instance',
                pNode,
                pNode.Position + self.derivedData.Offset,
                pNode.Rotation + self.derivedData.Angle
            )
            self.equipObj.LocalPosition = self.derivedData.Offset
            self.equipObj.LocalRotation = self.derivedData.Angle

            GuiControl:UpdateTakeOffBtn()
        end,
        self.baseData.TakeOutTime
    )
end

--取下装备
function ItemBase:Unequip()
    Data.Player.curEquipmentID = 0
    local effect = world:CreateInstance('UnequipEffect', 'UnequipEffect', self.equipObj.Parent, self.equipObj.Position)
    invoke(
        function()
            self.equipObj:Destroy()
            wait(.3)
            effect:Destroy()
        end,
        0.2
    )
    NetUtil.Fire_C('FsmTriggerEvent', localPlayer, 'Idle')
    --wait(self.baseData.TakeOutTime)
    Data.Player.bag[self.baseData.ItemID].count = Data.Player.bag[self.baseData.ItemID].count + 1
    GuiControl:UpdateTakeOffBtn()
    GuiControl:UpdateUseBtnIcon()
end

function ItemBase:Update(dt)
end

return ItemBase
