local BowIdleState = class('BowIdleState', PlayerActState)

function BowIdleState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('BowEquipIdle', 1, _stateName)
end

function BowIdleState:InitData()
    self:AddTransition(
        'ToBowMoveState',
        self.controller.states['BowMoveState'],
        -1,
        function()
            return self:MoveMonitor()
        end
    )
    self:AddTransition(
        'ToIdleState',
        self.controller.states['IdleState'],
        -1,
        function()
            return self.controller.triggers['IdleState']
        end
    )
    self:AddTransition(
        'ToBowChargeState',
        self.controller.states['BowChargeState'],
        -1,
        function()
            return self.controller.triggers['BowChargeState']
        end
    )
    self:AddTransition(
        'ToTakeOutItemState',
        self.controller.states['TakeOutItemState'],
        -1,
        function()
            return self.controller.triggers['TakeOutItemState']
        end
    )
    self:AddTransition(
        'ToBowHitState',
        self.controller.states['BowHitState'],
        -1,
        function()
            return self.controller.triggers['BowHitState']
        end
    )
    self:AddTransition(
        'ToBowJumpBeginState',
        self.controller.states['BowJumpBeginState'],
        -1,
        function()
            return self.controller.triggers['BowJumpBeginState']
        end
    )
end

function BowIdleState:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer.CharacterWidth = 0.5
    localPlayer.CharacterHeight = 1.7
    localPlayer.Avatar.LocalPosition = Vector3.Zero
    localPlayer.RotationRate = EulerDegree(0, 540, 0)
    localPlayer:SetMovementMode(Enum.MovementMode.MOVE_Walking)
    PlayerCam:SetCurCamEventHandler(PlayerCam.tpsCam)
end

function BowIdleState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    self:FallMonitor()
end

function BowIdleState:OnLeave()
    PlayerActState.OnLeave(self)
end

return BowIdleState
