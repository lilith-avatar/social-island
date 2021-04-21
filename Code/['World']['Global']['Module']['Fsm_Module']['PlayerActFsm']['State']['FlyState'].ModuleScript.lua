local FlyState = class('FlyState', PlayerActState)

local animState = 0
function FlyState:OnEnter()
    PlayerActState.OnEnter(self)
    animState = 0
    localPlayer:MoveTowards(Vector2.Zero)
end

function FlyState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({'Fly'})
    self:IdleMonitor()
    self:UpdateAnim()
end

function FlyState:IdleMonitor()
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
    if localPlayer.IsOnGround and animState == 2 then
        FsmMgr.playerActFsm:Switch('Idle')
    end
end

function FlyState:UpdateAnim()
    --print(localPlayer.LinearVelocity.y, animState)
    if localPlayer.LinearVelocity.y > 0 then
        if animState == 0 then
            localPlayer.Avatar:PlayAnimation('Jump02', 2, 1, 0, true, false, 1)
            animState = 1
        end
    else
        if animState == 1 then
            localPlayer.Avatar:PlayAnimation('Jump04Fly', 2, 1, 0.1, true, true, 1)
            animState = 2
        end
    end
end

function FlyState:OnLeave()
    PlayerActState.OnLeave(self)
end

return FlyState
