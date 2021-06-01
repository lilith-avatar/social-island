--- 消耗品类
-- @module ConsumableItem
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
local ConsumableItem = class('ConsumableItem', ItemBase)

function ConsumableItem:initialize(_baseData, _derivedData)
    ItemBase.initialize(self, _baseData, _derivedData)
    --print('ConsumableItem:initialize()')
end

--放入背包
function ConsumableItem:PutIntoBag()
    ItemBase.PutIntoBag(self)
end

--从背包里扔掉
function ConsumableItem:ThrowOutOfBag()
    ItemBase.ThrowOutOfBag(self)
end

--在背包中使用
function ConsumableItem:UseInBag()
    --print('使用', self.id)
    ItemBase.UseInBag(self)
    self:Equip()
end

--拿在手中使用
function ConsumableItem:UseInHand()
    ItemBase.UseInHand(self)
    NetUtil.Fire_C('FsmTriggerEvent', localPlayer, 'UseItem')
    localPlayer.Avatar:PlayAnimation(self.baseData.UseAniName, 8, 1, 0.2, true, false, 1)
    NetUtil.Fire_C('GetBuffEvent', localPlayer, self.derivedData.UseAddBuffID, self.derivedData.UseAddBuffDur)
    NetUtil.Fire_C('RemoveBuffEvent', localPlayer, self.derivedData.UseRemoveBuffID)
    invoke(
        function()
            localPlayer.Avatar:StopAnimation(self.baseData.UseAniName, 8)
            NetUtil.Fire_C('FsmTriggerEvent', localPlayer, 'Idle')
        end,
        self.baseData.UseTime
    )
    Data.Player.curEquipmentID = 0
    if self.derivedData.IsPutBack then
        self:Unequip()
    else
        self.equipObj:Destroy()
        NetUtil.Fire_C('FsmTriggerEvent', localPlayer, 'Idle')
        GuiControl:UpdateUseBtnIcon()
        GuiControl:UpdateTakeOffBtn()
    end
end

--装备
function ConsumableItem:Equip()
    ItemBase.Equip(self)
end

--取下装备
function ConsumableItem:Unequip()
    ItemBase.Unequip(self)
end

return ConsumableItem
