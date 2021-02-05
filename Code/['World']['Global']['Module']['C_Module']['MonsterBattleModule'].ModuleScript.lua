-- @module  MonsterBattle
-- @copyright Lilith Games, Avatar Team
-- @author Lin

local MonsterBattle, this = ModuleUtil.New('MonsterBattle', ClientBase)
local RealMonster = nil

function MonsterBattle:Init()
    --Game.SetFPSQuality(Enum.FPSQuality.High)
    print("[MonsterBattle] Init()")
    this:NodeRef()
    this:DataInit()
    this:EventBind()
	localPlayer.Local.ControlGui.Menu.PetBtn:SetActive(false)
end

--节点引用
function MonsterBattle:NodeRef()
    this.MonsterGUI = localPlayer.Local.MonsterGUI
    this.MainPanel = this.MonsterGUI.MainPanel
    this.BattlePanel = this.MonsterGUI.BattlePanel
    this.RED_BAR = ResourceManager.GetTexture('Internal/Blood_Red')
    this.GREEN_BAR = ResourceManager.GetTexture('Internal/Blood_Green')
    this.ORANGE_BAR = ResourceManager.GetTexture('Internal/Blood_Orange')
	this.Color_Red = Color(255,0,0)
	this.Color_White = Color(255,255,255)
end

--数据变量声明
function MonsterBattle:DataInit()
    --this.monster = nil
    this.monsterItemLis = {}
    this.focusMonsterItem = nil
    world:CreateObject('IntValueObject', 'HealthVal', localPlayer)
    world:CreateObject('IntValueObject', 'AttackVal', localPlayer)
    world:CreateObject('ObjRefValueObject', 'MonsterVal', localPlayer)
    world:CreateObject('IntValueObject', 'BattleVal', localPlayer)
	this.canFollow = true
end

--节点事件绑定
function MonsterBattle:EventBind()
    --激活宠物二级菜单
    localPlayer.Local.ControlGui.Menu.PetBtn.OnClick:Connect(
        function()
            _flag = this.MainPanel.ActiveSelf
            print(not _flag)
            this.MainPanel:SetActive(not _flag)
            if not _flag then
                print("[MonsterBattle] 菜单刷新")
                this:RefreshBag()
            end
        end
    )
    --根据输入框添加宠物，如果为-1则随机一个
    this.MainPanel.AddMonsterBtn.OnClick:Connect(
        function()
            local monsterId = tonumber(this.MainPanel.AddMonsterInputField.Text)
            this:GetNewMonster(monsterId)
        end
    )
    --绑定携带宠物事件
    this.MainPanel.ShowMonsterBtn.OnClick:Connect(
        function()
            if focusMonsterItem and focusMonsterItem.UUID.Value ~= this.playerData.showMonster.Uuid then
                local _longdata = this:GetMonsterDataByUUID(focusMonsterItem.UUID.Value)
                local _configdata = this:GetMonsterDataById(_longdata.Id)
                this.playerData.showMonster.Uuid = _longdata.Uuid
                this.playerData.showMonster.Id = _longdata.Id
                this.playerData.showMonster.Health = _longdata.Health
                this.playerData.showMonster.Attack = _longdata.Attack
                this:ShowMonster()
                this:SaveData()
            end
        end
    )
    --卸载当前携带宠物
    this.MainPanel.UnloadMonsterBtn.OnClick:Connect(
        function()
            if this.playerData.showMonster.Uuid then
                this.playerData.showMonster = {}
                this:ShowMonster()
                this:SaveData()
            end
        end
    )
    --开启战斗
    this.MainPanel.MonsterBattleBtn.OnClick:Connect(
        function()
            if RealMonster then
                this:Battle()
            end
        end
    )
    --关闭战斗
    this.BattlePanel.CloseButton.OnClick:Connect(
        function()
            this.BattlePanel:SetActive(false)
        end
    )
    --石头剪刀布
    this.BattlePanel.Button1.OnClick:Connect(
        function()
            localPlayer.BattleVal.Value = 1
			this.BattlePanel.Button1.Color = this.Color_Red
			this.BattlePanel.Button2.Color = this.Color_White
			this.BattlePanel.Button3.Color = this.Color_White
        end
    )
    this.BattlePanel.Button2.OnClick:Connect(
        function()
            localPlayer.BattleVal.Value = 2
			this.BattlePanel.Button1.Color = this.Color_White
			this.BattlePanel.Button2.Color = this.Color_Red
			this.BattlePanel.Button3.Color = this.Color_White
        end
    )
    this.BattlePanel.Button3.OnClick:Connect(
        function()
            localPlayer.BattleVal.Value = 3
			this.BattlePanel.Button1.Color = this.Color_White
			this.BattlePanel.Button2.Color = this.Color_White
			this.BattlePanel.Button3.Color = this.Color_Red
        end
    )
	localPlayer.OnCollisionBegin:Connect(CheckMonsterRangeBegin)
    localPlayer.OnCollisionEnd:Connect(CheckMonsterRangeEnd)
