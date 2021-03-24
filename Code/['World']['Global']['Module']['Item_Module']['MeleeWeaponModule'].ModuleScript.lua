--- 近战武器类
-- @module MeleeWeapon
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
local MeleeWeapon = class("MeleeWeapon", WeaponBase)

function MeleeWeapon:initialize(_data, _config)
    WeaponBase.initialize(self, _data, _config)
    print("MeleeWeapon:initialize()")
end

--攻击
function MeleeWeapon:Attack()
    WeaponBase.Attack(self)
end

function MeleeWeapon:Equip()
    WeaponBase.Equip(self)
end

return MeleeWeapon
