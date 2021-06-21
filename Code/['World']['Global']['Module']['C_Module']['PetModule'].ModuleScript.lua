--- 宠物模块
--- @module Pet Module
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local Pet, this = ModuleUtil.New('Pet', ClientBase)

--宠物物体
local petOBJ = nil

--移动路径
local moveTable = {}

--移动步速
local moveStep = 0

--宠物数据
local petData = {
    name = '',
    state = 0,
    animTable = {}
}

--宠物状态枚举
local petStateEum = {
    DISABLE = 0,
    IDLE = 1,
    TOIDLE = 2,
    MOVE = 3,
    TOMOVE = 4,
    FASTMOVE = 5,
    TELEPORT = 6,
    RIDE = 7
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
    --print('[Pet] Init()')
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
    Navigation.SetWalkableRoots({world.Scenes.grass, world.Scenes.cloud})
    Navigation.SetObstacleRoots(
        {
            world.Scenes.stone,
            world.Tree
        }
    )
    Navigation.SetAgent(1, 0.1, 0.2, 30.0)
    Navigation.SetUpdateDelay(0)

    --[[]]
    localPlayer:GetWaypoints(Vector3.Zero, Vector3.Zero)
end

--- 节点事件绑定
function Pet:EventBind()
    gui.Panel.BgImg.ConfirmBtn.OnClick:Connect(
        function()
            this:NamedPet(gui.Panel.BgImg.InputText.Text)
            this:InstancePet(Data.Player.petID)
            this:GetPetData(Data.Player.petID)
            gui:SetActive(false)
        end
    )

    for k, v in pairs(petStateEum) do
        LeaveStateFunc[v] = function()
            --print('Leave', v)
            this['LeaveState' .. v](self)
        end
        EnterStateFunc[v] = function()
            LeaveStateFunc[v]()
            petData.state = v
            --print('Enter', v)
            this['EnterState' .. v](self)
        end
        UpdateStateFunc[v] = function(dt)
            this['UpdateState' .. v](self, dt)
        end
    end
end

--- 弹出宠物命名面板
function Pet:OpenNamedPetUI(_id)
    Data.Player.petID = _id
    LanguageUtil.SetText(gui.Panel.BgImg.DesText, 'GuiText_Txt_PetGui_6', true, 20, 40)
    gui:SetActive(true)
end

--- 宠物命名
function Pet:NamedPet(_name)
    if _name ~= '' and _name ~= nil then
        Data.Player.petName = ':' .. _name
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
        localPlayer.Independent,
        localPlayer.Position - localPlayer.Forward * 2 + Vector3(0, 1, 0)
    )
    --this:GetPetData(_id)
    this:GetMoveTable(localPlayer.Position - localPlayer.Forward)
end

-- 获取移动点
function Pet:GetMoveTable(_pos)
    moveStep = 1
    local result = 0
    moveTable, result = petOBJ:GetWaypoints(petOBJ.Position, _pos, 0.1, 1, 3)
    if result > 2 then
    ----print('寻路失败', result, petOBJ, petData.state)
    end
    print('寻路成功', result)
end

