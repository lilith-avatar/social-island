--- 玩家社交动画模块
--- @module Player Social Animation, client-side
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang, Dead Ratman
local GuiSocialAnim, this = ModuleUtil.New('GuiSocialAnim', ClientBase)

-- Gui
local SocialAnimationGUI
local switchBtn
local bg
local pre
local next

-- Data
local curGroup = 1
local bgSize
local bgOffset

-- Tween
local zoomTweener

function GuiSocialAnim:Init()
    this:InitGui()
    this:InitListener()
    this:EventBind()
end

function GuiSocialAnim:InitGui()
    SocialAnimationGUI = localPlayer.Local.SpecialBottomUI.SocialAnimationGUI
    switchBtn = localPlayer.Local.ControlGui.Ctrl.SocialAnimBtn
    bg = SocialAnimationGUI.Bg
    pre = bg.Pre
    next = bg.Next

    bgSize = bg.Size
    bgOffset = bg.Offset

    zoomTweener = Tween:TweenProperty(bg, {Size = bgSize, Offset = Vector2.Zero}, 0.15, 1)
end

function GuiSocialAnim:EventBind()
    switchBtn.OnDown:Connect(
        function()
            if SocialAnimationGUI.ActiveSelf then
                SocialAnimationGUI:SetActive(false)
                SoundUtil.Play2DSE(localPlayer.UserId, 6)
            else
                SoundUtil.Play2DSE(localPlayer.UserId, 36)
                this:SetCurGroupAnimSlot(curGroup)
                this:UIStartTween()
            end
        end
    )

    pre.OnDown:Connect(
        function()
            if curGroup == 1 then
                curGroup = 5
            else
                curGroup = curGroup - 1
            end
            this:SetCurGroupAnimSlot(curGroup)
            SoundUtil.Play2DSE(localPlayer.UserId, 101)
        end
    )

    next.OnDown:Connect(
        function()
            if curGroup == 5 then
                curGroup = 1
            else
                curGroup = curGroup + 1
            end
            this:SetCurGroupAnimSlot(curGroup)
            SoundUtil.Play2DSE(localPlayer.UserId, 101)
        end
    )
end

function GuiSocialAnim:InitListener()
end

--设置动作槽位UI
function this:SetAnimSlot(_data)
    local slot = _data.ID % 6 + 1
    local slotBtnUI = bg['Btn' .. slot]
    slotBtnUI.OnClick:Clear()
    slotBtnUI.Info.TextSize = 20 - math.ceil(string.len(_data.ShowName) / 1.5)
    slotBtnUI.Info.Text = _data.ShowName
    slotBtnUI.Icon.Texture = ResourceManager.GetTexture('SocialAnimationIcon/' .. _data.Icon)
    slotBtnUI.OnClick:Connect(
        function()
            SoundUtil.Play2DSE(localPlayer.UserId, 101)
            CloudLogUtil.UploadLog('pannel_actions', 'movement_stickers_' .. _data.AnimName)
            SocialAnimationGUI:SetActive(false)
            --localPlayer.Avatar:PlayAnimation(_data.AnimName, _data.BodyPart, 1, 0.1, true, false, 1)
            NetUtil.Fire_C('PlayAnimationEvent', localPlayer, _data.AnimName, 0, 1, 0.2, 0.2, true, false, 1)
        end
    )
end

--设置当前组的槽位
function GuiSocialAnim:SetCurGroupAnimSlot(_group)
    for i = 1, 6 do
        this:SetAnimSlot(Config.SocialAnim[i + (_group - 1) * 6])
    end
end

--UI的呼出动画
function GuiSocialAnim:UIStartTween()
    bg.Size = bgSize * 0.1
    bg.Offset = bgOffset + Vector2(-150, -100)
    SocialAnimationGUI:SetActive(true)
    zoomTweener:Play()
end

function GuiSocialAnim:Update(dt)
    if switchBtn.ActiveSelf == false and SocialAnimationGUI.ActiveSelf == true then
        SocialAnimationGUI:SetActive(false)
    end
end

return GuiSocialAnim
