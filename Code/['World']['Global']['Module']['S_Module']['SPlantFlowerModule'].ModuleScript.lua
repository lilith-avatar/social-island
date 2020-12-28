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
end

---Update函数
function SPlantFlower:Update()
end

function SPlantFlower:PlantFlowerEventHandler(_userId,_flowerObj)
	table.insert(this.realFlower,_flowerObj)
	SetCombine()
end

function SetCombine()
	print(#this.realFlower)
	--local _all = #this.realFlower
	for k,v in ipairs(this.realFlower) do
		--print(k..'--------------------------------------')
		--print(math.fmod(k,8))
		--print(math.modf(k/8)+1)
		v:SetParentTo(this.Nodes[math.fmod(k-1,8)+1],this.Points[math.modf((k-1)/8)+1],EulerDegree(0,0,0))
	end
end

return SPlantFlower