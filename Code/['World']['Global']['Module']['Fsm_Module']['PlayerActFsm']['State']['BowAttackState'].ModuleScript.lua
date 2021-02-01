local BowAttack = class("BowAttack", PlayerActState)

function BowAttack:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer:MoveTowards(Vector2.Zero)
    localPlayer.Avatar:PlayAnimation("BowAttack", 2, 1, 0.1, true, false, 1)
    ItemMgr.itemInstance[ItemMgr.curWeaponID]:ShootArrow()
end

function BowAttack:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    localPlayer:MoveTowards(Vector2.Zero)
end

function BowAttack:OnLeave()
    PlayerActState.OnLeave(self)
end

return BowAttack
