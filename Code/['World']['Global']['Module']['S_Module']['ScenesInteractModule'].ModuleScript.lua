--- 场景交互模块
--- @module ScenesInteract Module
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman.Yen Yuan
local ScenesInteract, this = ModuleUtil.New('ScenesInteract', ServerBase)

--- 变量声明
-- 交互物体
local interactOBJ = {}

-- 弹跳物体
local bounceOBJ = {}

-- 望远镜
local telescopeOBJ = {}

-- 座位
local seatOBJ = {}

-- 篝火
local bonfireOBJ = {}

-- 草
local grassOBJ = {}

-- 木马
local trojanObj = {}

-- 吉他
local guitarOBJ = {}

-- 帐篷
local tentOBJ = {}

-- 炸弹
local bombOBJ = {}

-- 收音机
local radioOBJ = {}

-- 锅
local potOBJ = {}

-- 玩家碰撞开始命令函数
local ColBeginFunc = {}

-- 玩家碰撞结束命令函数
local ColEndFunc = {}

-- 进入交互命令函数
local EnterInteractFunc = {}

-- 离开交互命令函数
local LeaveInteractFunc = {}

--- 初始化
function ScenesInteract:Init()
    print('[ScenesInteract] Init()')
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--- 节点引用
function ScenesInteract:NodeRef()
    for k, v in pairs(Config.ScenesInteract) do
        this:InstanceInteractOBJ(v.ID)
    end
    for k, v in pairs(world.TelescopeInteract:GetChildren()) do
        telescopeOBJ[v.Name] = {
            obj = v,
            aroundPlayers = {}
        }
        world:CreateObject('IntValueObject', 'InteractID', v)
        v.InteractID.Value = 14
    end
    for k, v in pairs(world.SeatInteract:GetChildren()) do
        seatOBJ[v.Name] = {
            obj = v,
            aroundPlayers = {}
        }
        world:CreateObject('StringValueObject', 'UsingPlayerUid', v)
        world:CreateObject('IntValueObject', 'InteractID', v)
        v.UsingPlayerUid.Value = ''
        v.InteractID.Value = 15
    end
    for k, v in pairs(world.BonfireInteract:GetChildren()) do
        bonfireOBJ[v.Name] = {
            obj = v,
            aroundPlayers = {}
        }
        world:CreateObject('IntValueObject', 'InteractID', v)
        v.InteractID.Value = 16
    end
    for k, v in pairs(world.BounceInteract:GetChildren()) do
        bounceOBJ[v.Name] = {
            obj = v,
            originScale = v.Scale,
            tweener1 = nil,
            tweener2 = nil,
            tweener3 = nil,
            isbouncing = false
        }
        world:CreateObject('IntValueObject', 'InteractID', v)
        v.InteractID.Value = 17
    end
    for k, v in pairs(world.GrassInteract:GetChildren()) do
        table.insert(grassOBJ, v)
        world:CreateObject('IntValueObject', 'InteractID', v)
        v.InteractID.Value = 18
    end
    for k, v in pairs(world.Trojan:GetChildren()) do
        trojanObj[v.Name] = {
            obj = v,
            aroundPlayers = {}
        }
        world:CreateObject('StringValueObject', 'UsingPlayerUid', v)
        world:CreateObject('IntValueObject', 'InteractID', v)
        v.UsingPlayerUid.Value = ''
        v.InteractID.Value = 20
    end
    for k, v in pairs(world.Guitar:GetChildren()) do
        guitarOBJ[v.Name] = {
            obj = v
        }
        world:CreateObject('IntValueObject', 'InteractID', v)
        v.InteractID.Value = 21
    end
    for k, v in pairs(world.Tent:GetChildren()) do
        tentOBJ[v.Name] = {
            obj = v,
            aroundPlayers = {}
        }
        world:CreateObject('StringValueObject', 'UsingPlayerUid1', v)
        world:CreateObject('StringValueObject', 'UsingPlayerUid2', v)
        world:CreateObject('IntValueObject', 'InteractID', v)
        v.UsingPlayerUid1.Value = ''
        v.UsingPlayerUid2.Value = ''
        v.InteractID.Value = 22
    end
    for k, v in pairs(world.Radio:GetChildren()) do
        radioOBJ[v.Name] = {
            obj = v,
            aroundPlayers = {}
        }
        world:CreateObject('IntValueObject', 'InteractID', v)
        v.InteractID.Value = 24
    end
    for k, v in pairs(world.Pot:GetChildren()) do
        potOBJ[v.Name] = {
            obj = v,
            aroundPlayers = {}
        }
        world:CreateObject('IntValueObject', 'InteractID', v)
        v.InteractID.Value = 26
    end
