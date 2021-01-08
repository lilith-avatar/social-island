-- @module  MonsterBattle
-- @copyright Lilith Games, Avatar Team
-- @author Lin

local PlantFlower, this = ModuleUtil.New('PlantFlower', ClientBase)

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
end

--节点事件绑定
function PlantFlower:EventBind()
    localPlayer.OnCollisionBegin:Connect(CheckFlowerLandBegin)
    localPlayer.OnCollisionEnd:Connect(CheckFlowerLandEnd)
    this.PlantGUI.PlantButton.OnClick:Connect(OnPlant)
end

function PlantFlower:OnPlayerJoinEventHandler()
    wait(3)
    --print('[PlantFlower]', table.dump(this.playerData.flowerLis))
    for k, v in ipairs(this.playerData.flowerLis) do
        OnPlant(v)
    end
end

function PlantFlower:Update(dt, tt)
end

function CheckFlowerLandBegin(_hitObj, _hitPoint, hitNormal)
    if _hitObj.Name == 'FlowerLand' then
        this.PlantGUI.PlantButton.Visible = true
    end
end

function CheckFlowerLandEnd(_hitObj, _hitPoint, hitNormal)
    if _hitObj and _hitObj.Name == 'FlowerLand' then
        this.PlantGUI.PlantButton.Visible = false
    end
end

--种一个花
function OnPlant(_longData)
    invoke(
        function()
            local _pos = Vector3(localPlayer.Position.x, 0, localPlayer.Position.z)
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
                table.insert(this.flowerData, _data)
                NetUtil.Fire_S('PlantFlowerEvent', localPlayer.UserId, _data)
            else
                _flower.LocalPosition = Vector3(_flower.LocalPosition.x, 0.5, _flower.LocalPosition.z)
                local _data = {}
                _data.LocalPosition = _flower.LocalPosition
                _data.CDtime = math.random(100, 300)
                _data.Obj = _flower
                _data.StartTime = os.time()
                _data.User = localPlayer.UserId
                table.insert(this.flowerData, _data)
                NetUtil.Fire_S('PlantFlowerEvent', localPlayer.UserId, _data)

                local _flower = {}
                _flower.Id = 1
                _flower.StartTime = _data.StartTime
                _flower.CDtime = _data.CDtime
                _flower.PosX = _data.LocalPosition.x
                _flower.PosY = _data.LocalPosition.y
                _flower.PosZ = _data.LocalPosition.z
                --_flower.Position = _data.Position
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
                    v.Obj.Flower.Visible = true
                    v.Obj.SurfaceGUI.TimeText.Visible = false
                    table.removebyvalue(this.flowerData, v)
                end
            end
        end
        wait(1)
    end
end

-- 以下为数据交互函数
-- TODO: (长期数据沿用Monster，建议之后的长期存储沿用)
function PlantFlower:LoadMDataBackEventHandler(_userId, _playerData)
    --print(_userId == localPlayer.UserId)
    if _userId == localPlayer.UserId then
        print('[PlantFlower]', table.dump(_playerData))
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
