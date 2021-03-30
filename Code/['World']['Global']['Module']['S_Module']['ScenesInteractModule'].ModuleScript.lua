--- 场景交互模块
--- @module ScenesInteract Module
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman.Yen Yuan
local ScenesInteract, this = ModuleUtil.New('ScenesInteract', ServerBase)

--- 变量声明
--交互物体
local interactOBJ = {}

--弹跳物体
local bounceOBJ = {}

--望远镜
local telescopeOBJ = {}

--座位
local seatOBJ = {}

--篝火
local bonfireOBJ = {}

--草
local grassOBJ = {}

--木马
local trojanObj = {}

--吉他
local guitarOBJ = {}

--帐篷
local tentOBJ = {}

--炸弹
local bombOBJ = {}

--收音机
local radioOBJ = {}

--锅
local potOBJ = {}

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
    for k, v in pairs(world.BounceInteract:GetChildren()) do
        bounceOBJ[v.Name] = {
            obj = v,
            originScale = v.Scale,
            tweener1 = nil,
            tweener2 = nil,
            tweener3 = nil,
            isbouncing = false
        }
    end
    for k, v in pairs(world.SeatInteract:GetChildren()) do
        seatOBJ[v.Name] = v
    end
    for k, v in pairs(world.BonfireInteract:GetChildren()) do
        bonfireOBJ[v.Name] = v
    end
    for k, v in pairs(world.GrassInteract:GetChildren()) do
        table.insert(grassOBJ, v)
    end
    for k, v in pairs(world.Trojan:GetChildren()) do
        trojanObj[v.Name] = v
    end
    for k, v in pairs(world.Guitar:GetChildren()) do
        guitarOBJ[v.Name] = v
    end
    for k, v in pairs(world.Tent:GetChildren()) do
        tentOBJ[v.Name] = v
    end
    for k, v in pairs(world.Bomb:GetChildren()) do
        bombOBJ[v.Name] = v
    end
    for k, v in pairs(world.Radio:GetChildren()) do
        radioOBJ[v.Name] = v
    end
    for k,v in pairs(world.Pot:GetChildren()) do
        potOBJ[v.Name] = v
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
            itemID = config.GetItemID,
            isUse = config.IsUse,
            addBuffID = config.AddBuffID,
            addBuffDur = config.AddBuffDur,
            rewardCoin = config.RewardCoin,
            useCount = config.UseCount,
            useCountMax = config.UseCount,
            resetTime = config.ResetTime,
            resetCD = 0
        }
        world:CreateObject('StringValueObject', 'ScenesInteractUID', temp.obj)
        table.insert(interactOBJ, temp)
    end
end

--弹跳
function ScenesInteract:ElasticDeformation(_bounce, _player)
    if _bounce.isbouncing == false then
        _bounce.isbouncing = true
        _bounce.tweener1 =
            Tween:TweenProperty(_bounce.obj, {Scale = 0.8 * _bounce.originScale}, 0.1, Enum.EaseCurve.Linear)
        _bounce.tweener2 =
            Tween:TweenProperty(_bounce.obj, {Scale = 1.2 * _bounce.originScale}, 0.1, Enum.EaseCurve.Linear)
        _bounce.tweener3 = Tween:TweenProperty(_bounce.obj, {Scale = _bounce.originScale}, 0.2, Enum.EaseCurve.Linear)
        invoke(
            function()
                _bounce.tweener1:Play()
                wait(0.1)
                _player.LinearVelocity = Vector3(0, 20, 0)
                _bounce.tweener1:Destroy()
                _bounce.tweener2:Play()
                wait(0.1)
                _bounce.tweener3:Play()
                _bounce.tweener2:Destroy()
                wait(0.2)
                _bounce.isbouncing = false
                _bounce.obj.BounceInteractUID.Value = ''
                _bounce.tweener3:Destroy()
            end
        )
    end
end

--草动
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
        {Rotation = EulerDegree(_obj.Rotation.x, _obj.Rotation.y, _obj.Rotation.z + _property)},
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
            NetUtil.Fire_C('UpdateCoinEvent', localPlayer, 1)
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