end

function MonsterBattle:OnPlayerJoinEventHandler()
    this:LoadData()
    wait(2)
	this.MonsterGUI.Visible = true
	localPlayer.Local.ControlGui.Menu.PetBtn:SetActive(true)
	
    invoke(
        function()
            this:MonsterFollow()
        end
    )
    this:ShowMonster()
    world:CreateObject('StringValueObject', 'EnemyVal', localPlayer)
	MonsterUpDown()
end

function CheckMonsterRangeBegin(_hitObj, _hitPoint, hitNormal)
	if _hitObj == nil then
		return
	end
    if _hitObj.Name == 'MonsterRange' then
		this.MonsterGUI.BattleBtn.Visible = true
		this.MonsterGUI.BattleBtn.OnClick:Connect(
        function()
            NetUtil.Fire_S("StartBattleEvent", true, _hitObj, localPlayer)
			this.MonsterGUI.BattleBtn.Visible = false
        end
    )
    end	
end

function CheckMonsterRangeEnd(_hitObj, _hitPoint, hitNormal)
	if _hitObj == nil then
		return
	end
	if _hitObj.Name == 'MonsterRange' then
		this.MonsterGUI.BattleBtn.Visible = false
		this.MonsterGUI.BattleBtn.OnClick:Clear()
    end	
end

function MonsterBattle:Update(dt, tt)
    --world.Monster.PositionController.TargetPosition = localPlayer.Position + Vector3(0,2,0) - localPlayer.Forward
end

--宠物跟随
function MonsterBattle:MonsterFollow()
    while true do
        wait(0.1)
        if RealMonster ~= nil and this.canFollow then
            if (RealMonster.Position - localPlayer.Position).Magnitude > 2 then
                RealMonster.LinearVelocity =
                    (localPlayer.Position - RealMonster.Position).Normalized * 6 *
                    (RealMonster.Position - localPlayer.Position).Magnitude /
                    3
            else
                RealMonster.LinearVelocity = Vector3.Zero
            end
            RealMonster.Cube:LookAt(localPlayer, Vector3.Up)
            if (RealMonster.Position - localPlayer.Position).Magnitude > 10 then
                this:FlashMove()
            end
        end
    end
end

--宠物晃动
function MonsterUpDown()
	invoke(
        function()
            local _moveTime = 2
            while true do
                wait()
                if RealMonster and RealMonster.Cube then
                    local Tweener =
                        Tween:TweenProperty(
                        RealMonster.Cube,
                        {LocalPosition = Vector3(0, 2.5, 0)},
                        _moveTime,
                        Enum.EaseCurve.Linear
                    )
                    Tweener:Play()
                    wait(_moveTime)
                    Tweener =
                        Tween:TweenProperty(
                        RealMonster.Cube,
                        {LocalPosition = Vector3(0, 2, 0)},
                        _moveTime,
                        Enum.EaseCurve.Linear
                    )
                    Tweener:Play()
                    wait(_moveTime)
                end
            end
        end
    )
end

