--- 宠物模块
--- @module Pet Module
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local Pet, this = ModuleUtil.New('Pet', ClientBase)

--宠物ID
local petID = 0

--宠物物体
local petOBJ = nil

--移动路径
local moveTable = {}

--移动步速
local moveStep = 0

--宠物数据
local petData = {
    name = '',
    strength = 0,
    speed = 0,
    state = 0
}

--宠物状态枚举
local petStateEum = {
    DISABLE = 0,
    IDLE = 1,
    MOVE = 2,
    TELEPORT = 3,
    RIDE = 4
}

local gui

-- 进入状态触发
local EnterStateFunc = {}
-- 状态持续触发
local UpdateStateFunc = {}
-- 离开状态触发
local LeaveStateFunc = {}

--- 初始化
function Pet:Init()
    print('[Pet] Init()')
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
    Navigation.SetWalkableRoots(world.Scenes.Terrain:GetChildren())
    Navigation.SetObstacleRoots(table.MergeTables(world.Stone:GetChildren(), world.Tree:GetChildren()))
    Navigation.SetAgent(1, 0.1, 0.2, 30.0)
    Navigation.SetUpdateDelay(0)
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

    for k, v in pairs(petStateEum) do
        LeaveStateFunc[v] = function()
            this['LeaveState' .. v](self)
        end
        EnterStateFunc[v] = function()
            LeaveStateFunc[v]()
            petData.state = v
            this['EnterState' .. v](self)
        end
        UpdateStateFunc[v] = function(dt)
            this['UpdateState' .. v](self, dt)
        end
    end
end

--- 弹出宠物命名面板
function Pet:OpenNamedPetUI(_id)
    petID = _id
    gui:SetActive(true)
end

--- 宠物命名
function Pet:NamedPet(_name)
    if _name ~= '' and _name ~= nil then
        petData.name = ':' .. _name
    else
        _name = ''
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
        localPlayer.Position - localPlayer.Forward * 2 + Vector3(0, 1, 0)
    )
    --this:GetPetData(_id)
end

-- 获取移动点
function Pet:GetMoveTable(_pos)
    moveStep = 1
    local result = 0
    moveTable, result = petOBJ:GetWaypoints(petOBJ.Position, _pos, 0.1, 1, 3)
    if result > 2 then
        --print('寻路失败', result, petOBJ, petData.state)
    end
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
    petOBJ.NameGUI.Panel.NameBGText.Text = localPlayer.Name .. '的宠物' .. petData.name
    petOBJ.NameGUI.Panel.NameText.Text = localPlayer.Name .. '的宠物' .. petData.name
    petOBJ.NameGUI.Panel.TypeBGText.Text =
        Config.PetEntry1[petEntry1ID].Name .. Config.PetEntry2[petEntry2ID].Name .. Config.Pet[_id].Name
    petOBJ.NameGUI.Panel.TypeText.Text =
        Config.PetEntry1[petEntry1ID].Name .. Config.PetEntry2[petEntry2ID].Name .. Config.Pet[_id].Name
    petData.state = 1
end

-- 进入状态触发
do
    --DISABLE
    function Pet:EnterState0()
        petOBJ:SetActive(false)
        petOBJ:MoveTowards(Vector2.Zero)
    end
    --IDLE
    function Pet:EnterState1()
        petOBJ:SetActive(true)
        petOBJ.AnimatedMesh:PlayAnimation(
            Config.Animal[petID].IdleAnimationName[math.random(#Config.Animal[petID].IdleAnimationName)],
            2,
            1,
            0.1,
            true,
            true,
            1
        )
        petOBJ:MoveTowards(Vector2.Zero)
    end
    --MOVE
    function Pet:EnterState2()
        petOBJ:SetActive(true)
        petOBJ.AnimatedMesh:PlayAnimation(
            Config.Animal[petID].MoveAnimationName[math.random(#Config.Animal[petID].MoveAnimationName)],
            2,
            1,
            0.1,
            true,
            true,
            1
        )
        petOBJ.WalkSpeed = Config.Animal[petID].DefMoveSpeed
        this:GetMoveTable(localPlayer.Position - localPlayer.Forward)
    end
    --TELEPORT
    function Pet:EnterState3()
        petOBJ.Position = localPlayer.Position - localPlayer.Forward + Vector3(0, 1, 0)
    end
    --RIDE
    function Pet:EnterState4()
    end
end

-- 状态持续触发
do
    --DISABLE
    function Pet:UpdateState0()
    end
    --IDLE
    function Pet:UpdateState1()
        if (petOBJ.Position - localPlayer.Position).Magnitude > 3 then
            EnterStateFunc[petStateEum.MOVE]()
        end
    end
    --MOVE
    function Pet:UpdateState2()
        if (petOBJ.Position - localPlayer.Position).Magnitude > 10 then
            EnterStateFunc[petStateEum.TELEPORT]()
        end
        this:PetMove()
    end
    --TELEPORT
    function Pet:UpdateState3()
        if (petOBJ.Position - localPlayer.Position).Magnitude < 3 then
            EnterStateFunc[petStateEum.IDLE]()
        elseif (petOBJ.Position - localPlayer.Position).Magnitude < 10 then
            EnterStateFunc[petStateEum.MOVE]()
        end
    end
    --RIDE
    function Pet:UpdateState4()
    end
end

-- 离开状态触发
do
    --DISABLE
    function Pet:LeaveState0()
    end
    --IDLE
    function Pet:LeaveState1()
    end
    --MOVE
    function Pet:LeaveState2()
    end
    --TELEPORT
    function Pet:LeaveState3()
    end
    --RIDE
    function Pet:LeaveState4()
    end
end

---宠物运动
function Pet:PetMove()
    if moveTable then
        if moveStep < #moveTable then
            local dir = (moveTable[moveStep + 1].Position - petOBJ.Position).Normalized
            dir.y = 0
            petOBJ:FaceToDir(dir, 2 * math.pi)
            petOBJ:MoveTowards(Vector2(dir.x, dir.z))
            if (petOBJ.Position - moveTable[moveStep + 1].Position).Magnitude < 1 then
                moveStep = moveStep + 1
            end
        else
            petOBJ:MoveTowards(Vector2.Zero)
            EnterStateFunc[petStateEum.IDLE]()
        end
    else
        petOBJ:MoveTowards(Vector2.Zero)
        EnterStateFunc[petStateEum.IDLE]()
    end
end

function Pet:Update(dt)
    if petOBJ then
        UpdateStateFunc[petData.state](dt)
    end
end

return Pet
