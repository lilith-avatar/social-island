-- @module  MonsterBattle
-- @copyright Lilith Games, Avatar Team
-- @author Lin

local PlantFlower, this = ModuleUtil.New('PlantFlower', ClientBase)
local POCKET_OUT_TIME = 1 --拿种子动画时间
local PUT_DOWN_TIME = 0.5 --放置种子动画时间
local GAIN_RANGE = 3 --收获范围，浇花范围
local MAX_FLOWER = 50 --最大可栽种数量
local WATER_CD = 5 --浇花CD
local WATER_SAVE_CD = 5 --浇花减少的CD

local waterCheckTime = WATER_CD
local isInStorm = false

function PlantFlower:Init()
    print('[PlantFlower] Init()')
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
	this.finishFlowerData = {}
end

--节点事件绑定
function PlantFlower:EventBind()
    localPlayer.OnCollisionBegin:Connect(CheckFlowerLandBegin)
    localPlayer.OnCollisionEnd:Connect(CheckFlowerLandEnd)
    this.PlantGUI.PlantButton1.OnClick:Connect(function() if CanPlantFlower() then OnPlant(nil,1) end end)
	this.PlantGUI.PlantButton2.OnClick:Connect(function() if CanPlantFlower() then OnPlant(nil,2) end end)
	this.PlantGUI.PlantButton3.OnClick:Connect(function() if CanPlantFlower() then OnPlant(nil,3) end end)
	this.PlantGUI.GainButton.OnClick:Connect(OnGain)
	this.PlantGUI.WaterButton.OnClick:Connect(OnWater)
end

function PlantFlower:OnPlayerJoinEventHandler()
    wait(3)
    --print('[PlantFlower]', table.dump(this.playerData.flowerLis))
    for k, v in ipairs(this.playerData.flowerLis) do
        OnPlant(v)
    end
end

function PlantFlower:Update(dt, tt)
	waterCheckTime = waterCheckTime + dt
	this.PlantGUI.WaterButton.Clickable = waterCheckTime >= WATER_CD
end

function CheckFlowerLandBegin(_hitObj, _hitPoint, hitNormal)
    if _hitObj.Name == 'FlowerLand' then
        this.PlantGUI.PlantButton1.Visible = true
		this.PlantGUI.PlantButton2.Visible = true
		this.PlantGUI.PlantButton3.Visible = true
		this.PlantGUI.GainButton.Visible = true
		this.PlantGUI.WaterButton.Visible = true
	elseif _hitObj.Name == 'WindRange' then
		invoke(function()
			localPlayer.LinearVelocity = Vector3(0,20,0)
			wait(0.1)
			localPlayer.GravityScale = 0
			isInStorm = true
		end)
    end	
end

function CheckFlowerLandEnd(_hitObj, _hitPoint, hitNormal)
    if _hitObj and _hitObj.Name == 'FlowerLand' then
        this.PlantGUI.PlantButton1.Visible = false
		this.PlantGUI.PlantButton2.Visible = false
		this.PlantGUI.PlantButton3.Visible = false
		this.PlantGUI.GainButton.Visible = false
		this.PlantGUI.WaterButton.Visible = false
	elseif _hitObj.Name == 'WindRange' then
		localPlayer.GravityScale = 2
		isInStorm = false
    end
end

