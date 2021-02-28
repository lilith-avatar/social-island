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

--发射弓箭
function LongRangeWeapon:ShootArrow()
    local dir = (localPlayer.ArrowAim.Position - localPlayer.Position)
    dir.y = PlayerCam:TPSGetRayDir().y
    dir = dir.Normalized
    local arrow =
        world:CreateInstance(
        self.config.ArrowModelName,
        self.config.ArrowModelName,
        world,
        localPlayer.Avatar.Bone_R_Hand.Position,
        localPlayer.Rotation
    )
    arrow.Forward = dir
    arrow.LinearVelocity = arrow.Forward * 40
    arrow.OnCollisionBegin:Connect(
        function(_hitObj)
            if _hitObj ~= localPlayer and _hitObj.ClassName == "PlayerInstance" then
                NetUtil.Fire_S(
                    "SPlayerHitEvent",
                    localPlayer,
                    _hitObj,
                    ItemMgr.itemInstance[ItemMgr.curWeaponID]:GetAttackData()
                )
                arrow.OnCollisionBegin:Clear()
                arrow:Destroy()
            else
                if _hitObj.AnimalID and self.config.Hunt then
                    NetUtil.Fire_C(
                        "GetItemFromPoolEvent",
                        localPlayer,
                        Config.Animal[_hitObj.AnimalID.Value].ItemPoolID,
                        math.floor(self.config.IncomeFactor * Config.Animal[_hitObj.AnimalID.Value].DropCoin)
                    )
                    _hitObj.AnimalDeadEvent:Fire()
                end
            end
        end
    )
    invoke(
        function()
            if arrow then
                arrow.OnCollisionBegin:Clear()
                arrow:Destroy()
            end
        end,
        3
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
