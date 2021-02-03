local OneHandedSwordAttack1 = class("OneHandedSwordAttack1", PlayerActState)

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

function OneHandedSwordAttack1:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer:MoveTowards(Vector2.Zero)
    localPlayer.Avatar:PlayAnimation("OneHandedSwordAttack1", 2, 1, 0.1, true, false, 1)
    --localPlayer.Avatar:PlayAnimation("OneHandedSwordAttack1", 3, 1, 0.1, true, false, 1)
    ItemMgr.itemInstance[ItemMgr.curWeaponID].weaponObj.Col.OnCollisionBegin:Connect(
        function(_hitObj)
            AttackHit(_hitObj)
        end
    )
    if ItemMgr.itemInstance[ItemMgr.curWeaponID].config.Mole then
        NetUtil.Fire_S('PlayerHitEvent', localPlayer.UserId, MoleGame.rangeList)
    end
end

function OneHandedSwordAttack1:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    localPlayer:MoveTowards(Vector2.Zero)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle", "SwimIdle"})
end

function OneHandedSwordAttack1:OnLeave()
    PlayerActState.OnLeave(self)
    ItemMgr.itemInstance[ItemMgr.curWeaponID].weaponObj.Col.OnCollisionBegin:Clear()
end

return OneHandedSwordAttack1