end

--- 数据变量初始化
function ScenesInteract:DataInit()
    this.TrojanList = {}
    this.TentList = {}
    this.RadioData = {
        songIndex = 0,
        songList = {97, 98, 99},
        curSong = nil
    }
    for k, v in pairs(Const.InteractEnum) do
        EnterInteractFunc[v] = function(_player)
            if this['Enter' .. k] then
                this['Enter' .. k](self, _player)
            end
        end
        LeaveInteractFunc[v] = function(_player)
            if this['Leave' .. k] then
                this['Leave' .. k](self, _player)
            end
        end
        ColBeginFunc[v] = function(_player, _obj)
            if this[k .. 'ColBeginFunc'] then
                this[k .. 'ColBeginFunc'](self, _player, _obj)
            end
        end
        ColEndFunc[v] = function(_player, _obj)
            if this[k .. 'ColEndFunc'] then
                this[k .. 'ColEndFunc'](self, _player, _obj)
            end
        end
    end
end

--- 节点事件绑定
function ScenesInteract:EventBind()
end

--- 实例化场景交互 ScenesInteract:InstanceInteractOBJ(60, Vector3(-62.0279, 0, -35.9028))
function ScenesInteract:InstanceInteractOBJ(_id, _pos)
    local config = Config.ScenesInteract[_id]
    if config.IsPre or _pos then
        local temp = {
            obj = world:CreateInstance(
                config.ArchetypeName,
                config.ArchetypeName,
                world.ScenesInteract,
                _pos or config.Pos,
                config.Rot or EulerDegree(0, 0, 0)
            ),
            aroundPlayers = {},
            id = _id,
            itemID = config.GetItemID,
            isUse = config.IsUse,
            addBuffID = config.AddBuffID,
            addBuffDur = config.AddBuffDur,
            rewardCoin = config.RewardCoin,
            useCount = config.UseCount,
            useCountMax = config.UseCount,
            resetTime = config.ResetTime,
            resetCD = 0,
            anitName = config.AnitName,
            interactAEID = config.InteractAEID
        }
        world:CreateObject('IntValueObject', 'InteractID', temp.obj)
        temp.obj.InteractID.Value = 13
        table.insert(interactOBJ, temp)
    end
end

-- 弹跳
function ScenesInteract:ElasticDeformation(_bounce, _player)
    if _bounce.isbouncing == false then
        _bounce.isbouncing = true
        _bounce.tweener1 =
            Tween:TweenProperty(
            _bounce.obj,
            {
                Scale = 0.8 * _bounce.originScale
            },
            0.1,
            Enum.EaseCurve.Linear
        )
        _bounce.tweener2 =
            Tween:TweenProperty(
            _bounce.obj,
            {
                Scale = 1.2 * _bounce.originScale
            },
            0.1,
            Enum.EaseCurve.Linear
        )
        _bounce.tweener3 =
            Tween:TweenProperty(
            _bounce.obj,
            {
                Scale = _bounce.originScale
            },
            0.2,
            Enum.EaseCurve.Linear
        )
        invoke(
            function()
                _bounce.tweener1:Play()
                _player.LinearVelocity = Vector3(0, 20, 0)
                SoundUtil.Play3DSE(_bounce.obj.Position, 22)
                wait(0.1)
                NetUtil.Fire_C('FsmTriggerEvent', _player, 'Fly')
                _bounce.tweener1:Destroy()
                _bounce.tweener2:Play()
                wait(0.1)
                _bounce.tweener3:Play()
                _bounce.tweener2:Destroy()
                wait(0.2)
                _bounce.isbouncing = false
                _bounce.tweener3:Destroy()
            end
        )
    end
end

