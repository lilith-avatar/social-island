local TwoHandedSwordAttack2 = class("TwoHandedSwordAttack2", PlayerActState)

function AttackHit(_hitObj)
    if _hitObj ~= localPlayer and _hitObj.ClassName == "PlayerInstance" then
        NetUtil.Fire_S(
            "SPlayerHitEvent",
            localPlayer,
            _hitObj,
            ItemMgr.itemInstance[ItemMgr.curWeaponID]:GetAttackData()
        )
    end
end

function TwoHandedSwordAttack2:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer:MoveTowards(Vector2.Zero)
    localPlayer.Avatar:PlayAnimation("TwoHandedSwordAttack2", 2, 1, 0.1, true, false, 1)
    --localPlayer.Avatar:PlayAnimation("TwoHandedSwordAttack2", 3, 1, 0.1, true, false, 1)
	ItemMgr.itemInstance[ItemMgr.curWeaponID].weaponObj.Col.OnCollisionBegin:Connect(
        function(_hitObj)
            AttackHit(_hitObj)
        end
    )
	if ItemMgr.itemInstance[ItemMgr.curWeaponID].config.Mole then
        NetUtil.Fire_S('PlayerHitEvent', localPlayer.UserId, MoleGame.rangeList)
    end
end

function TwoHandedSwordAttack2:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    localPlayer:MoveTowards(Vector2.Zero)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle", "SwimIdle"})
end

function TwoHandedSwordAttack2:OnLeave()
    PlayerActState.OnLeave(self)
	ItemMgr.itemInstance[ItemMgr.curWeaponID].weaponObj.Col.OnCollisionBegin:Clear()
end

return TwoHandedSwordAttack2
