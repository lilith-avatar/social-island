--- 打猎Gui模块
--- @module Player Cannon, client-side
--- @copyright Lilith Games, Avatar Team
local GuiHunt, this = ModuleUtil.New("GuiHunt", ClientBase)

local huntGui

function GuiHunt:Init()
    print("GuiHunt:Init")
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

function GuiHunt:NodeRef()
    huntGui = localPlayer.Local.HuntGUI
end

function GuiHunt:DataInit()
end

function GuiHunt:EventBind()
    huntGui.Figure.ShootBtn.OnClick:Connect(
        function()
            FsmMgr:FsmTriggerEventHandler("BowAttack")
        end
    )
    huntGui.Figure.LeaveBtn.OnClick:Connect(
        function()
            this:LeaveBow()
        end
    )
end

-- 显示小游戏的GUI
function GuiHunt:SetMiniGameGuiEventHandler(_gameId, _selfActive, _ctrlGuiActive)
    if _gameId == 1 then
        huntGui:SetActive(_selfActive)
        PlayerCam:SetCurCamEventHandler(PlayerCam.tpsCam)
        invoke(
            function()
                localPlayer.Local.ControlGui:SetActive(_ctrlGuiActive)
            end,
            0.5
        )
        NetUtil.Fire_C("SetDefUIEvent", localPlayer, false, {"Menu"})
        NetUtil.Fire_C("SetDefUIEvent", localPlayer, false, {"UseBtn"}, localPlayer.Local.ControlGui.Ctrl)
    --localPlayer.Local.ControlGui.UseBtn:SetActive(false)
    --localPlayer.Local.ControlGui.SocialAnimBtn:SetActive(false)
    end
end

-- 退出弓箭状态
function GuiHunt:LeaveBow()
    PlayerCam:SetCurCamEventHandler()
    NetUtil.Fire_C("FsmTriggerEvent", localPlayer, "Idle")
    huntGui:SetActive(false)
    NetUtil.Fire_C("ResetDefUIEvent", localPlayer)
    --localPlayer.Local.ControlGui.UseBtn:SetActive(true)
    --localPlayer.Local.ControlGui.SocialAnimBtn:SetActive(true)
end

function GuiHunt:Update(dt)
end

return GuiHunt
