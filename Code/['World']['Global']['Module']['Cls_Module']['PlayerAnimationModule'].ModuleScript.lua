--- 动画模块
--- @module Player Animation, client-side
--- @copyright Lilith Games, Avatar Team
--- @author 王殷鹏, Yuancheng Zhang
local PlayerAnimation = {}

function PlayerAnimation:Init()
    world.OnRenderStepped:Connect(
        function(_delta)
            self:UpdateIK(_delta)
        end
    )
end

function PlayerAnimation:New(player, animName, layer, bodyPart, loopMode, showname)
    self.__index = self
    local Instance = {}
    setmetatable(Instance, self)
    Instance.Player = player
    Instance.AnimName = animName
    Instance.Layer = layer
    Instance.BodyPart = bodyPart
    Instance.LoopMode = loopMode
    Instance.Playing = false
    Instance.Weight = 0
    if showname then
        PlayerAnimation[showname] = Instance
    end
    return Instance
end

function PlayerAnimation:BeginIK(mySocket, targetSocket)
    PlayerAnimation.mySocket = mySocket
    PlayerAnimation.targetSocket = targetSocket
end

function PlayerAnimation:Play(speedScale, weight, transitionDuration, interrupt)
    self.Player.Avatar:SetBlendSubtree(self.BodyPart, self.Layer)
    self.Weight = weight or 0
    self.Player.Avatar:PlayAnimation(
        self.AnimName,
        self.Layer,
        weight or 1,
        transitionDuration or 0.1,
        interrupt or true,
        self.LoopMode > 1,
        self.speedScale or 1
    )
    self.Playing = true
end

function PlayerAnimation:Stop()
    self.Weight = 0
    self.Player.Avatar:StopAnimation(self.AnimName, self.Layer)
    self.Playing = false
end

function PlayerAnimation:ChangeBodyPart(bodyPart)
    self.BodyPart = bodyPart
end

function PlayerAnimation:AddEvent(eventName, percent, func)
    self[eventName] = self.Player.Avatar:AddAnimationEvent(self.AnimName, percent)
    self['Func' .. eventName] = func
    self[eventName]:Connect(func)
end

function PlayerAnimation:RemoveEvent(eventName)
    self[eventName]:Disconnect(self['Func' .. eventName])
end

function PlayerAnimation:ClearEvent(eventName)
    self[eventName]:Clear()
end

function PlayerAnimation:UpdateIK(delta)
    if PlayerAnimation.mySocket then
        local Tweener = Tween:TweenValue(0, 1, 1, Enum.EaseCurve.CircularInOut) --构造一个值插值器
        for i, v in ipairs(PlayerAnimation.mySocket) do
            local rate =
                math.clamp((v.Socket.Position - PlayerAnimation.targetSocket[i].Socket.Position).Magnitude, 0, 0.8)
            if v.Target == 1 then
                --(1 - Tweener:GetValue(rate))/5
                localPlayer.Avatar.LeftHandTarget = PlayerAnimation.targetSocket[i].Socket
                localPlayer.Avatar.LeftHandPositionWeight = 1 - Tweener:GetValue(rate)
                localPlayer.Avatar.LeftHandReach = 0
            elseif v.Target == 2 then
                localPlayer.Avatar.RightHandTarget = PlayerAnimation.targetSocket[i].Socket
                localPlayer.Avatar.RightHandPositionWeight = 1 - Tweener:GetValue(rate)
                localPlayer.Avatar.RightHandReach = 0
            --(1 - Tweener:GetValue(rate))/5
            end
        end
    else
        pcall(
            function()
                localPlayer.Avatar.LeftHandTarget = nil
                localPlayer.Avatar.RightHandTarget = nil
            end
        )
    end
end

function PlayerAnimation:StopIK()
    if PlayerAnimation.mySocket then
        PlayerAnimation.mySocket = nil
    end
end

return PlayerAnimation
