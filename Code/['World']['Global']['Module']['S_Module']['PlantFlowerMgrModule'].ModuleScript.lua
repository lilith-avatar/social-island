-- @module  MonsterBattle
-- @copyright Lilith Games, Avatar Team
-- @author Lin
local PlantFlowerMgr, this = ModuleUtil.New('PlantFlowerMgr', ServerBase)
--计算螺旋线的参数
local parameA,parameB,parameAngle = 0.5,0.5,5*math.pi
local spiralHeightAdded,intervalAngle = 0.1,0.05
local tempX,tempY,tempZ = 0,0,0
local STORM_BASETIME,STORM_LEFTTIME,STORM_RIGHTTIME = 60,0,0
local stormChecktime,stormNextTime = 0

---初始化函数
function PlantFlowerMgr:Init()
    print('[PlantFlowerMgr] Init()')
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--节点引用
function PlantFlowerMgr:NodeRef()
    this.Nodes = {}
    for i = 1, 8, 1 do
        table.insert(this.Nodes, world.FlowerLand['Node' .. i])
    end
    --print(table.dump(this.Nodes))
end

--数据变量声明
function PlantFlowerMgr:DataInit()
    if this.realFlower == nil then
        this.realFlower = {}
    end
	stormNextTime = STORM_BASETIME+math.random(STORM_LEFTTIME,STORM_RIGHTTIME)
	print(Config.FlowerPoint[1][1].Pos)
	print(#Config.FlowerPoint)
end

--节点事件绑定
function PlantFlowerMgr:EventBind()
    world.OnPlayerRemoved:Connect(
        function(player)
            OnPlayerDisconnect(player)
        end
    )
end

---Update函数
function PlantFlowerMgr:Update(dt)
	stormChecktime = stormChecktime + dt
	if stormChecktime > stormNextTime then
		this:SetCombine()
		stormChecktime = 0
		stormNextTime = STORM_BASETIME+math.random(STORM_LEFTTIME,STORM_RIGHTTIME)
	end
end

function OnPlayerDisconnect(player)
    local _subRealFlower = {}
    for k, v in ipairs(this.realFlower) do
        --print(v.User)
        if v.User == player.UserId then
            table.insert(_subRealFlower, v)
        end
    end
    --print('[PlantFlowerMgr] OnPlayerDisconnect', table.dump(_subRealFlower))
    for k, v in ipairs(_subRealFlower) do
		--print(v.Obj)
        v.Obj:Destroy()
        table.removebyvalue(this.realFlower, v)
    end
end

function PlantFlowerMgr:PlantFlowerEventHandler(_player, _data)
    table.insert(this.realFlower, _data)
end

function PlantFlowerMgr:DeleteFlowerEventHandler(_player, _uuid)
	for k,v in ipairs(this.realFlower) do
		if v.UUID == _uuid then
			table.removebyvalue(this.realFlower,v)
			v.Obj:Destroy()
			break
		end
	end
end

function PlantFlowerMgr:SetCombine()
    print('[PlantFlowerMgr] SetCombine()', #this.realFlower)
	invoke(function()
		PlaySetCombineFX()
	end,0)
end

function ReCombine()
	--Config.FlowerPoint[1][1].Pos
	local _points = Config.FlowerPoint[math.random(1,#Config.FlowerPoint)]
	for k, v in ipairs(this.realFlower) do
        --print(k..'--------------------------------------')
        --print(math.fmod(k,8))
        --print(math.modf(k/8)+1)
        v.Obj:SetParentTo(
            this.Nodes[math.fmod(k - 1, 8) + 1],
            _points[math.modf((k - 1) / 8) + 1].Pos,
            EulerDegree(0, 0, 0)
        )
    end
end

function PlaySetCombineFX()
	local spiralPoint = {}
	local drawAngle = 0
	while drawAngle <= parameAngle do
		table.insert(spiralPoint,1,GetPointByAngle(drawAngle))
		drawAngle = drawAngle + intervalAngle
	end
	world.FlowerLand.FX_WIND.Visible = true
	world.FlowerLand.FX_ASH.Visible = true
	for k,v in ipairs(spiralPoint) do
		world.FlowerLand.FX_WIND.LocalPosition = v
		wait(intervalAngle)
	end
	world.FlowerLand.FX_WIND.Visible = false
	world.FlowerLand.FX_ASH.Visible = false
	local _fx = world:CreateInstance('FX_Blast_effect_02','fx',world.FlowerLand,Vector3.Zero,EulerDegree(0,0,0))
	_fx.LocalPosition = Vector3.Zero
	ReCombine()
	NetUtil.Broadcast('LightHitEvent')
	wait(1)
	_fx:Destroy()
end

function GetPointByAngle(drawAngle)
	tempX = (parameA + parameB * drawAngle)*math.cos(drawAngle)
	tempZ = (parameA + parameB * drawAngle)*math.sin(drawAngle)
	tempY = spiralHeightAdded*drawAngle
	return Vector3(tempX,0.9,tempZ)
end

function PlantFlowerMgr:WaterEventHandler(_userId,_pos)
	NetUtil.Broadcast('WaterEvent',_pos)
end

return PlantFlowerMgr
