--- 玩家社交动画模块
--- @module Player Social Animation, client-side
--- @copyright Lilith Games, Avatar Team
--- @author 王殷鹏, Yuancheng Zhang
local SocialAnimation, this = ModuleUtil.New('SocialAnimation', ClientBase)

local PlayerAnimation = PlayerAnimation

local AnimationList = {}
local AnimationTbl = {}

function SocialAnimation:Init()
    RootUI = localPlayer.Local.ControlGui.AnimationPanel
    RootUI.Header.Color = Color(255, 255, 255, 180)
    CloseButton = RootUI.Close
    AnimationBtn = localPlayer.Local.ControlGui.AnimationBtn
    EmotionPanel = RootUI.Emotion
    DancePanel = RootUI.Dance
    MultiplayerPanel = RootUI.Multiplayer
    PanelTbl = {EmotionPanel, DancePanel, MultiplayerPanel}
    CurrentIndex = 0

    ButtonTbl = {RootUI.EmotionButton, RootUI.DanceButton, RootUI.MultiplayerButton}
    EmotionTbl = {}
    DanceTbl = {}
    MultiplayerTbl = {}
    OverallTbl = {EmotionTbl, DanceTbl, MultiplayerTbl}
    self.CurrentAnimLogic = nil
    self:CreatePanel()
    self:InitListener()
end

function SocialAnimation:InitListener()
    AnimationBtn.OnDown:Connect(ToggleAnimPanel)
    CloseButton.OnDown:Connect(CloseAnimPanel)
    localPlayer.OnStateChanged:Connect(OnPlayerStateChanged)
end

function SocialAnimation:ClearSelected()
    for i, v in pairs(ButtonTbl) do
        v.TextColor = Color(255, 255, 255, 255)
        v.Line.Visible = false
    end
    for i, v in pairs(PanelTbl) do
        v.Visible = false
    end
end

function SocialAnimation:CreateButton(type, index, showname, name, bodyPart, loopMode, icon, num, length, scale)
    local Panel = PanelTbl[type]
    local Button = world:CreateInstance('AnimationButton', name, Panel)
    Button.Info.Text = showname
    if type == 2 then
        Button.Info.FontSize = 25
    elseif type == 3 then
        Button.Info.FontSize = 20
    end
    Button.Image = ResourceManager.GetTexture('AnimationIcon/' .. icon)
    local Gap = 0.1
    local PosX = ((Gap + 1) * index - 0.5) / ((Gap + 1) * num + Gap)
    Button.AnchorsX = Vector2(PosX, PosX) * scale
    Button.AnchorsY = Vector2(0.7, 0.7)
    Button.Size = Vector2(length / 1.4 * 0.7, length / 1.4 * 0.7)
    local AnimationLogic = PlayerAnimation:New(localPlayer, name, 2, bodyPart, loopMode, showname)
    AnimationLogic:AddEvent(
        showname,
        1,
        function()
            AnimationLogic.Playing = false
            PlayerAnimation.mySocket = nil
            if showname == 'Clap' then
                if AnimationLogic.Count then
                    AnimationLogic.Count = AnimationLogic.Count + 1
                else
                    AnimationLogic.Count = 1
                end
                if AnimationLogic.Count >= 5 then
                    AnimationLogic.Count = 0
                    invoke(
                        function()
                            localPlayer.Effect.ClapEffect:SetActive(true)
                            wait(0.8)
                            localPlayer.Effect.ClapEffect:SetActive(false)
                        end
                    )
                end
            end
        end
    )
    Button:ToTop()
    Button.OnUp:Connect(
        function()
            self:ClearTrigger()
            if type == 3 then
                world:CreateInstance('MultiAnimation', showname, localPlayer, localPlayer.Position)
            end
            if localPlayer.State == Enum.CharacterState.Idle then
                self.CurrentAnimLogic = AnimationLogic
                AnimationLogic:Play(1, 1, 0.2)
            end
        end
    )
end

function SocialAnimation:CreatePanel()
    for i, info in ipairs(Config.SocialAnim) do
        table.insert(OverallTbl[info.AnimClass], info)
    end

    for i, v in pairs(PanelTbl) do
        if #OverallTbl[i] > 5 then
            v.Scroll = Enum.ScrollBarType.Horizontal
            v.ScrollRange = #OverallTbl[i] / 5.5 * v.FinalSize.X
            v.AnimationBack.AnchorsX = Vector2(0, v.ScrollRange / v.FinalSize.x)
        else
            v.Scroll = Enum.ScrollBarType.None
            v.ScrollRange = v.FinalSize.x
        end
    end

    for i, v in pairs(OverallTbl) do
        for i1, v1 in pairs(v) do
            self:CreateButton(
                i,
                i1,
                v1.ShowName,
                v1.AnimName,
                v1.BodyPart,
                v1.LoopMode,
                v1.Icon,
                #v,
                PanelTbl[i].FinalSize.y,
                PanelTbl[i].ScrollRange / PanelTbl[i].FinalSize.x
            )
        end
    end

    for i, v in pairs(ButtonTbl) do
        v.Color = Color(255, 255, 255, 0)
        v.OnDown:Connect(
            function()
                self:ClearSelected()
                v.Line.Visible = true
                v.TextColor = Color(255, 130, 67, 255)
                PanelTbl[i].Visible = true
            end
        )
    end
end

function SocialAnimation:ClearTrigger()
    for i, v in pairs(localPlayer:GetChildren()) do
        if v.TriggerItem then
            v:Destroy()
        end
    end
end

function SocialAnimation:BeginIK(my, target)
    PlayerAnimation:BeginIK(my, target)
end

function SocialAnimation:StopIK()
    PlayerAnimation:StopIK()
end

function CloseAnimPanel()
    RootUI.Visible = false
end

function ToggleAnimPanel()
    RootUI.Visible = not RootUI.Visible
end

function OnPlayerStateChanged(oldState, newState)
    if newState == Enum.CharacterState.Jump or oldState == Enum.CharacterState.Idle then
        this:ClearTrigger()
        if this.CurrentAnimLogic then
            this:StopIK()
            if this.CurrentAnimLogic.BodyPart == Enum.BodyPart.FullBody then
                this.CurrentAnimLogic:Stop()
            elseif this.CurrentAnimLogic.BodyPart == Enum.BodyPart.UpperBody and this.CurrentAnimLogic.Playing then
                this.CurrentAnimLogic:ChangeBodyPart(Enum.BodyPart.UpperBody)
            end
        end
    end
    if newState == Enum.AnimationMode.Idle then
        if this.CurrentAnimLogic and this.CurrentAnimLogic.Playing then
            if this.CurrentAnimLogic.BodyPart == Enum.BodyPart.UpperBody then
                this.CurrentAnimLogic:ChangeBodyPart(Enum.BodyPart.FullBody)
            end
        end
    end
end

return SocialAnimation
