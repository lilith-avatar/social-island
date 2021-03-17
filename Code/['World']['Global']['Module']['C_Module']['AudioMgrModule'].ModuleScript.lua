---  音效模块：
-- @module  AudioMgr
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
---@module AudioMgr

local AudioMgr, this = ModuleUtil.New("AudioMgr", ClientBase)

local BGMAudioSources = {}
local BGMClips = {}
local EffectAudioSources = {}
local EffectClips = {}

function AudioMgr:Init()
    print("[AudioMgr] Init()")
    this:NodeRef()
    this:DataInit()
    this:EventBind()
    this:PlayBGM(2)
end

--节点引用
function AudioMgr:NodeRef()
end

--数据变量声明
function AudioMgr:DataInit()
    this.BGMAudioSourceNode = PlayerCam.playerGameCam["BGMNode"]
    this.EffectAudioSourceNode = PlayerCam.playerGameCam["SENode"]

    for k, v in pairs(Config.Sound) do
        if v.Type == "SoundEffect" then
            this:InitEffectClip(v)
        elseif v.Type == "BGM" then
            this:InitBGMClip(v)
        end
    end

    for i = 1, 2 do
        this:InitBGMSource(i)
    end
    for i = 1, 3 do
        this:InitEffectSource(i)
    end
end

--节点事件绑定
function AudioMgr:EventBind()
end

function AudioMgr:Update(dt, tt)
end

--初始化一个BGM播放器
function AudioMgr:InitBGMSource(_index)
    BGMAudioSources[_index] = {
        Source = world:CreateObject("AudioSource", "BGMSource" .. _index, this.BGMAudioSourceNode),
        Index = _index
    }
    return BGMAudioSources[_index]
end

--初始化一个Effect播放器
function AudioMgr:InitEffectSource(_index)
    local tempSourceR =
        world:CreateObject(
        "AudioSource",
        "EffectSource" .. _index .. "Right",
        this.EffectAudioSourceNode,
        PlayerCam.playerGameCam.Position + PlayerCam.playerGameCam.Right
    )
    local tempSourceL =
        world:CreateObject(
        "AudioSource",
        "EffectSource" .. _index .. "Left",
        this.EffectAudioSourceNode,
        PlayerCam.playerGameCam.Position + PlayerCam.playerGameCam.Left
    )
    EffectAudioSources[_index] = {
        SourceRight = tempSourceR,
        SourceLeft = tempSourceL,
        Index = _index
    }
    return EffectAudioSources[_index]
end

--释放多余播放器
local function ReleaeseSource(_bgmNum, _effectNum)
    local index = _bgmNum + 1
    while table.nums(BGMAudioSources) > index - 1 do
        print("index:" .. index)
        if BGMAudioSources[index].Source.State == Enum.AudioSourceState.Stopped then
            local ReleaesedSource = BGMAudioSources[index].Source
            table.remove(BGMAudioSources, index)
            ReleaesedSource:Destroy()
        else
            index = index + 1
        end
    end
    local index2 = _effectNum + 1
    while table.nums(EffectAudioSources) > index2 - 1 do
        if
            EffectAudioSources[index2].SourceRight.State == Enum.AudioSourceState.Stopped and
                EffectAudioSources[index2].SourceLeft.State == Enum.AudioSourceState.Stopped
         then
            local ReleaesedSourceRight, ReleaesedSourceLeft =
                EffectAudioSources[index2].SourceRight,
                EffectAudioSources[index2].SourceLeft
            table.remove(EffectAudioSources, index2)
            ReleaesedSourceRight:Destroy()
            ReleaesedSourceLeft:Destroy()
        else
            index2 = index2 + 1
        end
    end
end

--初始化一个BGM音频
function AudioMgr:InitBGMClip(_data)
    BGMClips[_data.ID] = {
        id = _data.ID,
        clip = ResourceManager.GetSoundClip(_data.Path),
        isLoop = _data.IsLoop,
        volume = _data.Volume
    }
end

--初始化一个Effect音频
function AudioMgr:InitEffectClip(_data)
    EffectClips[_data.ID] = {
        id = _data.ID,
        clip = ResourceManager.GetSoundClip(_data.Path),
        isLoop = _data.IsLoop,
        volume = _data.Volume
    }
end