--- 获取宠物数据
function Pet:GetPetData(_id)
    petOBJ.NameGUI.Panel.NameBGText.Text =
        string.format(LanguageUtil.GetText(Config.GuiText.PetGui_7.Txt), localPlayer.Name) .. Data.Player.petName
    petOBJ.NameGUI.Panel.NameText.Text =
        string.format(LanguageUtil.GetText(Config.GuiText.PetGui_7.Txt), localPlayer.Name) .. Data.Player.petName

    if Config.Pet[_id].IsNew then
        petData.animTable = table.MergeTables(Config.Pet[_id].FastMoveAnimation, Config.Pet[_id].IdleAnimation)
        petData.animTable = table.MergeTables(petData.animTable, Config.Pet[_id].MoveAnimation)
        if Config.Pet[_id].ToIdleAnimation ~= '' then
            table.insert(petData.animTable, Config.Pet[_id].ToIdleAnimation)
        end
        if Config.Pet[_id].ToMoveAnimation ~= '' then
            table.insert(petData.animTable, Config.Pet[_id].ToMoveAnimation)
        end
        --print(table.dump(petData.animTable))
        for k, v in pairs(petData.animTable) do
            local animaion =
                ResourceManager.GetAnimation('Mesh/Pet/' .. Config.Pet[_id].AnimationPath .. '/Animation/' .. v)
            petOBJ.AnimatedMesh:ImportAnimation(animaion)
        end
    end
    EnterStateFunc[petStateEum.IDLE]()
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
            Config.Pet[Data.Player.petID].IdleAnimation[math.random(#Config.Pet[Data.Player.petID].IdleAnimation)],
            2,
            1,
            0.1,
            true,
            true,
            1
        )
        petOBJ:MoveTowards(Vector2.Zero)
    end
    --TOIDLE
    function Pet:EnterState2()
        petOBJ:SetActive(true)
        if Config.Pet[Data.Player.petID].ToIdleAnimation ~= '' then
            petOBJ.AnimatedMesh:PlayAnimation(Config.Pet[Data.Player.petID].ToIdleAnimation, 2, 1, 0.1, true, true, 1)
            invoke(
                function()
                    EnterStateFunc[petStateEum.IDLE]()
                end,
                0.5
            )
        else
            EnterStateFunc[petStateEum.IDLE]()
        end
    end
    --MOVE
    function Pet:EnterState3()
        petOBJ:SetActive(true)
        local s = Config.Pet[Data.Player.petID].MoveAnimation[math.random(#Config.Pet[Data.Player.petID].MoveAnimation)]
        petOBJ.AnimatedMesh:PlayAnimation(s, 2, 1, 0.1, true, true, 1)
        petOBJ.WalkSpeed = Config.Pet[Data.Player.petID].DefMoveSpeed
        this:GetMoveTable(localPlayer.Position - localPlayer.Forward)
    end
    --TOMOVE
    function Pet:EnterState4()
        petOBJ:SetActive(true)
        if Config.Pet[Data.Player.petID].ToMoveAnimation ~= '' then
            petOBJ.AnimatedMesh:PlayAnimation(Config.Pet[Data.Player.petID].ToMoveAnimation, 2, 1, 0.1, true, true, 1)
            invoke(
                function()
                    EnterStateFunc[petStateEum.MOVE]()
                end,
                0.5
            )
        else
            EnterStateFunc[petStateEum.MOVE]()
        end
    end
    --FASTMOVE
    function Pet:EnterState5()
        petOBJ:SetActive(true)
        if #Config.Pet[Data.Player.petID].FastMoveAnimation > 0 then
            petOBJ.AnimatedMesh:PlayAnimation(
                Config.Pet[Data.Player.petID].FastMoveAnimation[
                    math.random(#Config.Pet[Data.Player.petID].FastMoveAnimation)
                ],
                2,
                1,
                0.1,
                true,
                true,
                1
            )
        else
            petOBJ.AnimatedMesh:PlayAnimation(
                Config.Pet[Data.Player.petID].MoveAnimation[math.random(#Config.Pet[Data.Player.petID].MoveAnimation)],
                2,
                1,
                0.1,
                true,
                true,
                Config.Pet[Data.Player.petID].FastMoveSpeed / Config.Pet[Data.Player.petID].DefMoveSpeed
            )
        end
        petOBJ.WalkSpeed = Config.Pet[Data.Player.petID].FastMoveSpeed
        this:GetMoveTable(localPlayer.Position - localPlayer.Forward)
    end
    --TELEPORT
    function Pet:EnterState6()
        petOBJ.Position = localPlayer.Position - localPlayer.Forward + Vector3(0, 1, 0)
    end
    --RIDE
    function Pet:EnterState7()
    end
end

-- 状态持续触发
do
    --DISABLE
    function Pet:UpdateState0()
    end
    --IDLE
    function Pet:UpdateState1()
        if (petOBJ.Position - localPlayer.Position).Magnitude > 5 then
            EnterStateFunc[petStateEum.TOMOVE]()
        end
    end
    --TOIDLE
    function Pet:UpdateState2()
    end
    --MOVE
    function Pet:UpdateState3()
        if (petOBJ.Position - localPlayer.Position).Magnitude > 8 then
            EnterStateFunc[petStateEum.FASTMOVE]()
        end
        this:PetMove()
    end
    --TOMOVE
    function Pet:UpdateState4()
    end
    --FASTMOVE
    function Pet:UpdateState5()
        if (petOBJ.Position - localPlayer.Position).Magnitude > 20 then
            EnterStateFunc[petStateEum.TELEPORT]()
        end
        this:PetMove()
    end
    --TELEPORT
    function Pet:UpdateState6()
        if (petOBJ.Position - localPlayer.Position).Magnitude < 5 then
            EnterStateFunc[petStateEum.IDLE]()
        elseif (petOBJ.Position - localPlayer.Position).Magnitude < 15 then
            EnterStateFunc[petStateEum.MOVE]()
        end
    end
    --RIDE
    function Pet:UpdateState7()
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
    --TOIDLE
    function Pet:LeaveState2()
    end
    --MOVE
    function Pet:LeaveState3()
    end
    --TOMOVE
    function Pet:LeaveState4()
    end
    --FASTMOVE
    function Pet:LeaveState5()
    end
    --TELEPORT
    function Pet:LeaveState6()
    end
    --RIDE
    function Pet:LeaveState7()
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
            EnterStateFunc[petStateEum.TOIDLE]()
        end
    else
        petOBJ:MoveTowards(Vector2.Zero)
        EnterStateFunc[petStateEum.TOIDLE]()
    end
end

function Pet:CUseItemEventHandler(_id)
    if _id == 4004 then
        this:OpenNamedPetUI(tonumber('10' .. math.random(7)))
    end
end

--- 长期存储成功读取后
function Pet:LoadPlayerDataSuccessEventHandler(_hasData)
    --print('[Pet] 读取长期存储成功')
    if _hasData and Data.Player.petID ~= 0 then
        this:InstancePet(Data.Player.petID)
        this:GetPetData(Data.Player.petID)
    end
end

function Pet:Update(dt)
    if petOBJ then
        UpdateStateFunc[petData.state](dt)
    end
end

return Pet
