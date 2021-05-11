---@module Football
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local Football, this = ModuleUtil.New("Football", ServerBase)

---初始化函数
function Football:Init()
    this:DataInit()
    this:EventBind()
end

function Football:DataInit()
    this.ball = world.Football.Ball
    this.goal = world.Football.Goal
    this.border = world.Football.Border
    this.ballOriPos = this.ball.Position
end

function Football:EventBind()
    for k, v in pairs(this.goal:GetChildren()) do
        v.OnCollisionBegin:Connect(
            function(_hitObject)
				if _hitObject then
					if _hitObject.Name == "Ball" and _hitObject.ClassName == "Sphere" then
						this:FootballGoal(v)
					end
				end
            end
        )
    end
    this.border.OnCollisionEnd:Connect(
        function(_hitObject)
            if _hitObject and _hitObject.Name == "Ball" and _hitObject.ClassName == "Sphere" then
                this.ball.RefreshFx:SetActive(true)
                wait(1)
                this.ball.RefreshFx:SetActive(false)
                this:FootballReset()
            end
        end
    )
end

function Football:FootballGoal(_goal)
    this.ball.IsStatic = true
    _goal.GoalEffect:SetActive(true)
	CloudLogUtil.UploadLog('inter', 'Ball_Goal_'.._goal.Name)
    invoke(
        function()
            _goal.GoalEffect:SetActive(false)
            this:FootballReset()
        end,
        1
    )
end

function Football:FootballReset()
    this.ball.IsStatic = true
    this.ball.Position = this.ballOriPos
    this.ball.LinearVelocity = Vector3.Zero
    this.ball.RefreshFx:SetActive(true)
    wait(1)
    this.ball.IsStatic = false
    this.ball.RefreshFx:SetActive(false)
end

return Football