--播放bgm
function AudioMgr:PlayBGM(_id)
    local PlayTable = nil
    for k, v in pairs(BGMAudioSources) do
        if v.Source.State == Enum.AudioSourceState.Stopped then
            PlayTable = v
            break
        end
    end
    if PlayTable == nil then
        PlayTable = this:InitBGMSource(table.nums(BGMAudioSources) + 1)
    end
    PlayTable.Source.Loop = BGMClips[_id].isLoop
    PlayTable.Source.Volume = BGMClips[_id].volume
    PlayTable.Source.SoundClip = BGMClips[_id].clip
    PlayTable.Source:FadePlay(1)
    ReleaeseSource(2, 3)
    return PlayTable.Index
end

--停止播放BGM
function AudioMgr:StopBGM(_index)
    BGMAudioSources[_index].Source:Stop()
    ReleaeseSource(2, 3)
end

--计算播放音量和延迟
function AudioMgr:SimulateData(_pos)
    _pos = _pos or localPlayer.Position + localPlayer.Forward
    local rightVolume, leftVolume, volumeDif = 0, 0, 0
    local angleForward, angleRight =
        Vector3.Angle(localPlayer.Forward, _pos - localPlayer.Position),
        Vector3.Angle(localPlayer.Right, _pos - localPlayer.Position)

    if angleForward < 90 then
        volumeDif = math.sin(math.rad(angleForward))
    else
        volumeDif = math.sin(math.rad(angleForward))
    end

    if angleRight < 90 then
        rightVolume = 15 / (_pos - localPlayer.Position).Magnitude
        leftVolume = 15 * (1 - volumeDif) / (_pos - localPlayer.Position).Magnitude
    else
        rightVolume = 15 * (1 - volumeDif) / (_pos - localPlayer.Position).Magnitude
        leftVolume = 15 / (_pos - localPlayer.Position).Magnitude
    end
    return {_rightVolume = rightVolume, _leftVolume = leftVolume}
end

--播放器通过数据播放音效
function AudioMgr:SimulatePlay(_playTable, _data)
    if _data._rightVolume > 1 then
        _data._rightVolume = 1
    end
    if _data._leftVolume > 1 then
        _data._leftVolume = 1
    end
    if _data._rightVolume < 0.005 then
        _data._rightVolume = 0
    end
    if _data._leftVolume < 0.005 then
        _data._leftVolume = 0
    end
    if _playTable then
        _playTable.SourceRight.Volume = math.floor(_playTable.SourceRight.Volume * _data._rightVolume)
        _playTable.SourceLeft.Volume = math.floor(_playTable.SourceLeft.Volume * _data._leftVolume)
    end
    _playTable.SourceRight:Play()
    _playTable.SourceLeft:Play()
end

--播放3Deffect
function AudioMgr:PlayEffectEventHandler(_id, _pos, _playerIndex)
    print("播放3Deffect,id:", _id)
    if _id ~= 0 then
        this.EffectAudioSourceNode.Position = _pos or PlayerCam.playerGameCam.Position
        local PlayTable = nil
        for k, v in pairs(EffectAudioSources) do
            if
                v.SourceRight.State == Enum.AudioSourceState.Stopped and
                    v.SourceLeft.State == Enum.AudioSourceState.Stopped
             then
                PlayTable = v
                break
            end
        end
        if PlayTable == nil then
            PlayTable = this:InitEffectSource(table.nums(EffectAudioSources) + 1)
        end
        PlayTable.SourceRight.Loop = EffectClips[_id].isLoop
        PlayTable.SourceRight.Volume = EffectClips[_id].volume
        PlayTable.SourceRight.SoundClip = EffectClips[_id].clip
        PlayTable.SourceLeft.Loop = EffectClips[_id].isLoop
        PlayTable.SourceLeft.Volume = EffectClips[_id].volume
        PlayTable.SourceLeft.SoundClip = EffectClips[_id].clip
        PlayTable.Index = _playerIndex
        this:SimulatePlay(PlayTable, this:SimulateData(_pos))
        ReleaeseSource(2, 3)
    end
end

--停止播放Effect
function AudioMgr:StopEffectEventHandler(_index)
    for k, v in pairs(EffectAudioSources) do
        if v.Index == _index then
            v.SourceRight:Stop()
            v.SourceLeft:Stop()
            break
        end
    end
    ReleaeseSource(2, 3)
end

return AudioMgr
