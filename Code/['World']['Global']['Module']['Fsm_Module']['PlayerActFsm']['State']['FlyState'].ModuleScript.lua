local FlyState = class('FlyState', PlayerActState)

function FlyState:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer.Avatar:PlayAnimation('Jump04Fly', 2, 1, 0, true, true, 1)
end

function FlyState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    self:IdleMonitor()
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
    if localPlayer.IsOnGround then
        FsmMgr.playerActFsm:Switch('Idle')
    end
end

function FlyState:OnLeave()
    PlayerActState.OnLeave(self)
end

return FlyState
