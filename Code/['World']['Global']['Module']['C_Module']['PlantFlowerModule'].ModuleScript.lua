-- @module  MonsterBattle
-- @copyright Lilith Games, Avatar Team
-- @author Lin

local PlantFlower, this = ModuleUtil.New('PlantFlower', ClientBase)

function PlantFlower:Init()
    print('PlantFlower:Init')
	this:NodeRef()
    this:DataInit()
    this:EventBind()
	invoke(CheckFlowerTime)
end

--节点引用
function PlantFlower:NodeRef()
	this.PlantGUI = localPlayer.Local.PlantGUI
end

--数据变量声明
function PlantFlower:DataInit()
	this.flowerData = {}
end

--节点事件绑定
function PlantFlower:EventBind()
	localPlayer.OnCollisionBegin:Connect(CheckFlowerLandBegin)
	localPlayer.OnCollisionEnd:Connect(CheckFlowerLandEnd)
	this.PlantGUI.PlantButton.OnClick:Connect(OnPlant)
end

function PlantFlower:Update(dt, tt)
	
end

function CheckFlowerLandBegin(_hitObj,_hitPoint,hitNormal)
	if _hitObj.Name == 'FlowerLand' then
		this.PlantGUI.PlantButton.Visible = true
	end
end

function CheckFlowerLandEnd(_hitObj,_hitPoint,hitNormal)
	if _hitObj and _hitObj.Name == 'FlowerLand' then
		this.PlantGUI.PlantButton.Visible = false
	end
end

--种一个花
function OnPlant()
	local _flower = world:CreateInstance('FlowerPre','Flower',world.FlowerLand,localPlayer.Position,EulerDegree(0,math.random(0,360),0))
	_flower.LocalPosition = _flower.LocalPosition + Vector3(0,0.3,0)
	local _data = {}
	_data.Position = _flower.Position
	_data.CDtime = math.random(100,300)
	_data.Obj = _flower
	table.insert(this.flowerData,_data)
	NetUtil.Fire_S("PlantFlowerEvent", localPlayer.UserId,_flower)
end

function CheckFlowerTime()
	while true do
		if #this.flowerData > 0 then
			local _subLis = {}
			for k,v in ipairs(this.flowerData) do
				v.Obj.SurfaceGUI.TimeText.Text = v.CDtime
				v.CDtime = v.CDtime - 1
				if v.CDtime < 0 then
					table.insert(_subLis,v)
				end
			end
			if #_subLis > 0 then
				for k,v in ipairs(_subLis) do
					--v.Obj:Destroy()
					v.Obj.Flower.Visible = true
					table.removebyvalue(this.flowerData,v)
				end
			end
		end
		wait(1)
	end
end

--以下为数据交互函数(长期数据沿用Monster，建议之后的长期存储沿用)
function PlantFlower:LoadMDataBackEventHandler(_userId, _playerData)
	if _userId == localPlayer.UserId then
		this.playerData = _playerData
		print(table.dump(_playerData.flowerLis))
	end
end

return PlantFlower