local UseItemState = class("UseItemState", PlayerActState)

local dirStateEnum = {
    Forward = 1,
    Back = 2,
    Right = 3,
    Left = 4
}

function UseItemState:OnEnter()
    PlayerActState.OnEnter(self)
end

function UseItemState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor(
        {
            "Idle",
            "Walk",
            "Run",
            "Jump",
            "Vertigo",
            "Fly",
            "Hit",
            "SwimIdle",
            "Swimming",
            "TakeOutItem",
            "UseItem",
            "BowIdle",
            "BowWalk",
            "BowRun",
            "BowJump",
            "BowChargeIdle",
            "BowAttack",
            "BowHit",
            "PistolIdle",
            "PistolRun",
            "PistolWalk",
            "PistolJump",
            "PistolAttack",
            "PistolHit"
        }
    )
    self:IdleMonitor()
end
function UseItemState:OnLeave()
    PlayerActState.OnLeave(self)
end

---监听静止
function UseItemState:IdleMonitor()
    local dir = PlayerCtrl.finalDir
    dir.y = 0
    if dir.Magnitude > 0 then
        if PlayerCam:IsFreeMode() then
            localPlayer:FaceToDir(dir, 4 * math.pi)
        end
        localPlayer:MoveTowards(Vector2(dir.x, dir.z))
    else
        localPlayer:MoveTowards(Vector2.Zero)
    end
end

return UseItemState