-- 草动
function ScenesInteract:GrassInter(_object)
    if _object.IsSwinging.Value == false then
        _object.IsSwinging.Value = true
        local swayTweenerl = this:GrassSwayTween(_object, 20, 0.15)
        local swayTweener2 = this:GrassSwayTween(_object, -30, 0.3)
        local swayTweener3 = this:GrassSwayTween(_object, 0, 0.15)
        swayTweenerl.OnComplete:Connect(
            function()
                swayTweener2:Play()
                swayTweenerl:Destroy()
            end
        )
        swayTweener2.OnComplete:Connect(
            function()
                swayTweener3:Play()
                swayTweener2:Destroy()
            end
        )
        swayTweener3.OnComplete:Connect(
            function()
                _object.IsSwinging.Value = false
                swayTweener3:Destroy()
            end
        )

        swayTweenerl:Play()
    end
end

function ScenesInteract:GrassSwayTween(_obj, _property, _duration)
    return Tween:TweenProperty(
        _obj,
        {
            Rotation = EulerDegree(_obj.Rotation.x, _obj.Rotation.y, _obj.Rotation.z + _property)
        },
        _duration,
        Enum.EaseCurve.Linear
    )
end

function ScenesInteract:TrojanShake(dt)
    for k, v in pairs(this.TrojanList) do
        v.timer = v.timer + dt
        v.totalTimer = v.totalTimer + dt
        if v.timer >= 1 then
            -- 给钱
            NetUtil.Fire_C('UpdateCoinEvent', v.player, 500, false)
            v.timer = 0
        end
        v.model.Forward = v.originForward + Vector3.Up * math.sin(v.totalTimer) * 0.3
    end
end

function ScenesInteract:TentShake(dt)
    for k, v in pairs(this.TentList) do
        if v.num >= 2 then
            v.timer = v.timer + dt
            if v.timer >= 1 then
                local tweener = Tween:ShakeProperty(v.model, {'Rotation'}, 0.5, 1)
                tweener:Play()
                v.timer = 0
            end
        end
    end
end

--场景交互
do
    function ScenesInteract:ScenesInteractColBeginFunc(_player, _obj)
        for k, v in pairs(interactOBJ) do
            if v.obj == _obj then
                NetUtil.Fire_C('OpenDynamicEvent', _player, 'Interact', 13, v.id)
                v.aroundPlayers[_player.UserId] = _player.UserId
            end
        end
    end

    function ScenesInteract:ScenesInteractColEndFunc(_player, _obj)
        NetUtil.Fire_C('CloseDynamicEvent', _player)
        for k, v in pairs(interactOBJ) do
            if v.obj == _obj then
                v.aroundPlayers[_player.UserId] = nil
            end
        end
    end
    function ScenesInteract:EnterScenesInteract(_player)
        for k1, v1 in pairs(interactOBJ) do
            for k2, v2 in pairs(v1.aroundPlayers) do
                if v2 == _player.UserId then
                    if v1.useCount > 0 then
                        if v1.anitName then
                            _player.Avatar:PlayAnimation(v1.anitName, 2, 1, 0.1, true, false, 1)
                        end
                        if v1.interactAEID then
                            SoundUtil.Play3DSE(_player.Position, v1.interactAEID)
                        end
                        if v1.itemID ~= nil then
                            NetUtil.Fire_C('GetItemEvent', _player, v1.itemID)
                            if v1.isUse then
                                wait(.1)
                                NetUtil.Fire_C('UseItemInBagEvent', _player, v1.itemID)
                            end
                        end
                        if v1.addBuffID then
                            NetUtil.Fire_C('GetBuffEvent', _player, v1.addBuffID, v1.addBuffDur)
                        end
                        NetUtil.Fire_S('SpawnCoinEvent', 'P', v1.obj.Position + Vector3(0, 2.5, 0), v1.rewardCoin)
                        v1.useCount = v1.useCount - 1
                        if v1.useCount == 0 then
                            v1.obj:SetActive(false)
                        end
                    else
                        v1.obj:SetActive(false)
                    end
                    NetUtil.Fire_C('ChangeMiniGameUIEvent', _player)
                    return
                end
            end
        end
    end
end

