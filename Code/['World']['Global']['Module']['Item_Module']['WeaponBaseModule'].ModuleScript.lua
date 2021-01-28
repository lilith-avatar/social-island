--- 武器基类
-- @module WeaponBase
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
local WeaponBase = class("WeaponBase", ItemBase)

function WeaponBase:initialize(_data, _config)
    ItemBase.initialize(self, _data, _config)
    print("WeaponBase:initialize()")
    self.isUsable = true
    self.isEquipable = true
    self.weaponObj = nil
    self.attackCT = self.config.AttackCD
end

--放入背包
function WeaponBase:PutIntoBag()
end

--从背包里扔掉
function WeaponBase:ThrowOutOfBag()
end

--使用
function WeaponBase:Use()
    if self.useCT == 0 then
    end
    print("使用", self.id)
    if ItemMgr.curWeaponID ~= 0 then
        ItemMgr.itemInstance[ItemMgr.curWeaponID]:Unequip()
    end
    ItemMgr.curWeaponID = self.id
    ItemBase.Use(self)
    self:Equip()
end

--装备
function WeaponBase:Equip()
    local node1, node2 = string.match(self.config.ParentNode, "([%w_]+).([%w_]+)")
    print(node1, node1)
    local pNode = localPlayer.Avatar[node1][node2]
    self.weaponObj =
        world:CreateInstance(
        self.config.ModelName,
        self.config.ModelName .. "Instance",
        pNode,
        pNode.Position + self.config.Offset,
        pNode.Rotation + self.config.Angle
    )
    --[[self.weaponObj =
        world:CreateInstance(
        self.config.ModelName,
        self.config.ModelName .. "Instance",
        self.config.ParentNode,
        self.config.ParentNode.Positon + self.config.Offset,
        self.config.ParentNode.Rotation + self.config.Angle
    )]]
    --self:PlayIdleAnim()
    print("装备")
    NetUtil.Fire_C("GetBuffEvent", localPlayer, self.config.UseAddBuffID, self.config.UseAddBuffDur)
    --NetUtil.Fire_C("RemoveBuffEvent", localPlayer, self.config.UseAddBuffID)
    GuiControl:UpdateTakeOffBtn()
end

--取下装备
function WeaponBase:Unequip()
    NetUtil.Fire_C("FsmTriggerEvent", localPlayer, "Idle")
    NetUtil.Fire_C("RemoveBuffEvent", localPlayer, self.config.UseAddBuffID)
    self.weaponObj:Destroy()
    ItemMgr.curWeaponID = 0
    GuiControl:UpdateTakeOffBtn()
end

--攻击
function WeaponBase:Attack()
    self.attackCT = self.config.AttackCD
    self:PlayAttackAnim()
end

--获取攻击数据
function WeaponBase:GetAttackData()
    return {
        healthChange = self.config.HealthChange,
        hitAddBuffID = self.config.HitAddBuffID,
        hitAddBuffDur = self.config.HitAddBuffDur,
        hitRemoveBuffID = self.config.HitRemoveBuffID
    }
end

--播放攻击音效
function WeaponBase:PlayAttackSound()
    NetUtil.Fire_C("PlayEffectEvent", localPlayer, self.config.AttackSoundID)
end

--播放命中音效
function WeaponBase:PlayHitSound(_pos)
    NetUtil.Fire_C("PlayEffectEvent", localPlayer, self.config.HitSoundID, _pos)
end

--播放命中特效
function WeaponBase:PlayHitEffect(_pos)
    local effect =
        world:CreateInstance(self.config.HitEffectName, self.config.HitEffectName .. "Instance", self.weaponObj, _pos)
    invoke(
        function()
            effect:Destroy()
        end,
        1
    )
end

--切换到待机动作
function WeaponBase:PlayIdleAnim()
    NetUtil.Fire_C("FsmTriggerEvent", localPlayer, self.config.Anim .. "Idle")
end

--切换到攻击动作
function WeaponBase:PlayAttackAnim()
    for k, v in pairs(self.config.AttackAnimName) do
        NetUtil.Fire_C("FsmTriggerEvent", localPlayer, v)
    end
end

--CD消退
function WeaponBase:CDRun(dt)
    ItemBase.CDRun(self, dt)
    if self.attackCT > 0 then
        self.attackCT = self.attackCT - dt
    elseif self.attackCT < 0 then
        self.attackCT = 0
    end
end

return WeaponBase
