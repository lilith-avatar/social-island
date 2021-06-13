--- 武器基类
-- @module WeaponBase
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
local WeaponBase = class('WeaponBase', ItemBase)

function WeaponBase:initialize(_baseData, _derivedData)
    ItemBase.initialize(self, _baseData, _derivedData)
    --print("WeaponBase:initialize()")
    self.useCT = self.baseData.UseCD
end

--放入背包
function WeaponBase:PutIntoBag()
    ItemBase.PutIntoBag(self)
end

--从背包里扔掉
function WeaponBase:ThrowOutOfBag()
    ItemBase.ThrowOutOfBag(self)
end

--在背包中使用
function WeaponBase:UseInBag()
    --print("使用", self.id)
    ItemBase.UseInBag(self)
    self:Equip()
end

--拿在手中使用
function WeaponBase:UseInHand()
    if self.useCT == 0 then
        ItemBase.UseInHand(self)
        self:Attack()
    end
end

--装备
function WeaponBase:Equip()
    ItemBase.Equip(self)
end

--取下装备
function WeaponBase:Unequip()
    ItemBase.Unequip(self)
    self.useCT = 0
    GuiControl:UpdateUseBtnMask(0)
end

--攻击
function WeaponBase:Attack()
    PlayerAnimMgr:CreateSingleClipNode(self.baseData.UseAniName, 1, 'WeaponAttack', 1)
    PlayerAnimMgr:Play('WeaponAttack', 1, 1, 0.2, 0.2, true, false, 1)
    self.useCT = self.baseData.UseCD
    invoke(
        function()
            localPlayer.Avatar:StopBlendSpaceNode(1)
        end,
        self.baseData.UseTime
    )
end

--CD消退
function WeaponBase:CDRun(dt)
    if self.useCT > 0 then
        self.useCT = self.useCT - dt
    elseif self.useCT < 0 then
        self.useCT = 0
    end
    GuiControl:UpdateUseBtnMask(self.useCT / self.baseData.UseCD)
end

function WeaponBase:Update(dt)
    self:CDRun(dt)
end

return WeaponBase
