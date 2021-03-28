--- 远程武器类
-- @module BowWeapon
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
local BowWeapon = class('BowWeapon', WeaponBase)

function BowWeapon:initialize(_data, _derivedData)
    WeaponBase.initialize(self, _data, _derivedData)
    print('BowWeapon:initialize()')
    self.isCharge = false
    self.chargeForce = 0
    self.projectileConfig = Config.Projectile[self.derivedData.ProjectileID]
    self.chargeEffectObj = nil
    self.shootEffectObj = nil
end

--拿在手中使用
function BowWeapon:UseInHand()
    if self.useCT == 0 then
        self:StartCharge()
    end
end

--装备
function BowWeapon:Equip()
    WeaponBase.Equip(self)
    GuiBowAim.gui:SetActive(true)
    GuiBowAim.touchGui:SetActive(true)
    self.chargeEffectObj =
        world:CreateInstance(
        self.derivedData.ChargeEffect,
        self.derivedData.ChargeEffect .. 'Instance',
        self.equipObj.ChargeNode,
        self.equipObj.ChargeNode.Position
    )
    self.shootEffectObj =
        world:CreateInstance(
        self.derivedData.ShootEffect,
        self.derivedData.ShootEffect .. 'Instance',
        self.equipObj.ShootNode,
        self.equipObj.ShootNode.Position
    )
end

--取下装备
function BowWeapon:Unequip()
    WeaponBase.Unequip(self)
    GuiBowAim.gui:SetActive(false)
    GuiBowAim.touchGui:SetActive(false)
end

--攻击
function BowWeapon:Attack(_force)
    print('攻击')
    self.useCT = self.baseData.UseCD
    NetUtil.Fire_C('FsmTriggerEvent', localPlayer, 'BowAttack')
    self:ShootArrow(_force)
    self.equipObj.ChargeNode:SetActive(false)
    self.equipObj.ShootNode:SetActive(true)
    invoke(
        function()
            self.equipObj.ShootNode:SetActive(false)
        end,
        1
    )
end

--开始蓄力
function BowWeapon:StartCharge()
    self.isCharge = true
    NetUtil.Fire_C('FsmTriggerEvent', localPlayer, 'BowChargeIdle')
    self.equipObj.ChargeNode:SetActive(true)
end

--结束蓄力
function BowWeapon:EndCharge()
    self.isCharge = false
    self:Attack(self.chargeForce)
end

--蓄力
function BowWeapon:Charge(dt)
    if self.isCharge then
        if self.chargeForce < 1 then
            self.chargeForce = self.chargeForce + dt * (1 / self.derivedData.ChargeTime)
        else
            self.chargeForce = 1
        end
    else
        if self.chargeForce > 0 then
            self.chargeForce = self.chargeForce - dt * 5
        else
            self.chargeForce = 0
        end
    end
    self:UpdateChargeEffect(self.chargeForce)
    GuiBowAim:UpdateFrontSight(self.chargeForce)
    GuiBowAim:UpdateTouchGuiCD(self.useCT / self.baseData.UseCD)
    PlayerCam:TPSCamZoom(self.chargeForce)
end

--更新蓄力特效
function BowWeapon:UpdateChargeEffect(_force)
    if _force < 0.99 then
        self.chargeEffectObj.Step1.Scale = 0.3 * _force
        self.chargeEffectObj.Step1:SetActive(true)
        self.chargeEffectObj.Step2:SetActive(false)
    else
        self.chargeEffectObj.Step2:SetActive(true)
    end
end

--发射弓箭
function BowWeapon:ShootArrow(_force)
    local endPos = PlayerCam:TPSGetRayDir()
    local arrow =
        Projectile:CreateAvailableProjectile(
        self.derivedData.ProjectileID,
        localPlayer.Avatar.Bone_R_Hand.Position,
        localPlayer.Rotation,
        endPos,
        self.derivedData.ProjectileSpeed
    )

    SoundUtil.Play3DSE(localPlayer.Position, self.derivedData.ShootSoundID)
    invoke(
        function()
            wait(_force)
            if arrow then
                arrow.GravityEnable = true
                print(_force)
                wait(3 - _force)
            end
            if arrow then
                arrow.OnCollisionBegin:Clear()
                arrow:Destroy()
            end
        end,
        .1
    )
end
function BowWeapon:Update(dt)
    self:Charge(dt)
    self:CDRun(dt)
end

return BowWeapon
