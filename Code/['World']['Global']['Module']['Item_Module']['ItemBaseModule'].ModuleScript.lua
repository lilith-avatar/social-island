--- 物品基类
-- @module ItemBase
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
local ItemBase = class("ItemBase")

function ItemBase:initialize(_data, _config)
    print("ItemBase:initialize()")
    self.id = _data.ItemID
    self.useCD = _data.UseCD
    self.useCT = _data.UseCD
    self.useSoundID = _data.UseSoundID
    self.useAnimName = _data.useAnimName
    self.isUsable = true
    self.isEquipable = false
    self.config = _config
end

--放入背包
function ItemBase:PutIntoBag()
    GuiControl:InsertInfoEventHandler('获得' ..LanguageUtil.GetText(Config.Item[self.id].Name), 2, false)
end

--从背包里扔掉
function ItemBase:ThrowOutOfBag()
    GuiControl:InsertInfoEventHandler('失去' ..LanguageUtil.GetText(Config.Item[self.id].Name), 2, false)
end

--销毁
function ItemBase:DestroyItem()
end

--使用
function ItemBase:Use()
    self.useCT = self.useCD
    self:PlayUseSound()
end

--装备
function ItemBase:Equip()
end

--取下装备
function ItemBase:Unequip()
end

--播放使用音效
function ItemBase:PlayUseSound()
    NetUtil.Fire_C("PlayEffectEvent", localPlayer, self.useSoundID)
end

--播放使用动作
function ItemBase:PlayUseAnim()
    localPlayer.Avatar:PlayAnimation(self.useAnimName, 4, 1, 0.1, false, false, 1)
end

--CD消退
function ItemBase:CDRun(dt)
    if self.useCT > 0 then
        self.useCT = self.useCT - dt
    elseif self.useCT < 0 then
        self.useCT = 0
    end
end

return ItemBase
