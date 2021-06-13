--- 近战武器类
-- @module MeleeWeapon
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
local MeleeWeapon = class('MeleeWeapon', WeaponBase)

function MeleeWeapon:initialize(_data, _config)
    WeaponBase.initialize(self, _data, _config)
    --print('MeleeWeapon:initialize()')
end

--攻击
function MeleeWeapon:Attack()
    WeaponBase.Attack(self)
    invoke(
        function()
            self.equipObj.Col:SetActive(true)
            wait(self.baseData.UseTime)
            self.equipObj.Col:SetActive(false)
        end
    )
end

function MeleeWeapon:Equip()
    WeaponBase.Equip(self)
    invoke(
        function()
            self.equipObj.Col:SetActive(false)
            self.equipObj.Col.OnCollisionBegin:Connect(
                function(_hitObj, _hitPoint)
                    if _hitObj ~= localPlayer and _hitObj.ClassName == 'PlayerInstance' and _hitObj.Avatar then
                        if _hitObj.Avatar.ClassName == 'PlayerAvatarInstance' then
                            self:AddForceToHitPlayer(_hitObj)
                            self:HitBuff(_hitObj)
                            self:PlayHitSoundEffect(_hitPoint)
                        end
                    end
                end
            )
        end,
        self.baseData.TakeOutTime + 0.1
    )
end

--对命中玩家施加力
function MeleeWeapon:AddForceToHitPlayer(_player)
    _player.LinearVelocity = (_player.Position - localPlayer.Position).Normalized * self.derivedData.HitForce
end

--命中增加/移除buff
function MeleeWeapon:HitBuff(_player)
    CloudLogUtil.UploadLog(
        'battle_actions',
        'hit_event',
        {hit_target_id = 'Player', target_detail = _player.Name, attack_target = localPlayer.Name, attack_type = 'Melee'}
    )
    NetUtil.Fire_S(
        'SPlayerHitEvent',
        localPlayer,
        _player,
        {
            addBuffID = self.derivedData.HitAddBuffID,
            addDur = self.derivedData.HitAddBuffDur,
            removeBuffID = self.derivedData.HitRemoveBuffID
        }
    )
end

--播放命中音效和特效
function MeleeWeapon:PlayHitSoundEffect(_pos)
    SoundUtil.Play3DSE(_pos, self.derivedData.HitSoundID)
    local effect =
        world:CreateInstance(self.derivedData.HitEffectName, self.derivedData.HitEffectName .. 'Instance', world, _pos)
    invoke(
        function()
            effect:Destroy()
        end,
        1
    )
end

return MeleeWeapon
