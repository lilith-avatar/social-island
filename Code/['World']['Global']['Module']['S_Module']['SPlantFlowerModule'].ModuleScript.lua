-- @module  MonsterBattle
-- @copyright Lilith Games, Avatar Team
-- @author Lin
local SPlantFlower,this = ModuleUtil.New('SPlantFlower',ServerBase)

---初始化函数
function SPlantFlower:Init()
	this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--节点引用
function SPlantFlower:NodeRef()
	this.Nodes = {}
	for i=1,8,1 do
		table.insert(this.Nodes,world.FlowerLand['Node'..i])
	end
	--print(table.dump(this.Nodes))
end

--数据变量声明
function SPlantFlower:DataInit()
	if this.realFlower == nil then
		this.realFlower = {}
	end
	this.Points = {Vector3(1,0,0),Vector3(2,0,0),Vector3(3,0,0),Vector3(4,0,0),Vector3(5,0,0),Vector3(6,0,0),Vector3(7,0,0)}
	print(table.dump(this.Points))
end

--节点事件绑定
function SPlantFlower:EventBind()
	world.OnPlayerRemoved:Connect(function(player)
		OnPlayerDisconnect(player)
	end)
end

function OnPlayerDisconnect(player)
	local _subRealFlower = {}
	for k,v in ipairs(this.realFlower) do
		print(v.User)
		if v.User == player.UserId then
			table.insert(v,_subRealFlower)
		end
	end
	print(table.dump(_subRealFlower))
	for k,v in ipairs(_subRealFlower) do
		v.Obj:Destory()
		table.removebyvalue(this.realFlower,v)
	end
end

---Update函数
function SPlantFlower:Update()
end

function SPlantFlower:PlantFlowerEventHandler(_player,_data)
	table.insert(this.realFlower,_data)
	--SetCombine()
end

function SPlantFlower:SetCombine()
	print(#this.realFlower)
	--local _all = #this.realFlower
	for k,v in ipairs(this.realFlower) do
		--print(k..'--------------------------------------')
		--print(math.fmod(k,8))
		--print(math.modf(k/8)+1)
		v.Obj:SetParentTo(this.Nodes[math.fmod(k-1,8)+1],this.Points[math.modf((k-1)/8)+1],EulerDegree(0,0,0))
	end
end

return SPlantFlower