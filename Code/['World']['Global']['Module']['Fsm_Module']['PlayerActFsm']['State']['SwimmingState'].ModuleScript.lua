local Swimming = class('Swimming', PlayerActState)

local timer = 0

function Swimming:OnEnter()
    timer = 0
    PlayerActState.OnEnter(self)
    --localPlayer.Avatar:PlayAnimation("Swimming", 2, 1, 0.1, true, true, 1)
    localPlayer.Avatar:PlayAnimation('Swimming', 2, 1, 0.1, true, true, 1)
end

function Swimming:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({'Idle', 'Fly'})
    self:IdleMonitor()
    self:JumpMonitor()
    self:Splash(dt)
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
        local LVy = (PlayerCam.playerGameCam.Forward.y + 0.2) * 7
        if localPlayer.Position.y > -15.7 then
            if LVy > 0 then
                LVy = 0
            else
                LVy = LVy
            end
        else
            LVy = LVy
        end
        localPlayer.LinearVelocity = Vector3(localPlayer.LinearVelocity.x, LVy, localPlayer.LinearVelocity.z)
        if localPlayer.State == 1 and PlayerCam.playerGameCam.Forward.y > 0 then
            localPlayer.Position = localPlayer.Position + Vector3(0, 0.1, 0)
        end
        localPlayer:MoveTowards(Vector2(dir.x, dir.z).Normalized)
    else
        FsmMgr.playerActFsm:Switch('SwimIdle')
    end
end

--水花
function Swimming:Splash(dt)
    if localPlayer.Position.y > -15.7 then
        if timer < 0.5 then
            timer = timer + dt
        else
            local effect = world:CreateInstance('FootStep', 'FootStep', world, localPlayer.Position + Vector3(0, 1, 0))
            invoke(
                function()
                    effect:Destroy()
                end,
                1
            )
            timer = 0
        end
    end
end

function Swimming:JumpMonitor()
    if FsmMgr.playerActFsm.stateTrigger.Jump then
        if localPlayer.Position.y > -15.7 then
            FsmMgr.playerActFsm:Switch('Jump')
        end
    end
end

return Swimming