--种一个花
function OnPlant(_longData,_level)
    invoke(
        function()
            local _pos = Vector3(localPlayer.Position.x, -100000, localPlayer.Position.z)
				+localPlayer.Forward + math.randomOnUnitSphere()*0.5
            local _flower =
                world:CreateInstance(
                'FlowerPre',
                'Flower',
                world.FlowerLand,
                _pos,
                EulerDegree(0, math.random(0, 360), 0)
            )
            if _longData then
                _flower.LocalPosition = Vector3(_longData.PosX, _longData.PosY, _longData.PosZ)
                local _data = {}
                _data.LocalPosition = _longData.LocalPosition
                _data.CDtime = _longData.CDtime
                _data.Obj = _flower
                _data.StartTime = _longData.StartTime
                _data.User = localPlayer.UserId
				_data.HaveGet = _longData.HaveGet
				_data.UUID = _longData.UUID
				_data.Level = _longData.Level
				_data.Type = _longData.Type
                table.insert(this.flowerData, _data)
                NetUtil.Fire_S('PlantFlowerEvent', localPlayer.UserId, _data)
            else
				--动画播放
				NetUtil.Fire_C('SetPlayerControllableEvent',localPlayer,false)
				this.PlantGUI:SetActive(false)
				localPlayer.Avatar:PlayAnimation('HTPocketOut', 2, 1, 0, true, false, 1)
				wait(POCKET_OUT_TIME)
				localPlayer.Avatar:PlayAnimation('PutDownPlate', 2, 1, 0, true, false, 1)
				wait(PUT_DOWN_TIME)
				NetUtil.Fire_C('SetPlayerControllableEvent',localPlayer,true)
				this.PlantGUI:SetActive(true)
			
                _flower.LocalPosition = Vector3(_flower.LocalPosition.x, 0.4, _flower.LocalPosition.z)
                local _data = {}
                _data.LocalPosition = _flower.LocalPosition
                _data.CDtime = Config.FlowerInfo[_level].Time
                _data.Obj = _flower
                _data.StartTime = os.time()
                _data.User = localPlayer.UserId
				_data.HaveGet = false
				_data.UUID = UUID()
				_data.Level = Config.FlowerInfo[_level].Level
				_data.Type = -1
                table.insert(this.flowerData, _data)
                NetUtil.Fire_S('PlantFlowerEvent', localPlayer.UserId, _data)

                local _flower = {}
                _flower.StartTime = _data.StartTime
                _flower.CDtime = _data.CDtime
                _flower.PosX = _data.LocalPosition.x
                _flower.PosY = _data.LocalPosition.y
                _flower.PosZ = _data.LocalPosition.z
				_flower.HaveGet = _data.HaveGet
				_flower.UUID = _data.UUID
				_flower.Level = _data.Level
                _flower.Type = _data.Type
                table.insert(this.playerData.flowerLis, _flower)
                SaveData()
            end
        end
    )
end

function CheckFlowerTime()
    while true do
        if #this.flowerData > 0 then
            local _subLis = {}
            for k, v in ipairs(this.flowerData) do
                local _time = v.CDtime - os.time() + v.StartTime
                v.Obj.SurfaceGUI.TimeText.Text = _time
                --v.CDtime = v.CDtime - 1
                if _time < 0 then
                    table.insert(_subLis, v)
                end
            end
            if #_subLis > 0 then
                for k, v in ipairs(_subLis) do
                    --v.Obj:Destroy()
					v.Obj.Leaf.Visible = false
					invoke(function()
						FlowerFx(v.Obj)
					end)
					if not v.HaveGet then
						local _getFx = world:CreateInstance('FX_Environment_effect_13','fx_get',
						v.Obj,
						Vector3.Zero,
						EulerDegree(0,0,0))
						_getFx.LocalPosition = Vector3.Zero
					end
					if v.Type == -1 then
						local _rtype = math.random(1,3)
						v.Type = _rtype
						GetLongDataByUUID(v.UUID).Type =_rtype
						SaveData()
					end
					--print(v.Type)
					v.Obj['Flower'..v.Type].Visible = true
                    v.Obj.SurfaceGUI.TimeText.Visible = false
					table.insert(this.finishFlowerData,v)
                    table.removebyvalue(this.flowerData, v)
                end
            end
        end
        wait(1)
    end
end

function FlowerFx(_parent)
	local _fx = world:CreateInstance('FX_Buff_effect_01','fx',_parent,Vector3.Zero,EulerDegree(0,0,0))
	_fx.LocalPosition = Vector3.Zero
	DelayDestroy(_fx,1.5)
end