--望远镜交互
do
    function ScenesInteract:TelescopeInteractColBeginFunc(_player, _obj)
        NetUtil.Fire_C('OpenDynamicEvent', _player, 'Interact', 14)
        telescopeOBJ[_obj.Name].aroundPlayers[_player.UserId] = _player.UserId
    end

    function ScenesInteract:TelescopeInteractColEndFunc(_player, _obj)
        NetUtil.Fire_C('CloseDynamicEvent', _player)
        telescopeOBJ[_obj.Name].aroundPlayers[_player.UserId] = nil
    end
    function ScenesInteract:EnterTelescopeInteract(_player)
        for k1, v1 in pairs(telescopeOBJ) do
            for k2, v2 in pairs(v1.aroundPlayers) do
                if v2 == _player.UserId then
                    NetUtil.Fire_C('ChangeMiniGameUIEvent', _player, 14)
                    NetUtil.Fire_C('SetFPSCamEvent', _player)
                end
            end
        end
    end

    function ScenesInteract:LeaveTelescopeInteract(_player)
        for k1, v1 in pairs(radioOBJ) do
            for k2, v2 in pairs(v1.aroundPlayers) do
                if v2 == _player.UserId then
                    NetUtil.Fire_C('ChangeMiniGameUIEvent', _player)
                    NetUtil.Fire_C('SetCurCamEvent', _player)
                end
            end
        end
    end
end

--座位交互
do
    function ScenesInteract:SeatInteractColBeginFunc(_player, _obj)
        NetUtil.Fire_C('OpenDynamicEvent', _player, 'Interact', 15)
        seatOBJ[_obj.Name].aroundPlayers[_player.UserId] = _player.UserId
    end

    function ScenesInteract:SeatInteractColEndFunc(_player, _obj)
        NetUtil.Fire_C('CloseDynamicEvent', _player)
        seatOBJ[_obj.Name].aroundPlayers[_player.UserId] = nil
    end
    function ScenesInteract:EnterSeatInteract(_player)
        for k1, v1 in pairs(seatOBJ) do
            for k2, v2 in pairs(v1.aroundPlayers) do
                if v2 == _player.UserId and v1.obj.UsingPlayerUid.Value == '' then
                    NetUtil.Fire_C('ChangeMiniGameUIEvent', _player, 15)
                    v1.obj.UsingPlayerUid.Value = _player.UserId
                    v1.obj:Sit(_player)
                    _player.Avatar:PlayAnimation('SitIdle', 2, 1, 0.1, true, true, 1)
                    -- 音效
                    SoundUtil.Play3DSE(_player.Position, 14)
                end
            end
        end
    end

    function ScenesInteract:LeaveSeatInteract(_player)
        for k, v in pairs(seatOBJ) do
            if v.obj.UsingPlayerUid.Value == _player.UserId then
                NetUtil.Fire_C('ChangeMiniGameUIEvent', _player)
                v.obj.UsingPlayerUid.Value = ''
                v.obj:Leave(_player)
                NetUtil.Fire_C('FsmTriggerEvent', _player, 'Jump')
            end
        end
    end
end

--篝火交互
do
    function ScenesInteract:BonfireInteractColBeginFunc(_player, _obj)
        NetUtil.Fire_C('OpenDynamicEvent', _player, 'Interact', 16)
        bonfireOBJ[_obj.Name].aroundPlayers[_player.UserId] = _player.UserId
    end

    function ScenesInteract:BonfireInteractColEndFunc(_player, _obj)
        NetUtil.Fire_C('CloseDynamicEvent', _player)
        bonfireOBJ[_obj.Name].aroundPlayers[_player.UserId] = nil
    end

    function ScenesInteract:EnterBonfireInteract(_player)
        for k1, v1 in pairs(bonfireOBJ) do
            for k2, v2 in pairs(v1.aroundPlayers) do
                if v2 == _player.UserId then
                    if v1.obj.On.ActiveSelf then
                        v1.obj.On:SetActive(false)
                        v1.obj.Off:SetActive(true)
                    else
                        SoundUtil.Play3DSE(_player.Position, 102)
                        v1.obj.On:SetActive(true)
                        v1.obj.Off:SetActive(false)
                    end
                end
            end
        end
        NetUtil.Fire_C('ChangeMiniGameUIEvent', _player)
        NetUtil.Fire_C('OpenDynamicEvent', _player, 'Interact', 16)
    end
end

--弹性物体交互
do
    function ScenesInteract:BounceInteractColBeginFunc(_player, _obj)
        --NetUtil.Fire_C('OpenDynamicEvent', _player, 'Interact', 17)
        for k, v in pairs(bounceOBJ) do
            if v.obj == _obj then
                this:ElasticDeformation(v, _player)
            end
        end
    end
