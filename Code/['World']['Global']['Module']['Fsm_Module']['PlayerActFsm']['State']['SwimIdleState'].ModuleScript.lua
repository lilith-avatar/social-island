local SwimIdle = class('SwimIdle', PlayerActState)

function SwimIdle:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer:MoveTowards(Vector2.Zero)
    localPlayer.GravityScale = 0
    if localPlayer.Position.y <= -15.7 then
        localPlayer.LinearVelocity = Vector3(0, 0.01, 0)
    else
        localPlayer.LinearVelocity = Vector3.Zero
    end
    --localPlayer.Avatar:PlayAnimation("SwimIdle", 2, 1, 0.1, true, true, 1)
    localPlayer.Avatar:PlayAnimation('SwimIdle', 2, 1, 0.1, true, true, 1)
    localPlayer.Avatar.Position = localPlayer.Position + Vector3(0, 0.8, 0)
end

function SwimIdle:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({'Idle', 'Fly'})
    self:MoveMonitor()
    self:JumpMonitor()
    if localPlayer.Position.y > -15.7 then
        localPlayer.LinearVelocity = Vector3.Zero
    end
end

function SwimIdle:OnLeave()
    PlayerActState.OnLeave(self)
end

---监听移动
function SwimIdle:MoveMonitor()
    local dir = PlayerCtrl.finalDir
    dir.y = 0
    if dir.Magnitude > 0 then
        FsmMgr.playerActFsm:Switch('Swimming')
    end
end

function SwimIdle:JumpMonitor()
    if FsmMgr.playerActFsm.stateTrigger.Jump then
        if localPlayer.Position.y > -15.7 then
            FsmMgr.playerActFsm:Switch('Jump')
        end
        local effect = world:CreateInstance('LandWater', 'LandWater', world, localPlayer.Position + Vector3(0, 2, 0))
        invoke(
            function()
                effect:Destroy()
            end,
            1
        )
    end
end

return SwimIdle