--收获
function OnGain()
	--print(#this.finishFlowerData)
	--播放动画
	NetUtil.Fire_C('SetPlayerControllableEvent',localPlayer,false)
	this.PlantGUI:SetActive(false)
	localPlayer.Avatar:PlayAnimation('PickUpLight', 2, 1, 0, true, false, 1)
	wait(1)
	NetUtil.Fire_C('SetPlayerControllableEvent',localPlayer,true)
	this.PlantGUI:SetActive(true)
	
	--修改数据
	local _distance = -1
	for k,v in ipairs(this.finishFlowerData) do
		_distance = (v.Obj.Position - localPlayer.Position).Magnitude
		--print(_distance)
		if _distance <= GAIN_RANGE and v.HaveGet == false then
			DelayDestroy(v.Obj.fx_get,0)
			v.HaveGet = true
			GetLongDataByUUID(v.UUID).HaveGet = true
			print('[PlantFlower] 获得奖励')
		end
	end
	SaveData()
end

--浇水
function OnWater()
	if true and waterCheckTime > WATER_CD then --TODO:判断是否手持花洒
		NetUtil.Fire_C('SetPlayerControllableEvent',localPlayer,false)
		this.PlantGUI:SetActive(false)
		local _waterFx = world:CreateInstance('FX_WATER','fx_water',
						world.FlowerLand,
						Vector3.Zero,
						EulerDegree(0,0,0))
		_waterFx.Position = localPlayer.Position
		DelayDestroy(_waterFx,2.7)
		localPlayer.Avatar:PlayAnimation('HTWateringStart', 2, 1, 0, true, false, 0.2)
		wait(0.2)
		localPlayer.Avatar:PlayAnimation('HTWateringLoop', 2, 1, 0, true, true, 2)
		wait(2)
		localPlayer.Avatar:PlayAnimation('HTWateringEnd', 2, 1, 0, true, false, 0.5)
		waterCheckTime = 0
		NetUtil.Fire_C('SetPlayerControllableEvent',localPlayer,true)
		NetUtil.Fire_S('WaterEvent',localPlayer.UserId,localPlayer.Position)
		this.PlantGUI:SetActive(true)
	end
	--NetUtil.Fire_S
end

function PlantFlower:WaterEventHandler(_pos)
	local _changeData = nil
	for k, v in ipairs(this.flowerData) do
        _distance = (v.Obj.Position - _pos).Magnitude
		--print(_distance)
		if _distance <= GAIN_RANGE and v.HaveGet == false then
			v.StartTime = v.StartTime - WATER_SAVE_CD
			_changeData = GetLongDataByUUID(v.UUID)
			_changeData.StartTime = _changeData.StartTime - WATER_SAVE_CD
			invoke(function()
				v.Obj.SurfaceGUI.SubTimeText.Text = '-'..WATER_SAVE_CD
				v.Obj.SurfaceGUI.SubTimeText.Visible = true
				wait(0.3)
				v.Obj.SurfaceGUI.SubTimeText.Visible = false
			end)
		end
	end
end

--删除花
function DeleteFlowerByUUID(_uuid)
	for k,v in ipairs(this.finishFlowerData) do
		if v.UUID == _uuid then
			table.removebyvalue(this.finishFlowerData,v)
			break
		end
	end
	for k,v in ipairs(this.playerData.flowerLis) do
		if v.UUID == _uuid then
			table.removebyvalue(this.playerData.flowerLis,v)
			break
		end
	end
	NetUtil.Fire_S('DeleteFlowerEvent', localPlayer.UserId, _uuid)
end

function CanPlantFlower()
	local _subLis = {}
	for k,v in ipairs(this.playerData.flowerLis) do
		if v.CDtime - os.time() + v.StartTime < 0 and v.HaveGet then
			table.insert(_subLis,v)
		end
	end
	table.sort(_subLis,function(a,b) return (a.StartTime < b.StartTime)end)
	
	for i = 1,math.min(#_subLis,math.max(#this.playerData.flowerLis - MAX_FLOWER,0)),1 do
		--print(table.dump(_subLis[i]))
		DeleteFlowerByUUID(_subLis[i].UUID)
	end
	
	if #this.playerData.flowerLis - #_subLis >= MAX_FLOWER then
		print('[PlantFlower] 超过可种植上限，请收获部分植物再进行操作')
		return false
	else
		print('[PlantFlower] 可种植')
		return true
	end
end

function GetLongDataByUUID(_uuid)
	for k,v in ipairs(this.playerData.flowerLis) do
		if v.UUID == _uuid then
			return v
		end
	end
	return nil
end

function PlantFlower:LightHitEventHandler()
	if this.PlantGUI.GainButton.Visible then
		PlantFlower:BoomAction()
	end
	
	if isInStorm then --防止飞天
		localPlayer.GravityScale = 2
	end
end

function PlantFlower:BoomAction()
	localPlayer.LinearVelocity = Vector3(math.random(-20,20),20,math.random(-20,20))
	wait(1)
	localPlayer.LinearVelocity = Vector3(0,0,0)
end

function DelayDestroy(_obj,_delayTime)
	invoke(function()
		wait(_delayTime)
		_obj:Destroy()
	end)
end

-- 以下为数据交互函数
-- TODO: (长期数据沿用Monster，建议之后的长期存储沿用)
function PlantFlower:LoadMDataBackEventHandler(_userId, _playerData)
    --print(_userId == localPlayer.UserId)
    if _userId == localPlayer.UserId then
        --print('[PlantFlower]', table.dump(_playerData))
        this.playerData = _playerData
		--print(table.dump(_playerData.flowerLis))
    end
end

-- 保存长期数据
function SaveData()
    --print(table.dump(this.playerData))
    NetUtil.Fire_S('SaveMDataEvent', localPlayer.UserId, this.playerData)
end

return PlantFlower
