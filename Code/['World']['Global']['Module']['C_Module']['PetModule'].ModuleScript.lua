--- 宠物模块
--- @module Pet Module
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local Pet, this = ModuleUtil.New("Pet", ClientBase)

--宠物ID
local petID = 0

--宠物物体
local petOBJ = nil

--宠物数据
local petData = {
    name = "",
    strength = 0,
    speed = 0,
    state = 0
}

--宠物状态枚举
local petStateEum = {
    IDLE = 1,
    MOVE = 2,
    TELEPORT = 3,
    RACE = 4
}

local gui

--- 初始化
function Pet:Init()
    print("[Pet] Init()")
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--- 节点引用
function Pet:NodeRef()
    gui = localPlayer.Local.SpecialTopUI.PetNamedGUI
end

--- 数据变量初始化
function Pet:DataInit()
end

--- 节点事件绑定
function Pet:EventBind()
    gui.Panel.BgImg.ConfirmBtn.OnClick:Connect(
        function()
            this:NamedPet(gui.Panel.BgImg.InputText.Text)
            this:InstancePet(petID)
            this:GetPetData(petID)
            gui:SetActive(false)
        end
    )
end

--- 弹出宠物命名面板
function Pet:OpenNamedPetUI(_id)
    petID = _id
    gui:SetActive(true)
end

--- 宠物命名
function Pet:NamedPet(_name)
    if _name ~= "" and _name ~= nil then
        petData.name = ":" .. _name
    else
        _name = ""
    end
end

--- 宠物实例化
function Pet:InstancePet(_id)
    if petOBJ then
        petOBJ:Destroy()
    end
    petOBJ =
        world:CreateInstance(
        Config.Pet[_id].ArchetypeName,
        Config.Pet[_id].Name,
        world,
        localPlayer.Position - localPlayer.Forward * 3 + Vector3(0, 1, 0)
    )
    petOBJ.LinearVelocityController.TargetLinearVelocity = Vector3.Zero
    petOBJ.LinearVelocityController.Intensity = 0
    petOBJ.RotationController.Intensity = 0
    petOBJ.LinearVelocity = Vector3.Zero
    this:GetPetData(_id)
end

--- 获取宠物数据
function Pet:GetPetData(_id)
    local petEntry1ID, petEntry2ID = 0, 0
    local randomNum = math.random(600)
    local sum = 0
    for i = 1, #Config.PetEntry1 do
        sum = sum + Config.PetEntry1[i].Weight
        if randomNum < sum then
            petEntry1ID = i

            break
        end
    end
    randomNum = math.random(600)
    sum = 0
    for i = 1, #Config.PetEntry2 do
        sum = sum + Config.PetEntry2[i].Weight
        if randomNum < sum then
            petEntry2ID = i
            break
        end
    end
    petData.strength =
        math.random(Config.Pet[_id].StrengthRange[1], Config.Pet[_id].StrengthRange[2]) +
        math.random(Config.PetEntry1[petEntry1ID].StrengthRange[1], Config.PetEntry1[petEntry1ID].StrengthRange[2]) +
        math.random(Config.PetEntry2[petEntry2ID].StrengthRange[1], Config.PetEntry2[petEntry2ID].StrengthRange[2])
    petData.speed =
        math.random(Config.Pet[_id].SpeedRange[1], Config.Pet[_id].SpeedRange[2]) +
        math.random(Config.PetEntry1[petEntry1ID].SpeedRange[1], Config.PetEntry1[petEntry1ID].SpeedRange[2]) +
        math.random(Config.PetEntry2[petEntry2ID].SpeedRange[1], Config.PetEntry2[petEntry2ID].SpeedRange[2])
    petData.strength = petData.strength > 0 and petData.strength or 1
    petData.speed = petData.speed > 0 and petData.speed or 1
    petOBJ.NameGUI.Panel.NameBGText.Text = localPlayer.Name .. "的宠物:" .. petData.name
    petOBJ.NameGUI.Panel.NameText.Text = localPlayer.Name .. "的宠物:" .. petData.name
    petOBJ.NameGUI.Panel.TypeBGText.Text =
        Config.PetEntry1[petEntry1ID].Name .. Config.PetEntry2[petEntry2ID].Name .. Config.Pet[_id].Name
    petOBJ.NameGUI.Panel.TypeText.Text =
        Config.PetEntry1[petEntry1ID].Name .. Config.PetEntry2[petEntry2ID].Name .. Config.Pet[_id].Name
end

---宠物运动
function Pet:PetMove()
    if petOBJ and petData.state ~= petStateEum.RACE then
        if (petOBJ.Position - localPlayer.Position).Magnitude < 3 then
            this:ChangeAnimalState(petOBJ, petStateEum.IDLE)
        elseif (petOBJ.Position - localPlayer.Position).Magnitude < 10 then
            this:ChangeAnimalState(petOBJ, petStateEum.MOVE)
            petOBJ.LinearVelocityController.TargetLinearVelocity =
                petOBJ.RotationController.Forward * 12
        else
            this:ChangeAnimalState(petOBJ, petStateEum.TELEPORT)
        end
        petOBJ.RotationController.Forward = localPlayer.Position - petOBJ.Position
        petOBJ.RotationController.TargetRotation = EulerDegree(0, petOBJ.RotationController.Rotation.y, 0)
    end
end

---宠物运动状态改变
function Pet:ChangeAnimalState(petOBJ, _state)
    if petData.state ~= _state then
        petData.state = _state
        if _state == petStateEum.IDLE then
            petOBJ.AnimatedMesh:PlayAnimation(
                Config.Animal[petID].IdleAnimationName[math.random(#Config.Animal[petID].IdleAnimationName)],
                2,
                1,
                0.1,
                true,
                true,
                1
            )
            petOBJ.LinearVelocityController.TargetLinearVelocity = Vector3.Zero
            petOBJ.LinearVelocityController.Intensity = 0
            petOBJ.LinearVelocity = Vector3.Zero
            petOBJ.IsStatic = true
        elseif _state == petStateEum.MOVE then
            petOBJ.AnimatedMesh:PlayAnimation(
                Config.Animal[petID].MoveAnimationName[math.random(#Config.Animal[petID].MoveAnimationName)],
                2,
                1,
                0.1,
                true,
                true,
                12 / Config.Animal[petID].DefMoveSpeed
            )
            petOBJ.LinearVelocityController.Intensity = Config.Animal[petID].LVCtrlIntensity
            petOBJ.RotationController.Intensity = Config.Animal[petID].RotCtrlIntensity
            petOBJ.IsStatic = false
        elseif _state == petStateEum.TELEPORT then
            petOBJ.LinearVelocityController.TargetLinearVelocity = Vector3.Zero
            petOBJ.LinearVelocityController.Intensity = 0
            petOBJ.LinearVelocity = Vector3.Zero
            petOBJ.Position = localPlayer.Position - localPlayer.Forward * 3 + Vector3(0, 1, 0)
        elseif _state == petStateEum.RACE then
            petOBJ.LinearVelocityController.TargetLinearVelocity = Vector3.Zero
            petOBJ.LinearVelocityController.Intensity = 0
            petOBJ.RotationController.Intensity = 0
            petOBJ.LinearVelocity = Vector3.Zero
            petOBJ.IsStatic = true
        end
    end
end

function Pet:Update(dt)
    this:PetMove()
end

return Pet
