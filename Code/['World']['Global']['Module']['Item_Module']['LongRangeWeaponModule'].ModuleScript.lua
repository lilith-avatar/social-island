--- 远程武器类
-- @module LongRangeWeapon
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
local LongRangeWeapon = class("LongRangeWeapon", WeaponBase)

function LongRangeWeapon:initialize(_data, _config)
    WeaponBase.initialize(self, _data, _config)
    print("LongRangeWeapon:initialize()")
end

--攻击
function LongRangeWeapon:Attack()
    self.attackCT = self.config.AttackCD
    self:PlayAttackAnim()
end

--装备
function LongRangeWeapon:Equip()
    WeaponBase.Equip(self)
    GuiBowAim.gui:SetActive(true)
    GuiBowAim.touchGui:SetActive(true)
end

--取下装备
function LongRangeWeapon:Unequip()
    WeaponBase.Unequip(self)
    GuiBowAim.gui:SetActive(false)
    GuiBowAim.touchGui:SetActive(false)
end

--发射弓箭
function LongRangeWeapon:ShootArrow(_force)
    local endPos = PlayerCam:TPSGetRayDir()
    local arrow =
        world:CreateInstance(
        self.config.ArrowModelName,
        self.config.ArrowModelName,
        world,
        localPlayer.Avatar.Bone_R_Hand.Position,
        localPlayer.Rotation
    )
    --world:CreateInstance("TestSphere", "TestSphere", world, endPos)
    self:PlayAttackSound()
    arrow.Forward = endPos - arrow.Position
    arrow.LinearVelocity = arrow.Forward * 40
    arrow.OnCollisionBegin:Connect(
        function(_hitObj)
            if _hitObj then
                if _hitObj ~= localPlayer and _hitObj.ClassName == "PlayerInstance" then
                    NetUtil.Fire_S(
                        "SPlayerHitEvent",
                        localPlayer,
                        _hitObj,
                        ItemMgr.itemInstance[ItemMgr.curWeaponID]:GetAttackData()
                    )
                    arrow.OnCollisionBegin:Clear()
                    self:PlayHitSound(_hitObj.Position)
                    arrow:Destroy()
                elseif _hitObj.AnimalID and self.config.Hunt then
                    self:PlayHitSound(_hitObj.Position)
                    NetUtil.Fire_C(
                        "GetItemFromPoolEvent",
                        localPlayer,
                        Config.Animal[_hitObj.AnimalID.Value].ItemPoolID,
                        0
                    )
                    NetUtil.Fire_S(
                        "SpawnCoinEvent",
                        "P",
                        _hitObj.Position + Vector3(0, 1, 0),
                        math.floor(self.config.IncomeFactor * Config.Animal[_hitObj.AnimalID.Value].DropCoin)
                    )
                    _hitObj.AnimalDeadEvent:Fire()
                elseif _hitObj.Name == "ArrowTargetCol" then
                    self:PlayHitSound(_hitObj.Position)
                    _hitObj.Parent.ArrowTargetEvent:Fire(_hitObj.Position)
                    arrow:Destroy()
                end
            end
        end
    )
    invoke(
        function()
            wait(_force)
            if arrow then
                arrow.GravityEnable = true
                wait(3 - _force)
            end
            if arrow then
                arrow.OnCollisionBegin:Clear()
                arrow:Destroy()
            end
        end,
        .1
    )
    return arrow
end

--弓箭爆炸
function LongRangeWeapon:ArrowExplosion()
    if self.config.ExplosionRange > 0 then
        for k, v in pairs(self:GetPlayersByRange()) do
            NetUtil.Fire_C("GetBuffEvent", v, self.config.HitAddBuffID, self.config.HitAddBuffDur)
            NetUtil.Fire_C("RemoveBuffEvent", v, self.config.HitRemoveBuffID)
            self:PlayHitEffect(v.Position)
            self:PlayHitSound(v.Position)
        end
    end
end

--获取爆炸范围内的玩家
function LongRangeWeapon:GetPlayersByRange()
    local players = {}
    for k, v in pairs(world:FindPlayers()) do
        if self.config.ExplosionRange > 0 then
            if (localPlayer.Position - v.Position).Magnitude <= self.config.ExplosionRange then
                players[#players + 1] = v
            end
        else
            return nil
        end
    end
    return players
end

--获取攻击数据
function LongRangeWeapon:GetAttackData()
    return {
        healthChange = self.config.HealthChange,
        hitAddBuffID = self.config.HitAddBuffID,
        hitAddBuffDur = self.config.HitAddBuffDur,
        hitRemoveBuffID = self.config.HitRemoveBuffID
    }
end

return LongRangeWeapon
