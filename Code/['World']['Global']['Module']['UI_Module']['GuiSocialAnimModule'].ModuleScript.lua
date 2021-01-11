--- 玩家社交动画模块
--- @module Player Social Animation, client-side
--- @copyright Lilith Games, Avatar Team
--- @author 王殷鹏, Yuancheng Zhang
local GuiSocialAnim, this = ModuleUtil.New('GuiSocialAnim', ClientBase)

local PlayerAnimation = PlayerAnimation

-- GUI
local uiRoot
local HEADER_COLOR = Color(255, 255, 255, 180)
local CREATE_PANEL_DELAY = .2

-- Data
local emoTbl, danceTbl, multiTbl = {}, {}, {}
local overallTbl = {emoTbl, danceTbl, multiTbl}

function GuiSocialAnim:Init()
    print('[GuiSocialAnim] Init()')
    self.currAnimLogic = nil
    self:InitGui()
    self:InitListener()
    invoke(CreatePanel, CREATE_PANEL_DELAY)
end

function GuiSocialAnim:InitGui()
    uiRoot = localPlayer.Local.ControlGui.SocialAnimPnl
    uiRoot.HeaderImg.Color = HEADER_COLOR
    -- Buttons
    closeBtn = uiRoot.CloseBtn
    animBtn = localPlayer.Local.ControlGui.Menu.SocialAnimBtn
    animBtn.Visible = false
    -- Panels
    emoPnl = uiRoot.EmotionPnl
    dancePnl = uiRoot.DancePnl
    multiPnl = uiRoot.MultiplayerPnl
    -- Tables
    panelTbl = {emoPnl, dancePnl, multiPnl}
    btnTbl = {uiRoot.EmotionBtn, uiRoot.DanceBtn, uiRoot.MultiplayerBtn}
end

function GuiSocialAnim:InitListener()
    animBtn.OnDown:Connect(ToggleAnimPanel)
    closeBtn.OnDown:Connect(CloseAnimPanel)
    localPlayer.OnStateChanged:Connect(OnPlayerStateChanged)
end

function GuiSocialAnim:BeginIK(my, target)
    PlayerAnimation:BeginIK(my, target)
end

function GuiSocialAnim:StopIK()
    PlayerAnimation:StopIK()
end

function CreatePanel()
    for i, info in ipairs(Config.SocialAnim) do
        table.insert(overallTbl[info.AnimClass], info)
    end

    for i, v in pairs(panelTbl) do
        if #overallTbl[i] > 5 then
            --TODO: 用下面这行代码测试，目前会有缩放问题
            -- print(v.FinalSize.x, v.FinalSize.y)
            v.Scroll = Enum.ScrollBarType.Horizontal
            v.ScrollRange = #overallTbl[i] / 5.5 * v.FinalSize.x
            v.AnimationBack.AnchorsX = Vector2(0, v.ScrollRange / v.FinalSize.x)
        else
            v.Scroll = Enum.ScrollBarType.None
            v.ScrollRange = v.FinalSize.x
        end
    end

    for i, v in pairs(overallTbl) do
        for i1, v1 in pairs(v) do
            CreateButton(
                i,
                i1,
                v1.ShowName,
                v1.AnimName,
                v1.BodyPart,
                v1.LoopMode,
                v1.Icon,
                #v,
                panelTbl[i].FinalSize.y,
                panelTbl[i].ScrollRange / panelTbl[i].FinalSize.x
            )
            -- 分帧创建
            wait()
        end
    end

    for i, v in pairs(btnTbl) do
        v.Color = Color(255, 255, 255, 0)
        v.OnDown:Connect(
            function()
                ClearSelected()
                v.Line.Visible = true
                v.TextColor = Color(255, 130, 67, 255)
                panelTbl[i].Visible = true
            end
        )
    end

    print('[GuiSocialAnim] CreatePanel() done')
    animBtn.Visible = true
end

function CreateButton(type, index, showname, name, bodyPart, loopMode, icon, num, length, scale)
    local Panel = panelTbl[type]
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
            ClearTrigger()
            if type == 3 then
                world:CreateInstance('MultiAnimation', showname, localPlayer, localPlayer.Position)
            end
            if localPlayer.State == Enum.CharacterState.Idle then
                this.currAnimLogic = AnimationLogic
                AnimationLogic:Play(1, 1, 0.2)
            end
        end
    )
end

function ClearSelected()
    for i, v in pairs(btnTbl) do
        v.TextColor = Color(255, 255, 255, 255)
        v.Line.Visible = false
    end
    for i, v in pairs(panelTbl) do
        v.Visible = false
    end
end

function ClearTrigger()
    for i, v in pairs(localPlayer:GetChildren()) do
        if v.TriggerItem then
            v:Destroy()
        end
    end
end

function CloseAnimPanel()
    uiRoot.Visible = false
end

function ToggleAnimPanel()
    uiRoot.Visible = not uiRoot.Visible
end

function OnPlayerStateChanged(oldState, newState)
    if newState == Enum.CharacterState.Jump or oldState == Enum.CharacterState.Idle then
        ClearTrigger()
        if this.currAnimLogic then
            this:StopIK()
            if this.currAnimLogic.BodyPart == Enum.BodyPart.FullBody then
                this.currAnimLogic:Stop()
            elseif this.currAnimLogic.BodyPart == Enum.BodyPart.UpperBody and this.currAnimLogic.Playing then
                this.currAnimLogic:ChangeBodyPart(Enum.BodyPart.UpperBody)
            end
        end
    end
    if newState == Enum.AnimationMode.Idle then
        if this.currAnimLogic and this.currAnimLogic.Playing then
            if this.currAnimLogic.BodyPart == Enum.BodyPart.UpperBody then
                this.currAnimLogic:ChangeBodyPart(Enum.BodyPart.FullBody)
            end
        end
    end
end

return GuiSocialAnim
