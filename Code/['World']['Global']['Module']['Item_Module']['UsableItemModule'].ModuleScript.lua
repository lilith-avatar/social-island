--- 即时使用型道具类
-- @module UsableItem
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
local UsableItem = class("UsableItem", ItemBase)

function UsableItem:initialize(_data, _config)
    ItemBase.initialize(self, _data, _config)
    print("UsableItem:initialize()")
    self.isUsable = true
    self.isEquipable = false
end

--放入背包
function UsableItem:PutIntoBag()
end

--从背包里扔掉
function UsableItem:ThrowOutOfBag()
end

--使用
function UsableItem:Use()
    ItemBase.Use(self)
    if self.config.UseAddBuffID then
        NetUtil.Fire_C("GetBuffEvent", localPlayer, self.config.UseAddBuffID, self.config.UseAddBuffDur)
    end
    if self.config.UseRemoveBuffID then
        NetUtil.Fire_C("RemoveBuffEvent", localPlayer, self.config.UseRemoveBuffID)
    end
    for k, v in pairs(self:GetPlayersByRange()) do
        if self.config.HitAddBuffID then
            NetUtil.Fire_C("GetBuffEvent", v, self.config.HitAddBuffID, self.config.HitAddBuffDur)
        end
        if self.config.HitRemoveBuffID then
            NetUtil.Fire_C("RemoveBuffEvent", v, self.config.HitRemoveBuffID)
        end
        self:PlayHitEffect(v.Position)
        self:PlayHitSound(v.Position)
    end
    if self.config.IsConsume then
        NetUtil.Fire_C("RemoveItemEvent", localPlayer, self.id)
    end
end

--获取影响范围内的玩家
function UsableItem:GetPlayersByRange()
    local players = {}
    for k, v in pairs(world:FindPlayers()) do
        if self.config.Range and self.config.Range > 0 then
            if (localPlayer.Position - v.Position).Magnitude <= self.config.Range then
                if v == localPlayer and self.config.IsSelfActive then
                    players[#players + 1] = v
                end
            end
        else
            if v == localPlayer and self.config.IsSelfActive then
                players[#players + 1] = v
                return players
            end
        end
    end
    return players
end

--播放命中特效
function UsableItem:PlayHitEffect(_pos)
    local effect =
        world:CreateInstance(self.config.HitEffectName, self.config.HitEffectName .. "Instance", self.weaponObj, _pos)
    invoke(
        function()
            effect:Destroy()
        end,
        1
    )
end

--播放命中音效
function UsableItem:PlayHitSound(_pos)
    NetUtil.Fire_C("PlayEffectEvent", self.config.HitSoundID, _pos)
end

--CD消退
function UsableItem:CDRun(dt)
    ItemBase.CDRun(self, dt)
end

return UsableItem
