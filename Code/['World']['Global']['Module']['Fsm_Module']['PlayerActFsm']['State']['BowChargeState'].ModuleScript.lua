local BowChargeState = class('BowChargeState', PlayerActState)

function BowChargeState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    local anims = {
        {'BowEquipIdle', 0.0, 1.0},
        {'WalkingFront', 0.25, 1.0},
        {'BowRun', 0.5, 1.0}
    }
    PlayerAnimMgr:Create1DClipNode(anims, 'speedXZ', _stateName)
    PlayerAnimMgr:CreateSingleClipNode('BowChargeIdle', 1, _stateName .. 'UpperBody')
end

function BowChargeState:InitData()
    self:AddTransition(
        'ToIdleState',
        self.controller.states['IdleState'],
        -1,
        function()
            return self.controller.triggers['IdleState']
        end
    )
    --[[self:AddTransition(
        'ToBowHitState',
        self.controller.states['BowHitState'],
        -1,
        function()
            return self.controller.triggers['BowHitState']
        end
    )]]
    self:AddTransition(
        'ToBowAttackState',
        self.controller.states['BowAttackState'],
        -1,
        function()
            return self.controller.triggers['BowAttackState']
        end
    )
end

function BowChargeState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.2, 0.2, true, true, 1)
    PlayerAnimMgr:Play(self.stateName .. 'UpperBody', 1, 1, 0.2, 0.2, true, true, 1)
end

function BowChargeState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    self:SpeedMonitor()
    self:Move()
    self:FallMonitor()
end

local isAim = false
---移动
function BowChargeState:Move()
    local dir = PlayerCtrl.finalDir
    local forward = PlayerCam.curCamera.Forward
    forward.y = 0
    dir.y = 0
    if Vector3.Angle(forward, localPlayer.Forward) < 15 then
        isAim = true
    else
        isAim = false
    end
    if dir.Magnitude > 0 then
        localPlayer:AddMovementInput(dir, 0.3)
    elseif isAim == false then
        localPlayer:AddMovementInput(forward, 0.01)
    end
end

function BowChargeState:OnLeave()
    PlayerActState.OnLeave(self)
    --localPlayer.Avatar:StopBlendSpaceNode(1)
end

return BowChargeState
