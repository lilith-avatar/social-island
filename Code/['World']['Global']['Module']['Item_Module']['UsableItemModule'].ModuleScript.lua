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
    if self.useCT == 0 then
        ItemBase.Use(self)
        NetUtil.Fire_C("GetBuffEvent", localPlayer, self.config.UseAddBuffID, self.config.UseAddBuffDur)
        NetUtil.Fire_C("RemoveBuffEvent", localPlayer, self.config.UseAddBuffID)
        for k, v in pairs(self:GetPlayersByRange()) do
            NetUtil.Fire_C("GetBuffEvent", v, self.config.HitAddBuffID, self.config.HitAddBuffDur)
            NetUtil.Fire_C("RemoveBuffEvent", v, self.config.HitRemoveBuffID)
            self:PlayHitEffect(v.Position)
            self:PlayHitSound(v.Position)
        end
    end
end

--获取影响范围内的玩家
function UsableItem:GetPlayersByRange()
    local players = {}
    for k, v in pairs(world:FindPlayers()) do
        if self.config.Range > 0 then
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
