local UseItemState = class('UseItemState', PlayerActState)

local isMove = false

function UseItemState:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer.Avatar:StopAnimation('WalkingFront', 2)
    localPlayer.Avatar:StopAnimation('RunFront', 2)
    localPlayer.Avatar:StopAnimation('OneHandedSwordRun', 2)
    localPlayer.Avatar:StopAnimation('Jogging', 2)
    isMove = false
end

function UseItemState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor(
        {
            'Idle',
            'Walk',
            'Run',
            'Jump',
            'Vertigo',
            'Fly',
            'Hit',
            'SwimIdle',
            'Swimming',
            'TakeOutItem',
            'UseItem',
            'BowIdle',
            'BowWalk',
            'BowRun',
            'BowJump',
            'BowChargeIdle',
            'BowAttack',
            'BowHit',
            'PistolIdle',
            'PistolRun',
            'PistolWalk',
            'PistolJump',
            'PistolAttack',
            'PistolHit'
        }
    )
    self:IdleMonitor()
end
function UseItemState:OnLeave()
    PlayerActState.OnLeave(self)
    localPlayer.Avatar:StopAnimation('RunFront', 9)
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
        if isMove == false then
            localPlayer.Avatar:PlayAnimation('RunFront', 9, 2, 0.1, true, true, 1)
            isMove = true
        end
    else
        localPlayer.Avatar:StopAnimation('RunFront', 9)
        localPlayer:MoveTowards(Vector2.Zero)
        isMove = false
    end
end

return UseItemState
