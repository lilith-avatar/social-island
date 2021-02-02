local TwoHandedSwordAttack3 = class("TwoHandedSwordAttack3", PlayerActState)

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

function TwoHandedSwordAttack3:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer:MoveTowards(Vector2.Zero)
    localPlayer.Avatar:PlayAnimation("TwoHandedSwordAttack3", 2, 1, 0.1, true, false, 1)
    --localPlayer.Avatar:PlayAnimation("TwoHandedSwordAttack3", 3, 1, 0.1, true, false, 1)
	ItemMgr.itemInstance[ItemMgr.curWeaponID].weaponObj.Col.OnCollisionBegin:Connect(
        function(_hitObj)
            AttackHit(_hitObj)
        end
    )
end

function TwoHandedSwordAttack3:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    localPlayer:MoveTowards(Vector2.Zero)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle","SwimIdle"})
end

function TwoHandedSwordAttack3:OnLeave()
    PlayerActState.OnLeave(self)
	ItemMgr.itemInstance[ItemMgr.curWeaponID].weaponObj.Col.OnCollisionBegin:Clear()
end

return TwoHandedSwordAttack3
