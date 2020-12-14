--- 玩家动画状态模块
--- @module Player Social  Animation, client-side
--- @copyright Lilith Games, Avatar Team
--- @author 王殷鹏, Yuancheng Zhang

local AnimationState, this = ModuleUtil.New('AnimationState', ClientBase)

function AnimationState:Init()
    Animation = PlayAnimation
    climbUpAni = Animation:Initial(localPlayer, 'LadderClimbing', 2, Enum.BodyPart.FullBody, 2)
    climbIdleAni = Animation:Initial(localPlayer, 'LadderClimbIdle', 2, Enum.BodyPart.FullBody, 2)
end

function AnimationState:Swim()
    climbIdleAni:Stop()
    climbUpAni:Stop()
    localPlayer.AnimationMode = Enum.AnimationMode.Swim
end

function AnimationState:Climb()
    if not climbUpAni.Playing then
        climbIdleAni:Stop()
        climbUpAni:Play()
    end
end

function AnimationState:ClimbIdle()
    if not climbIdleAni.Playing then
        climbUpAni:Stop()
        climbIdleAni:Play()
    end
end

function AnimationState:Default()
    climbIdleAni:Stop()
    climbUpAni:Stop()
    if gItem.CommonItem.active then
        localPlayer.AnimationMode = gItem.CommonItem.config.Anim
    elseif localPlayer.Avatar.Bone_Head.DeathBlood then
        local NumberPool = {1, 2, 4}
        local RandomSeed = math.random(1, 3)
        local index = NumberPool[RandomSeed]
        localPlayer.AnimationMode = Enum.AnimationMode['Zombie' .. index]
    else
        localPlayer.AnimationMode = Enum.AnimationMode.None
    end
end

return AnimationState