function ScenesInteract:TentNumEffect(_num, _model)
    if _num == 1 then
        _model.Effect:SetActive(true)
        _model.Effect.Sleep:SetActive(true)
        _model.Effect.MakeLove:SetActive(false)
    end
    if _num >= 2 then
        _model.Effect:SetActive(true)
        _model.Effect.Sleep:SetActive(false)
        _model.Effect.MakeLove:SetActive(true)
    end
end

function ScenesInteract:InteractSEventHandler(_player, _id)
    if _id == 13 then
        for k, v in pairs(interactOBJ) do
            if v.obj.ScenesInteractUID.Value == _player.UserId then
                if v.useCount > 0 then
                    if v.itemID ~= nil then
                        NetUtil.Fire_C('GetItemEvent', _player, v.itemID)
                        if v.isUse then
                            wait(.1)
                            NetUtil.Fire_C('UseItemInBagEvent', _player, v.itemID)
                        end
                    end
                    if v.addBuffID then
                        NetUtil.Fire_C('GetBuffEvent', _player, v.addBuffID, v.addBuffDur)
                    end
                    NetUtil.Fire_S('SpawnCoinEvent', 'P', v.obj.Position + Vector3(0, 2.5, 0), v.rewardCoin)
                    v.useCount = v.useCount - 1
                    if v.useCount == 0 then
                        v.obj:SetActive(false)
                    end
                else
                    v.obj:SetActive(false)
                end
                NetUtil.Fire_C('ChangeMiniGameUIEvent', _player)
                return
            end
        end
    end
    if _id == 15 then
        NetUtil.Fire_C('ChangeMiniGameUIEvent', _player, 15)
        for k, v in pairs(seatOBJ) do
            if v.SeatInteractUID.Value == _player.UserId then
                v:Sit(_player)
                _player.Avatar:PlayAnimation('SitIdle', 2, 1, 0, true, true, 1)
                -- 音效
                SoundUtil.Play3DSE(_player.Position, 14)
            end
        end
    end
    if _id == 16 then
        for k, v in pairs(bonfireOBJ) do
            if v.BonfireInteractUID.Value == _player.UserId then
                if v.On.ActiveSelf then
                    v.On:SetActive(false)
                    v.Off:SetActive(true)
                else
                    v.On:SetActive(true)
                    v.Off:SetActive(false)
                end
            end
        end
        NetUtil.Fire_C('ChangeMiniGameUIEvent', _player)
        NetUtil.Fire_C('OpenDynamicEvent', _player, 'Interact', 16)
    end
    if _id == 17 then
        for k, v in pairs(bounceOBJ) do
            if v.obj.BounceInteractUID.Value == _player.UserId then
                this:ElasticDeformation(v, _player)
            end
        end
    end
    if _id == 18 then
        for k, v in pairs(grassOBJ) do
            if v.GrassInteractUID.Value == _player.UserId then
                this:GrassInter(v)
            end
        end
    end
    if _id == 20 then
        NetUtil.Fire_C('ChangeMiniGameUIEvent', _player, 20)
        for k, v in pairs(trojanObj) do
            if v.TrojanUID.Value == _player.UserId then
                v.Seat:Sit(_player)
                _player.Avatar:PlayAnimation('HTRide', 3, 1, 0, true, true, 1)
                _player.Avatar:PlayAnimation('SitIdle', 2, 1, 0, true, true, 1)
                -- 音效
                SoundUtil.Play3DSE(_player.Position, 15)
                this.TrojanList[v.Name] = {
                    model = v,
                    timer = 0,
                    totalTimer = 0,
                    originForward = v.Forward,
                    dirRatio = 1
                }
            end
        end
    end
    if _id == 21 then
        NetUtil.Fire_C('ChangeMiniGameUIEvent', _player, 21)
    end
    if _id == 22 then
        NetUtil.Fire_C('ChangeMiniGameUIEvent', _player, 22)
        for k, v in pairs(tentOBJ) do
            if v.TentUID1.Value == _player.UserId or v.TentUID2.Value == _player.UserId then
                _player.Avatar:SetActive(false)
                if not this.TentList[v.Name] then
                    this.TentList[v.Name] = {
                        model = v,
                        num = 0,
                        timer = 0
                    }
                end
                this.TentList[v.Name].num = this.TentList[v.Name].num + 1
                this:TentNumEffect(this.TentList[v.Name].num, v)
            end
        end
    end
    if _id == 23 then
        for k, v in pairs(bombOBJ) do
            NetUtil.Fire_C('ChangeMiniGameUIEvent', _player, 23)
            if v.BombUID.Value == _player.UserId then
                _player.LinearVelocity = (v.Position - _player.Position).Normalized * 10
                NetUtil.Fire_C('FsmTriggerEvent', v.insidePlayer, 'Fly')
            end
        end
    end
    if _id == 24 then
        for k, v in pairs(radioOBJ) do
            NetUtil.Fire_C('OpenDynamicEvent', _player, 'Interact', 24)
            if v.RadioUID.Value == _player.UserId then
                this.RadioData.songIndex = this.RadioData.songIndex + 1
                if this.RadioData.songIndex > #this.RadioData.songList then
                    this.RadioData.songIndex = 1
                end
                -- 先停止当前音乐，再播放
                if this.RadioData.curSong then
                    --NetUtil.Fire_C("StopEffectEvent", _player, "radio")
                else
                    v.Model.On:SetActive(true)
                end
                --[[NetUtil.Fire_C(
                    "PlayEffectEvent",
                    _player,
                    this.RadioData.songList[this.RadioData.songIndex],
                    v.Position,
                    "radio"
                )]]
                this.RadioData.curSong = true
            end
        end
    end
    if _id == 26 then
        for k,v in pairs(potOBJ) do
            NetUtil.Fire_C("ChangeMiniGameUIEvent", _player, 26)
            if v.PotUID.Value == _player.UserId then
                v.Off:SetActive(false)
                v.On:SetActive(true)
            end

        end
    end