--获取新的宠物
function MonsterBattle:GetNewMonster(_monsterId)
    math.randomseed(os.time())
    local _monsterData = this:GetMonsterDataById(_monsterId)
    if (_monsterData == nil) then
        print("[MonsterBattle] 表中没有该宠物数据")
    else
        local _monsterItem = {}
        _monsterItem.Uuid = UUID()
        _monsterItem.Id = _monsterData.Id
        _monsterItem.Health = math.modf(_monsterData.HealthMax * (0.333 + math.randomFloat(-0.1, 0.1)))
        _monsterItem.Attack = math.modf(_monsterData.AttackMax * (0.333 + math.randomFloat(-0.1, 0.1)))
        this.playerData.monsterLis[#this.playerData.monsterLis + 1] = _monsterItem

        print(table.dump(_monsterItem))
        this:RefreshBag()
        this:SaveData()
    end
end

function MonsterBattle:ShowMonster()
    local _showMonster = this.playerData.showMonster
    --销毁当前的宠物
    if RealMonster then
        RealMonster:Destroy()
        RealMonster = nil
    end
    --根据Id生成宠物
    if _showMonster.Id then
        local _monster =
            world:CreateInstance(
            'Monster',
            'Monster' .. localPlayer.UserId,
            world,
            localPlayer.Position,
            EulerDegree(0, 0, 0)
        )
        RealMonster = _monster
        --local _healthVal = world:CreateObject('IntValueObject','HealthVal',RealMonster)
        --local _attackVal = world:CreateObject('IntValueObject','AttackVal',RealMonster)
        localPlayer.MonsterVal.Value = _monster
        this:RefreshShowMonsterVal()
        this:FlashMove()
        this.HealthGUI = localPlayer.MonsterVal.Value.Cube.HealthGui
        print("[MonsterBattle] 更换成功")
    end
end

--修改携带宠物的值节点数值
function MonsterBattle:RefreshShowMonsterVal()
    if RealMonster then
        localPlayer.HealthVal.Value = this.playerData.showMonster.Health
        localPlayer.AttackVal.Value = this.playerData.showMonster.Attack
        this:HealthChange()
    end
end

--刷新背包
function MonsterBattle:RefreshBag()
    --删除原来的btn
    for k, v in ipairs(this.monsterItemLis) do
        v:Destroy()
    end
    this.monsterItemLis = {}

    local _node = this.MainPanel.BackGround
    for k, v in ipairs(this.playerData.monsterLis) do
        local _item = world:CreateInstance('MonsterItem', 'MonsterItem', _node)
        _item.Offset = Vector2(130 * math.fmod(k - 1, 6), 130 * math.modf((k - 1) / 6))
        local _data = this:GetMonsterDataById(v.Id)
        _item.Text = _data.Name .. '  ' .. v.Health .. '  ' .. v.Attack
        _item.UUID.Value = v.Uuid
        _item.OnClick:Connect(
            function()
                for k2, v2 in ipairs(this.monsterItemLis) do
                    v2.Color = this.Color_White
                end
                if _item == focusMonsterItem then
                    _item.Color = this.Color_White
                    focusMonsterItem = nil
                else
                    _item.Color = this.Color_Red
                    focusMonsterItem = _item
                end
                this:InitFocusItem()
            end
        )
        table.insert(this.monsterItemLis, 1, _item)
    end
end

function MonsterBattle:InitFocusItem()
    local showBtn = this.MainPanel.ShowMonsterBtn
    if focusMonsterItem then
        showBtn:SetActive(true)
        local _longdata = this:GetMonsterDataByUUID(focusMonsterItem.UUID.Value)
        local _configdata = this:GetMonsterDataById(_longdata.Id)
        showBtn.Text = "携带: " .. _configdata.Name .. ' ' .. _longdata.Health .. ' ' .. _longdata.Attack
    else
        showBtn:SetActive(false)
        showBtn.Text = ''
    end
end

--宠物战斗
function MonsterBattle:ReadyBattleEventHandler()
    this:FlashMove()
    --temp
    this.MainPanel:SetActive(false)
    --print(this.BattlePanel)
    this.BattlePanel:SetActive(true)
    this:RefreshShowMonsterVal()
    this.HealthGUI:SetActive(true)
	
	localPlayer.Local.ControlGui.Joystick:SetActive(false)
	localPlayer.Local.ControlGui.Ctrl:SetActive(false)
end

function MonsterBattle:MBattleEventHandler(_enum, _arg1, _arg2)
    if _enum == Const.MonsterEnum.SKILLTIME then
        this.BattlePanel.TimeText.Text = _arg1
    elseif _enum == Const.MonsterEnum.SHOWSKILL then
        local _skillTxt = {'石头', '剪刀', '布'}
        if localPlayer.BattleVal.Value == -1 then --如果没有决定，则随机一个
            math.randomseed(os.time() + Timer.GetTimeMillisecond())
            localPlayer.BattleVal.Value = math.random(1, 3)
        end
        this.HealthGUI.SkillText.Text = _skillTxt[localPlayer.BattleVal.Value]
    elseif _enum == Const.MonsterEnum.NEWROUND then
        localPlayer.BattleVal.Value = -1
		this.BattlePanel.Button1.Color = this.Color_White
		this.BattlePanel.Button2.Color = this.Color_White
		this.BattlePanel.Button3.Color = this.Color_White
    elseif _enum == Const.MonsterEnum.BEHIT then
        invoke(
            function()
                localPlayer.HealthVal.Value = math.max(0, localPlayer.HealthVal.Value - _arg1)
                local _manaBall = world:CreateObject('Sphere', 'Ball', world, _arg2.MonsterVal.Value.Cube.Position)
                _manaBall.Size = Vector3.One * 0.3
                local Tweener =
                    Tween:TweenProperty(_manaBall, {Position = RealMonster.Cube.Position}, 0.5, Enum.EaseCurve.Linear)
                Tweener:Play()
                wait(0.5)
                this.HealthGUI.HitText.Text = _arg1
                _manaBall:Destroy()
                this:HealthChange()
                local Tweener = Tween:ShakeProperty(RealMonster.Cube, {'LocalPosition'}, 1, 0.1)
                Tweener:Play()
                wait(1)
                this.HealthGUI.HitText.Text = ''
            end
        )
    elseif _enum == Const.MonsterEnum.OVER then
        this.MainPanel:SetActive(false)
        this.BattlePanel:SetActive(false)
        this.HealthGUI:SetActive(false)
		this.MonsterGUI.Visible = true
        --localPlayer.Local.ControlGui:SetActive(true)
		localPlayer.Local.ControlGui.Joystick:SetActive(true)
		localPlayer.Local.ControlGui.Ctrl:SetActive(true)
    end
end

-- 血条随生命值颜色改变而改变
function MonsterBattle:HealthChange()
    if this.HealthGUI then
        local percent = localPlayer.HealthVal.Value / this.playerData.showMonster.Health
        if percent >= 0.7 then
            this.HealthGUI.BackgroundImg.HealthBarImg.Texture = this.GREEN_BAR
        elseif percent >= 0.3 then
            this.HealthGUI.BackgroundImg.HealthBarImg.Texture = this.ORANGE_BAR
        else
            this.HealthGUI.BackgroundImg.HealthBarImg.Texture = this.RED_BAR
        end
        this.HealthGUI.BackgroundImg.HealthBarImg.AnchorsX = Vector2(0.05, 0.9 * percent + 0.05)
        this.HealthGUI.BloodText.Text = localPlayer.HealthVal.Value .. '/' .. this.playerData.showMonster.Health
    end
end

function MonsterBattle:MonsterScanEventHandler(_pos,_euler,_time)
	print("[Monster]'..'开始扫描")
	invoke(function()
		this.canFollow = false
		RealMonster.LinearVelocity = Vector3.Zero
		this:FlashMove(_pos)
		RealMonster.Rotation = _euler
		wait(0.2)
		RealMonster.Cube.FX1:SetActive(true)
		local Tweener =
            Tween:TweenProperty(
            RealMonster,
            {Rotation = _euler - EulerDegree(0,180,0)},
            _time,
            Enum.EaseCurve.Linear
        )
        Tweener:Play()
		wait(_time)
		RealMonster.Cube.FX1:SetActive(false)
		this.canFollow = true
	end)
end

function MonsterBattle:TestScan()
	NetUtil.Fire_C('MonsterScanEvent',localPlayer,localPlayer.Position+Vector3(3,0,0),EulerDegree(0,0,0),5)
end

function MonsterBattle:FlashMove(_pos)
	if _pos == nil then
		RealMonster.Position = localPlayer.Position - localPlayer.Forward * 2
	else
		RealMonster.Position = _pos
	end
	local _fx = world:CreateInstance('FX_FLASHMOVE','fx',RealMonster,Vector3.Zero,EulerDegree(0,0,0))
	_fx.LocalPosition = RealMonster.Cube.LocalPosition
	DelayDestroy(_fx,1)
end

function DelayDestroy(_obj,_delayTime)
	invoke(function()
		wait(_delayTime)
		_obj:Destroy()
	end)
end

--以下为数据交互函数
--保存长期数据
function MonsterBattle:SaveData()
    NetUtil.Fire_S('SaveMDataEvent', localPlayer.UserId, this.playerData)
end
--读取长期数据
function MonsterBattle:LoadData()
    NetUtil.Fire_S('LoadMDataEvent', localPlayer.UserId)
end

function MonsterBattle:LoadMDataBackEventHandler(_userId, _playerData)
    if _userId == localPlayer.UserId then
        --print(table.dump(_playerData))
        this.playerData = _playerData
    end
end
--根据Id获取宠物信息
function MonsterBattle:GetMonsterDataById(_monsterId)
    if _monsterId == -1 then
        return Config.MonsterConfig[math.random(1, #Config.MonsterConfig)]
    end

    for k, v in ipairs(Config.MonsterConfig) do
        if v.Id == _monsterId then
            return v
        end
    end
    return nil
end
--根据UUID获取宠物长期数据
function MonsterBattle:GetMonsterDataByUUID(_uuid)
    for k, v in ipairs(this.playerData.monsterLis) do
        if v.Uuid == _uuid then
            return v
        end
    end

    return nil
end

return MonsterBattle