end

--草交互
do
    function ScenesInteract:GrassInteractColBeginFunc(_player, _obj)
        this:GrassInter(_obj)
    end
end

--摇摇椅交互
do
    function ScenesInteract:TrojanColBeginFunc(_player, _obj)
        NetUtil.Fire_C('OpenDynamicEvent', _player, 'Interact', 20)
        trojanObj[_obj.Name].aroundPlayers[_player.UserId] = _player.UserId
    end

    function ScenesInteract:TrojanColEndFunc(_player, _obj)
        NetUtil.Fire_C('CloseDynamicEvent', _player)
        trojanObj[_obj.Name].aroundPlayers[_player.UserId] = nil
    end
    function ScenesInteract:EnterTrojan(_player)
        for k1, v1 in pairs(trojanObj) do
            for k2, v2 in pairs(v1.aroundPlayers) do
                if v2 == _player.UserId and v1.obj.UsingPlayerUid.Value == '' then
                    NetUtil.Fire_C('UnequipCurEquipmentEvent', _player)
                    v1.obj.UsingPlayerUid.Value = _player.UserId
                    v1.obj.Seat:Sit(_player)
                    NetUtil.Fire_C('ChangeMiniGameUIEvent', _player, 20)
                    _player.Avatar:PlayAnimation('HTRide', 3, 1, 0, true, true, 1)
                    _player.Avatar:PlayAnimation('SitIdle', 2, 1, 0, true, true, 1)
                    -- 音效
                    this.TrojanList[v1.obj.Name] = {
                        model = v1.obj,
                        timer = 0,
                        totalTimer = 0,
                        originForward = v1.obj.Forward,
                        dirRatio = 1,
                        --sound = SoundUtil.Play3DSE(_player.Position, 15),
                        player = _player
                    }
                end
            end
        end
    end

    function ScenesInteract:LeaveTrojan(_player)
        for k, v in pairs(trojanObj) do
            if v.obj.UsingPlayerUid.Value == _player.UserId then
                v.obj.Seat:Leave(_player)
                v.obj.UsingPlayerUid.Value = ''
                _player.Avatar:StopAnimation('HTRide', 3)
                _player.Avatar:StopAnimation('SitIdle', 2)
                NetUtil.Fire_C('FsmTriggerEvent', _player, 'Jump')
                NetUtil.Fire_C('ChangeMiniGameUIEvent', _player)
                --SoundUtil.Stop3DSE(this.TrojanList[v.obj.Name].sound)
                v.obj.Forward = this.TrojanList[v.obj.Name].originForward
                this.TrojanList[v.obj.Name] = nil
            end
        end
    end
end

--吉他交互
do
    function ScenesInteract:GuitarColBeginFunc(_player, _obj)
        NetUtil.Fire_C('OpenDynamicEvent', _player, 'Interact', 21)
    end
    function ScenesInteract:GuitarColEndFunc(_player, _obj)
        NetUtil.Fire_C('CloseDynamicEvent', _player)
    end
    function ScenesInteract:EnterGuitar(_player)
        NetUtil.Fire_C('ChangeMiniGameUIEvent', _player, 21)
    end
    function ScenesInteract:LeaveGuitar(_player)
        NetUtil.Fire_C('ChangeMiniGameUIEvent', _player)
    end
end