end

function ScenesInteract:LeaveInteractSEventHandler(_player, _id)
    if _id == 15 then
        for k, v in pairs(seatOBJ) do
            if v.SeatInteractUID.Value == _player.UserId then
                v:Leave(_player)
                NetUtil.Fire_C('FsmTriggerEvent', _player, 'Jump')
                NetUtil.Fire_C('ChangeMiniGameUIEvent', _player)
            end
        end
    end
    if _id == 20 then
        for k, v in pairs(trojanObj) do
            if v.TrojanUID.Value == _player.UserId then
                v.Seat:Leave(_player)
                _player.Avatar:StopAnimation('HTRide', 3)
                _player.Avatar:StopAnimation('SitIdle', 2)
                NetUtil.Fire_C('FsmTriggerEvent', _player, 'Jump')
                NetUtil.Fire_C('ChangeMiniGameUIEvent', _player)
                NetUtil.Fire_C('StopEffectEvent', _player, v.Name)
                v.Forward = this.TrojanList[v.Name].originForward
                this.TrojanList[v.Name] = nil
            end
        end
    end
    if _id == 21 then
        NetUtil.Fire_C('ChangeMiniGameUIEvent', _player)
    end
    if _id == 22 then
        NetUtil.Fire_C('ChangeMiniGameUIEvent', _player)
        _player.Avatar:SetActive(true)
        for k, v in pairs(tentOBJ) do
            if v.TentUID1.Value == _player.UserId or v.TentUID2.Value == _player.UserId then
                this.TentList[v.Name].num = this.TentList[v.Name].num - 1
                this:TentNumEffect(this.TentList[v.Name].num, v)
                if this.TentList[v.Name].num == 0 then
                    this.TentList[v.Name] = nil
                    v.Effect:SetActive(false)
                end
            end
        end
    end
    if _id == 23 then
        for k, v in pairs(bombOBJ) do
            if v.BombUID.Value == _player.UserId then
                NetUtil.Fire_C('ChangeMiniGameUIEvent', _player)
            end
        end
    end
    if _id == 24 then
        for k, v in pairs(radioOBJ) do
            if v.RadioUID.Value == _player.UserId then
                NetUtil.Fire_C('ChangeMiniGameUIEvent', _player)
            end
        end
    end
    if _id == 26 then
        for k,v in pairs(potOBJ) do
            NetUtil.Fire_C("ChangeMiniGameUIEvent", _player)
            if v.PotUID.Value == _player.UserId then
                v.Off:SetActive(true)
                v.On:SetActive(false)
            end

        end
    end
end

--重置交互物体
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
