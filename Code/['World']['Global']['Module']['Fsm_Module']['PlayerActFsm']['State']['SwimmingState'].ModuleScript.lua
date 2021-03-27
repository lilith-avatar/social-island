local Swimming = class("Swimming", PlayerActState)

local timer = 0

function Swimming:OnEnter()
    timer = 0
    PlayerActState.OnEnter(self)
    --localPlayer.Avatar:PlayAnimation("Swimming", 2, 1, 0.1, true, true, 1)
    localPlayer.Avatar:PlayAnimation("Swimming", 2, 1, 0.1, true, true, 1)
end

function Swimming:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle"})
    self:IdleMonitor()
    self:JumpMonitor()
    if timer < 1 then
        timer = timer + dt
    else
        --NetUtil.Fire_C("PlayEffectEvent", localPlayer, 21)
        --SoundUtil.Play3DSE(localPlayer.Position, 21)
        timer = 0
    end
end

function Swimming:OnLeave()
    PlayerActState.OnLeave(self)
end

---监听静止
function Swimming:IdleMonitor()
    local dir = PlayerCtrl.finalDir
    dir.y = 0
    if localPlayer.Position.y > -15.7 then
        if dir.Magnitude > 0 then
            if PlayerCam:IsFreeMode() then
                localPlayer:FaceToDir(dir, 4 * math.pi)
            end
            localPlayer:MoveTowards(Vector2(dir.x, dir.z).Normalized)
            localPlayer.LinearVelocity = Vector3(localPlayer.LinearVelocity.x, 0, localPlayer.LinearVelocity.z)
            localPlayer:MoveTowards(Vector2(dir.x, dir.z).Normalized)
        else
            FsmMgr.playerActFsm:Switch("SwimIdle")
        end
    else
        if dir.Magnitude > 0 then
            if PlayerCam:IsFreeMode() then
                localPlayer:FaceToDir(dir, 4 * math.pi)
            end
            localPlayer:MoveTowards(Vector2(dir.x, dir.z).Normalized)
            localPlayer.LinearVelocity =
                Vector3(
                localPlayer.LinearVelocity.x,
                PlayerCam.playerGameCam.Forward.y * 7,
                localPlayer.LinearVelocity.z
            )
            if localPlayer.State == 1 and PlayerCam.playerGameCam.Forward.y > 0 then
                localPlayer.Position = localPlayer.Position + Vector3(0, 0.1, 0)
            end
            localPlayer:MoveTowards(Vector2(dir.x, dir.z).Normalized)
        else
            FsmMgr.playerActFsm:Switch("SwimIdle")
        end
    end
end

function Swimming:JumpMonitor()
    if FsmMgr.playerActFsm.stateTrigger.Jump then
        if localPlayer.Position.y > -15.7 then
            FsmMgr.playerActFsm:Switch("Jump")
        end
    end
end

return Swimming
