---@module Football
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local Football,this = ModuleUtil.New('Football',ServerBase)

---初始化函数
function Football:Init()
    this:DataInit()
    this:EventBind()
end

function Football:DataInit()
    this.ball = world.Football.Ball
    this.goal = world.Football.Goal
    this.ballOriPos = this.ball.Position
end

function Football:EventBind()
    for k,v in pairs(this.goal:GetChildren()) do
        v.OnCollisionBegin:Connect(
            function(_hitObject)
                if _hitObject.Name == 'Ball' and _hitObject.ClassName == 'Sphere' then
                    this:FootballGoal(v)
                end
            end
        )
    end
end

function Football:FootballGoal(_goal)
    this.ball.IsStatic = true
    _goal.GoalEffect:SetActive(true)
    invoke(function()
        _goal.GoalEffect:SetActive(false)
        this.ball.Position = this.ballOriPos
        this.ball.RefreshFx:SetActive(true)
        this.ball.IsStatic = false
        wait(1)
        this.ball.RefreshFx:SetActive(false)
    end, 1)
end

return Football
