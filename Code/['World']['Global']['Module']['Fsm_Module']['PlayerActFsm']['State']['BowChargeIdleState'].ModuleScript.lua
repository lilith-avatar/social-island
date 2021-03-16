local BowChargeIdle = class("BowChargeIdle", PlayerActState)

function BowChargeIdle:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer:MoveTowards(Vector2.Zero)
    NetUtil.Fire_C("PlayEffectEvent", localPlayer, 55)
    localPlayer.Avatar:PlayAnimation("BowChargeIdle", 2, 1, 0.1, true, true, 1)
    localPlayer.Avatar.Bone_R_Hand.BowChangeEffect:SetActive(true)
end

function BowChargeIdle:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    localPlayer:MoveTowards(Vector2.Zero)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle", "BowHit", "SwimIdle", "BowAttack"})
    for k, v in pairs(localPlayer.Avatar.Bone_R_Hand.BowChangeEffect:GetChildren()) do
        v.Size = Vector3(0.3, 0.3, 0.3) * GuiBowAim.chargeForce
    end
end

function BowChargeIdle:OnLeave()
    PlayerActState.OnLeave(self)
    localPlayer.Avatar.Bone_R_Hand.BowChangeEffect:SetActive(false)
end

return BowChargeIdle
