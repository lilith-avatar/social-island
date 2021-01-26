local Swimming = class("Swimming", PlayerActState)

function Swimming:OnEnter()
    PlayerActState.OnEnter(self)
    --localPlayer.Avatar:PlayAnimation("Swimming", 2, 1, 0.1, true, true, 1)
    localPlayer.Avatar:PlayAnimation("Swimming", 4, 1, 0.1, true, true, 1)
end

function Swimming:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle"})
    self:IdleMonitor()
end

function Swimming:OnLeave()
    PlayerActState.OnLeave(self)
end

---监听静止
function Swimming:IdleMonitor()
    local dir = PlayerCtrl.finalDir
    dir.y = 0
    if dir.Magnitude > 0 then
        if PlayerCam:IsFreeMode() then
            localPlayer:FaceToDir(dir, 4 * math.pi)
        end
        localPlayer:MoveTowards(Vector2(dir.x, dir.z).Normalized)
        localPlayer.LinearVelocity =
            Vector3(localPlayer.LinearVelocity.x, PlayerCam.playerGameCam.Forward.y * 5, localPlayer.LinearVelocity.z)
        localPlayer:MoveTowards(Vector2(dir.x, dir.z).Normalized)
    else
        FsmMgr.playerActFsm:Switch("SwimIdle")
    end
end

return Swimming
