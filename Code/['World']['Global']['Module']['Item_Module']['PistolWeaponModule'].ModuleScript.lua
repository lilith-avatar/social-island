--- 远程武器类
-- @module PistolWeapon
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
local PistolWeapon = class("PistolWeapon", WeaponBase)

function PistolWeapon:initialize(_data, _derivedData)
    WeaponBase.initialize(self, _data, _derivedData)
    print("PistolWeapon:initialize()")
    self.isFire = false
    self.projectileConfig = Config.Projectile[self.derivedData.ProjectileID]
    self.fireDT = 0
end

--拿在手中使用
function PistolWeapon:UseInHand()
    self:StartFire()
end

--装备
function PistolWeapon:Equip()
    WeaponBase.Equip(self)
    GuiPistolAim.gui:SetActive(true)
    GuiPistolAim.touchGui:SetActive(true)
end

--取下装备
function PistolWeapon:Unequip()
    WeaponBase.Unequip(self)
    GuiPistolAim.gui:SetActive(false)
    GuiPistolAim.touchGui:SetActive(false)
end

--开始开火
function PistolWeapon:StartFire()
    self.isFire = true
    self.fireDT = 0
    NetUtil.Fire_C("FsmTriggerEvent", localPlayer, "PistolAttack")
end

--结束开火
function PistolWeapon:EndFire()
    self.isFire = false
    self.fireDT = 0
    NetUtil.Fire_C("FsmTriggerEvent", localPlayer, "PistolIdle")
end

--开火
function PistolWeapon:Fire(dt)
    if self.isFire then
        if self.fireDT < self.derivedData.FireRate then
            self.fireDT = self.fireDT + dt
        else
            self.fireDT = 0
            self:ShootBullet()
        end
    end
end

--发射子弹
function PistolWeapon:ShootBullet()
    localPlayer.Avatar:PlayAnimation("PistolAttack", 8, 1, 0.1, true, false, 1)
    print("发射子弹")
    local endPos = PlayerCam:TPSGetRayDir()
    local bullet =
        Projectile:CreateAvailableProjectile(
        self.derivedData.ProjectileID,
        localPlayer.Position + localPlayer.Forward + Vector3(0, 1, 0),
        localPlayer.Rotation,
        endPos,
        self.derivedData.ProjectileSpeed
    )
    NetUtil.Fire_C("PlayEffectEvent", localPlayer, self.baseData.ShootSoundID)
    invoke(
        function()
            wait(3)
            if bullet then
                bullet.OnCollisionBegin:Clear()
                bullet:Destroy()
            end
        end,
        .1
    )
end

function PistolWeapon:Update(dt)
    self:Fire(dt)
end

return PistolWeapon