--帐篷交互
do
    function ScenesInteract:TentColBeginFunc(_player, _obj)
        NetUtil.Fire_C('OpenDynamicEvent', _player, 'Interact', 22)
        tentOBJ[_obj.Name].aroundPlayers[_player.UserId] = _player.UserId
    end

    function ScenesInteract:TentColEndFunc(_player, _obj)
        NetUtil.Fire_C('CloseDynamicEvent', _player)
        tentOBJ[_obj.Name].aroundPlayers[_player.UserId] = nil
    end
    function ScenesInteract:EnterTent(_player)
        for k1, v1 in pairs(tentOBJ) do
            for k2, v2 in pairs(v1.aroundPlayers) do
                if v2 == _player.UserId then
                    if v1.obj.UsingPlayerUid1.Value == '' or v1.obj.UsingPlayerUid2.Value == '' then
                        NetUtil.Fire_C('ChangeMiniGameUIEvent', _player, 22)
                        NetUtil.Fire_C('GetBuffEvent', _player, 20, 1)
                        NetUtil.Fire_C('SetCurCamEvent', _player, nil, v1.obj)
                        NetUtil.Fire_C('SetCamDistanceEvent', _player, 6, 0.5)
                        _player.Avatar:SetActive(false)
                        _player.Position, _player.Rotation = v1.obj.LeaveLoc.Position, v1.obj.LeaveLoc.Rotation
                        if v1.obj.UsingPlayerUid1.Value == '' then
                            v1.obj.UsingPlayerUid1.Value = _player.UserId
                        else
                            v1.obj.UsingPlayerUid2.Value = _player.UserId
                        end
                        SoundUtil.Play3DSE(_player.Position, 103)
                        if not this.TentList[v1.obj.Name] then
                            this.TentList[v1.obj.Name] = {
                                model = v1.obj,
                                num = 0,
                                timer = 0
                            }
                        end
                        this.TentList[v1.obj.Name].num = this.TentList[v1.obj.Name].num + 1
                        this:TentNumEffect(this.TentList[v1.obj.Name].num, v1.obj)
                    end
                end
            end
        end

        function ScenesInteract:LeaveTent(_player)
            for k, v in pairs(tentOBJ) do
                if v.obj.UsingPlayerUid1.Value == _player.UserId or v.obj.UsingPlayerUid2.Value == _player.UserId then
                    NetUtil.Fire_C('PlayerSkinUpdateEvent', _player, 0)
                    NetUtil.Fire_C('ChangeMiniGameUIEvent', _player)
                    if v.obj.UsingPlayerUid1.Value == _player.UserId then
                        v.obj.UsingPlayerUid1.Value = ''
                    else
                        v.obj.UsingPlayerUid2.Value = ''
                    end
                    this.TentList[v.obj.Name].num = this.TentList[v.obj.Name].num - 1
                    this:TentNumEffect(this.TentList[v.obj.Name].num, v.obj)
                    if this.TentList[v.obj.Name].num == 0 then
                        this.TentList[v.obj.Name] = nil
                        v.obj.Effect:SetActive(false)
                        v.obj.Mesh = ResourceManager.GetMesh('Game/Tent/Tent' .. v.obj.ColorStr.Value .. 'Open')
                    end
                    --离开帐篷玩家的表现
                    _player.Avatar:PlayAnimation('SocialWarmUp', 2, 1, 0, true, false, 1)
                    _player.Avatar:SetActive(true)
                    NetUtil.Fire_C('ResetTentCamEvent', _player, 3)
                end
            end
        end
    end
end

local distanceTweener1, distanceTweener2
function ScenesInteract:TentBreath(_tent)
    distanceTweener1 = Tween:TweenProperty(_tent, {Stretch = Vector3(1, 1.1, 1)}, 1, 3)
    distanceTweener2 = Tween:TweenProperty(_tent, {Stretch = Vector3(1, 1, 1)}, 1.8, 1)
    distanceTweener1.OnComplete:Connect(
        function()
            distanceTweener2:Play()
        end
    )
    distanceTweener2.OnComplete:Connect(
        function()
            wait(0.5)
            distanceTweener1:Play()
        end
    )
    distanceTweener1:Play()
end

function ScenesInteract:TentNumEffect(_num, _model)
    if _num == 1 then
        _model.Effect:SetActive(true)
        _model.Effect.Sleep:SetActive(true)
        _model.Effect.MakeLove:SetActive(false)
        _model.Mesh = ResourceManager.GetMesh('Game/Tent/Tent' .. _model.ColorStr.Value .. 'Close')
        this:TentBreath(_model)
    elseif distanceTweener1 then
        distanceTweener1:Pause()
        distanceTweener1:Destroy()
        distanceTweener2:Pause()
        distanceTweener2:Destroy()
        _model.Stretch = Vector3(1, 1, 1)
    end
    if _num >= 2 then
        _model.Effect:SetActive(true)
        _model.Effect.Sleep:SetActive(false)
        _model.Effect.MakeLove:SetActive(true)
    end
end

