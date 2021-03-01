local BowWalk = class("BowWalk", PlayerActState)

function BowWalk:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer.Avatar:PlayAnimation("WalkingFront", 2, 1, 0.1, true, true, 1)
end

function BowWalk:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle","BowHit", "SwimIdle", "BowAttack"})
    self:IdleMonitor()
    self:RunMonitor("Bow")
    self:JumpMonitor("Bow")
end

function BowWalk:OnLeave()
    PlayerActState.OnLeave(self)
end

---监听静止
function BowWalk:IdleMonitor()
    local dir = PlayerCtrl.finalDir
    dir.y = 0
    if dir.Magnitude > 0 then
        localPlayer:MoveTowards(Vector2(dir.x, dir.z).Normalized)
    else
        FsmMgr.playerActFsm:Switch("BowIdle")
    end
end

return BowWalk
