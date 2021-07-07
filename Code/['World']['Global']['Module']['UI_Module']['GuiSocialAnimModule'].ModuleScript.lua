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

local actAnimTable = {}

function GuiSocialAnim:Init()
    this:InitGui()
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
            SocialAnimationGUI:SetActive(not SocialAnimationGUI.ActiveSelf)
            self:ActiveChildActBtn()
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

function GuiSocialAnim:PlayActAnim(_data)
    FsmMgr.playerActCtrl:GetActInfo(_data)
    FsmMgr.playerActCtrl:CallTrigger('ActBeginState')
end

function GuiSocialAnim:PlayActAnimEventHandler(_id)
    FsmMgr.playerActCtrl:GetActInfo(Config.SocialAnim[_id])
    FsmMgr.playerActCtrl:CallTrigger('ActBeginState')
end

function GuiSocialAnim:ActiveChildActBtn()
    if SocialAnimationGUI.ActiveSelf then
        actAnimTable = {}
        for k, v in pairs(Config.SocialAnim) do
            if v.Mode == FsmMgr.playerActCtrl.actAnimMode then
                table.insert(actAnimTable, v)
            end
        end
        if #actAnimTable == 0 then
            SocialAnimationGUI:SetActive(false)
            SoundUtil.Play2DSE(localPlayer.UserId, 6)
            return
        end

        SoundUtil.Play2DSE(localPlayer.UserId, 36)
        this:SetCurGroupAnimSlot(curGroup)
        this:UIStartTween()
    end
    return
end

--设置动作槽位UI
function GuiSocialAnim:SetAnimSlot(_slot, _data)
    local slotBtnUI = bg['Btn' .. _slot]
    slotBtnUI:SetActive(false)
    if _data then
        slotBtnUI.OnClick:Clear()
        slotBtnUI.Info.TextSize = 20 - math.ceil(string.len(_data.ShowName) / 1.5)
        slotBtnUI.Info.Text = _data.ShowName
        slotBtnUI.Icon.Texture = ResourceManager.GetTexture('SocialAnimationIcon/' .. _data.Icon)
        slotBtnUI:SetActive(true)
        slotBtnUI.OnClick:Connect(
            function()
                SoundUtil.Play2DSE(localPlayer.UserId, 101)
                CloudLogUtil.UploadLog('pannel_actions', 'movement_stickers_' .. _data.anim[2])
                SocialAnimationGUI:SetActive(false)
                this:PlayActAnim(_data)
            end
        )
    end
end

--设置当前组的槽位
function GuiSocialAnim:SetCurGroupAnimSlot(_group)
    for i = 1, 6 do
        if Config.SocialAnim[i + (_group - 1) * 6] then
            this:SetAnimSlot(i, Config.SocialAnim[i + (_group - 1) * 6])
        else
            this:SetAnimSlot(i)
        end
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