--收音机交互
do
    function ScenesInteract:RadioColBeginFunc(_player, _obj)
        NetUtil.Fire_C('OpenDynamicEvent', _player, 'Interact', 24)
        radioOBJ[_obj.Name].aroundPlayers[_player.UserId] = _player.UserId
    end

    function ScenesInteract:RadioColEndFunc(_player, _obj)
        NetUtil.Fire_C('CloseDynamicEvent', _player)
        radioOBJ[_obj.Name].aroundPlayers[_player.UserId] = nil
    end
    function ScenesInteract:EnterRadio(_player)
        for k1, v1 in pairs(radioOBJ) do
            for k2, v2 in pairs(v1.aroundPlayers) do
                if v2 == _player.UserId then
                    SoundUtil.Play3DSE(_player.Position, 104)
                    this.RadioData.songIndex = this.RadioData.songIndex + 1
                    if this.RadioData.songIndex > #this.RadioData.songList then
                        this.RadioData.songIndex = 1
                    end
                    -- 先停止当前音乐，再播放
                    if this.RadioData.curSong then
                        -- NetUtil.Fire_C("StopEffectEvent", _player, "radio")
                    else
                        v1.obj.Model.On:SetActive(true)
                    end
                    this.RadioData.curSong = true
                    NetUtil.Fire_C('OpenDynamicEvent', _player, 'Interact', 24)
                end
            end
        end
    end
end

--做饭交互
do
    function ScenesInteract:CookColBeginFunc(_player, _obj)
        NetUtil.Fire_C('OpenDynamicEvent', _player, 'Interact', 26)
        potOBJ[_obj.Name].aroundPlayers[_player.UserId] = _player.UserId
    end

    function ScenesInteract:CookColEndFunc(_player, _obj)
        NetUtil.Fire_C('CloseDynamicEvent', _player)
        potOBJ[_obj.Name].aroundPlayers[_player.UserId] = nil
    end

    function ScenesInteract:EnterCook(_player)
        for k1, v1 in pairs(potOBJ) do
            for k2, v2 in pairs(v1.aroundPlayers) do
                if v2 == _player.UserId then
                    NetUtil.Fire_C('ChangeMiniGameUIEvent', _player, 26)
                end
            end
            if table.nums(v1.aroundPlayers) > 0 then
                v1.obj.Off:SetActive(false)
                v1.obj.On:SetActive(true)
            end
        end
    end

    function ScenesInteract:LeaveCook(_player)
        for k1, v1 in pairs(potOBJ) do
            for k2, v2 in pairs(v1.aroundPlayers) do
                if v2 == _player.UserId then
                    v1.aroundPlayers[_player.UserId] = nil
                    NetUtil.Fire_C('ChangeMiniGameUIEvent', _player)
                    print('table.nums(v1.aroundPlayers)', table.nums(v1.aroundPlayers))
                    if table.nums(v1.aroundPlayers) <= 0 then
                        v1.obj.Off:SetActive(true)
                        v1.obj.On:SetActive(false)
                    end
                end
            end
        end
    end
end

--- 玩家碰撞开始
function ScenesInteract:SInteractOnPlayerColBeginEventHandler(_player, _obj, _id)
    if ColBeginFunc[_id] then
        ColBeginFunc[_id](_player, _obj)
    end
end
-- 玩家碰撞结束
function ScenesInteract:SInteractOnPlayerColEndEventHandler(_player, _obj, _id)
    if ColEndFunc[_id] then
        ColEndFunc[_id](_player, _obj)
    end
end

function ScenesInteract:InteractSEventHandler(_player, _id)
    print('InteractSEventHandler', _id)
    if EnterInteractFunc[_id] then
        EnterInteractFunc[_id](_player)
    end
end

function ScenesInteract:LeaveInteractSEventHandler(_player, _id)
    print('LeaveInteractSEventHandler', _id)
    if LeaveInteractFunc[_id] then
        LeaveInteractFunc[_id](_player)
    end
end

-- 重置交互物体
function ScenesInteract:ResetSIOBJ(dt)
    for k, v in pairs(interactOBJ) do
        if v.useCount == 0 and v.resetTime > 0 then
            if v.resetCD < v.resetTime then
                v.resetCD = v.resetCD + dt
            else
                v.resetCD = 0
                v.useCount = v.useCountMax
                v.obj:SetActive(true)
            end
        end
    end
end

function ScenesInteract:Update(dt)
    this:ResetSIOBJ(dt)
    this:TrojanShake(dt)
    this:TentShake(dt)
end

return ScenesInteract
