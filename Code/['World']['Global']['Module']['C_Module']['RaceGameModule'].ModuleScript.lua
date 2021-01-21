---计时赛跑客户端逻辑模块
---@module RaceGame
---@copyright Lilith Games, Avatar Team
---@author Changoo Wu
local RaceGame, this = ModuleUtil.New('RaceGame', ClientBase)
local Config = Config
local nowKey = 1

---采集玩法初始化
function RaceGame:Init()
    this:NodeDef()
end

---检查玩家是否带有宠物
local withPet = true
local totalResetTime = 0
function RaceGame:PetCheck(_dt, _tt)
	if withPet == true then
		totalResetTime = totalResetTime + _dt
		if totalResetTime > (60 * 0.75) then
			totalResetTime = 0
			this:RandomKey()
			this:FreshStartPoint()
			---重置的其他表现
		end
    end
end

--对玩家点击开始按钮做处理
function RaceGame:InteractCEventHandler(_interactID)
	if _interactID == 9 then
		if withPet ~= true then
			---弹报错说需要带上宠物
		else
			RaceGame:DataInit()
			RaceGame:GameStart()
		end
	end
end

---刷新起始点
function RaceGame:FreshStartPoint()
	this.startPoint.Position = Config.RacePoint[nowKey][1].Pos
end

---刷新现在挑战的序列
function RaceGame:RandomKey()
    nowKey = math.random(1, #Config.RacePoint)
end

---数据初始化
function RaceGame:DataInit()
    this.pointRecord = 1
    this.pointNum = #Config.RacePoint[nowKey]
    this.totalTime = Config.RacePoint[nowKey][1].MaxTime
    this.startUpdate = false
    this.timer = 0
end

---节点绑定
function RaceGame:NodeDef()
    ---如果玩家检测体不够大再扩一下
    this.checkPoint =
        world:CreateInstance(
        'CheckPoint',
        'CheckPoint',
        localPlayer.Local.Independent,
		Vector3(0,-1100,0)
    )
	this.startPoint =
        world:CreateInstance(
        'startPoint',
        'startPoint',
        localPlayer.Local.Independent,
        Vector3(0,-1000,0)
    )
    this.checkPoint.OnCollisionBegin:Connect(
        function(_hitObject, _hitPoint, _hitNormal)
            this:FreshPoint(_hitObject, _hitPoint, _hitNormal)
        end
    )
	
	this.startPoint.OnCollisionBegin:Connect(
        function(_hitObject)
            if _hitObject == localPlayer then
                NetUtil.Fire_C('OpenDynamicEvent', _hitObject, 'Interact', 9)
            end
        end
    )
    this.startPoint.OnCollisionEnd:Connect(
        function(_hitObject)
            if _hitObject == localPlayer then
                NetUtil.Fire_C('ResetDefUIEvent', _hitObject)
            end
        end
    )
end

---游戏开始
function RaceGame:GameStart()
    --Todo:面朝第一个点
    this.startUpdate = true
    RaceGameUIMgr:Show()
	this.startPoint.Position = Vector3(0,-1000,0)
	this.checkPoint.Position = Config.RacePoint[nowKey][2].Pos
end

---游戏结束
local rewardRate = 0
function RaceGame:GameOver()
    this.startUpdate = false
    rewardRate = this.pointRecord / this.pointNum
    if rewardRate == 1 then
        RaceGameUIMgr:ShowGameOver('win')
    else
        RaceGameUIMgr:ShowGameOver('lose')
    end
	this:RandomKey()
    NetUtil.Fire_S('RaceGameOverEvent', localPlayer, this.timer, rewardRate)
	this.checkPoint.Position = Vector3(0,-1100,0)
end

---碰到检查点之后的逻辑
function RaceGame:FreshPoint(_hitObject, _hitPoint, _hitNormal)
    if _hitObject == localPlayer and withPet then
		--todo：获得一个移动速度变成0的持续一秒的BUFF
		--todo：在检查点的位置放一个扫描的宠物动画
		this.checkPoint:SetActive(false)
		this.pointRecord = this.pointRecord + 1
		
		invoke(function()
			if this.pointRecord == this.pointNum then
				RaceGame:GameOver()
			else
				RaceGameUIMgr:GetCheckPoint(this.pointRecord, this.pointNum)
				this.checkPoint.Position = Config.RacePoint[nowKey][this.pointRecord + 1].Pos
				this.checkPoint:SetActive(true)
			end
		end,1)
		
	elseif _hitObject == localPlayer then
		---弹报错说需要带上宠物
    end
end

---游戏计时器逻辑
function RaceGame:Update(_dt, _tt)
    if this.startUpdate then
        this.totalTime = this.totalTime - _dt
        this.timer = this.timer + _dt
        if this.totalTime < 0 then
            RaceGame:GameOver()
        end
    else 
		RaceGame:PetCheck(_dt, _tt)
	end
end
return RaceGame
