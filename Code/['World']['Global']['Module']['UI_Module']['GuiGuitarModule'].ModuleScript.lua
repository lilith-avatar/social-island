---@module GuiGuitar
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local GuiGuitar, this = ModuleUtil.New("GuiGuitar", ClientBase)

local function SortBackFret(_backFret)
    table.sort(
        _backFret,
        function(p1, p2)
            return p1 > p2
        end
    )
end

---初始化函数
function GuiGuitar:Init()
    this:DataInit()
    this:NodeDef()
    this:EventBind()
    this:StringInit()
end

function GuiGuitar:DataInit()
    this.stringAudio = {}
    this.stringPitch = {}
    this.chordTime = 0
    this.fretTime = 0
    this.stringTime = 0
    this.practiceMode = false
end

function GuiGuitar:NodeDef()
    this.gui = localPlayer.Local.GuitarGui
    this.fret = this.gui.BGImg.FretPanel:GetChildren()
    this.string = this.gui.BGImg.StringPanel:GetChildren()
    this.chordBtn = this.gui.BGImg.ChordPanel:GetChildren()
    this.chordModeBtn = this.gui.ModePanel.ChordModeBtn
    this.proModeBtn = this.gui.ModePanel.ProModeBtn
    this.closeBtn = this.gui.CloseBtn
end

function GuiGuitar:StringInit()
    this.stringPitch = {}
    for i = 1, 6 do
        local data = {
            pitchFret = 0,
            backFret = {}
        }
        table.insert(this.stringPitch, data)
    end
end

function GuiGuitar:EventBind()
    for k, v in ipairs(this.string) do
        v.OnEnter:Connect(
            function()
                this:PlayString(k)
            end
        )
    end
    for k, v in ipairs(this.fret) do
        for m, n in ipairs(v:GetChildren()) do
            n.OnEnter:Connect(
                function()
                    this:PressFret(m, k)
                end
            )
            n.OnLeave:Connect(
                function()
                    this:RealseFret(m, k)
                end
            )
        end
    end
    for k, v in pairs(this.chordBtn) do
        v.OnClick:Connect(
            function()
                this:ChangeChord(v.Name)
                v.Color = Color(0, 85, 255, 255)
            end
        )
    end
    this.closeBtn.OnClick:Connect(
        function()
            this:StringInit()
            this:HideGui()
        end
    )
    this.chordModeBtn.OnClick:Connect(
        function()
            this:ChangeMode(true)
        end
    )
    this.proModeBtn.OnClick:Connect(
        function()
            this:ChangeMode(false)
        end
    )
end

function GuiGuitar:PlayString(_string)
    --local playPos = not this.practiceMode and localPlayer.Position or nil
    this.stringTime = this.stringTime + 1
    -- 播放对应弦的音效
    SoundUtil.Play2DSE(localPlayer.UserId, Config.GuitarPitch[_string].Pitch[this.stringPitch[_string].pitchFret])
    local Tweener = Tween:ShakeProperty(this.string[_string].StringImg, {"Offset"}, 0.5, 2)
    Tweener:Play()
end

function GuiGuitar:ChangeMode(_isChordMode)
    --this.practiceMode = not this.practiceMode
    --this.practiceBtn.Color = this.practiceMode and Color(85, 85, 127) or Color(255, 255, 255)
    this.gui.BGImg.ChordPanel:SetActive(_isChordMode)
    this.chordModeBtn.Color= _isChordMode and Color(0, 85, 255, 255) or Color(255, 255, 255, 255)
    this.proModeBtn.Color= _isChordMode and Color(255, 255, 255, 255) or Color(0, 85, 255, 255)
    if _isChordMode then
        this:ChangeChord(this.chordBtn[1].Name)
        this.chordBtn[1].Color = Color(0, 85, 255, 255)
        this.gui.BGImg.ChordDisable:SetActive(true)
    else
        this.gui.BGImg.ChordDisable:SetActive(false)
        this:StringInit()
    end
end

--- 按弦
function GuiGuitar:PressFret(_string, _fret)
    if _fret == this.stringPitch[_string].pitchFret then
        return
    end
    if _fret > this.stringPitch[_string].pitchFret then
        table.insert(this.stringPitch[_string].backFret, this.stringPitch[_string].pitchFret)
        this.stringPitch[_string].pitchFret = _fret
    else
        table.insert(this.stringPitch[_string].backFret, _fret)
    end
    this.fretTime = this.fretTime + 1
    SortBackFret(this.stringPitch[_string].backFret)
end

--- 松弦
function GuiGuitar:RealseFret(_string, _fret)
    if this.stringPitch[_string].pitchFret == _fret then
        this.stringPitch[_string].pitchFret = this.stringPitch[_string].backFret[1]
        table.remove(this.stringPitch[_string].backFret, 1)
    else
        for k, v in pairs(this.stringPitch[_string].backFret) do
            if v == _fret then
                table.remove(this.stringPitch[_string].backFret, k)
            end
        end
    end
end

function GuiGuitar:HideGui()
    this.gui:SetActive(false)
    CloudLogUtil.UploadLog('guitar','leave',{string_num = this.stringTime,chord_num = this.chordTime,fret_num = this.fretTime})
    NetUtil.Fire_C("ChangeMiniGameUIEvent", localPlayer)
end

function GuiGuitar:ChangeChord(_chord)
    this.chordTime = this.chordTime + 1
    --所有的按钮回复白色
    for k, v in pairs(this.chordBtn) do
        v.Color = Color(255, 255, 255, 255)
    end
    for k, v in pairs(Config.ChordFret[_chord].StringFret) do
        this.stringPitch[k].pitchFret = v
    end
end

function GuiGuitar:InteractCEventHandler()
end

function GuiGuitar:ChangeMiniGameUIEventHandler(_id)
	if _id == 21 then
	    CloudLogUtil.UploadLog('guitar', 'enter')
	end
end


return GuiGuitar
