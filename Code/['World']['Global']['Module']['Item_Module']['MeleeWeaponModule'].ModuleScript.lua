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
    self.attackCT = self.config.AttackCD
    self:PlayAttackAnim()
end

function MeleeWeapon:Use()
    WeaponBase.Use(self)
end

--获取攻击数据
function MeleeWeapon:GetAttackData()
    return {
        healthChange = self.config.HealthChange,
        hitAddBuffID = self.config.HitAddBuffID,
        hitAddBuffDur = self.config.HitAddBuffDur,
        hitRemoveBuffID = self.config.HitRemoveBuffID
    }
end

return MeleeWeapon
