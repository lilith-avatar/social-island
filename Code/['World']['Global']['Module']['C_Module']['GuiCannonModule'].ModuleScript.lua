--- 人间大炮Gui模块
--- @module Player Cannon, client-side
--- @copyright Lilith Games, Avatar Team
local GuiCannon, this = ModuleUtil.New("GuiCannon", ClientBase)

local cannonGui

local forceBarFillAmount = 0
local isAdd = true

function GuiCannon:Init()
    print("GuiCannon:Init")
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

function GuiCannon:NodeRef()
    cannonGui = localPlayer.Local.CannonGUI
end

function GuiCannon:DataInit()
end

function GuiCannon:EventBind()
    cannonGui.Figure.FireBtn.OnDown:Connect(
        function()
            NetUtil.Fire_S("CannonFireEvent", forceBarFillAmount)
        end
    )
    cannonGui.Figure.UpBtn.OnDown:Connect(
        function()
            NetUtil.Fire_S("SetCannonDirEvent", "Up")
        end
    )
    cannonGui.Figure.DownBtn.OnDown:Connect(
        function()
            NetUtil.Fire_S("SetCannonDirEvent", "Down")
        end
    )
    cannonGui.Figure.RightBtn.OnDown:Connect(
        function()
            NetUtil.Fire_S("SetCannonDirEvent", "Right")
        end
    )
    cannonGui.Figure.LeftBtn.OnDown:Connect(
        function()
            NetUtil.Fire_S("SetCannonDirEvent", "Left")
        end
    )
end

-- 显示小游戏的GUI
function GuiCannon:SetMiniGameGuiEventHandler(_gameId, _selfActive, _ctrlGuiActive)
    if _gameId == 4 then
        cannonGui:SetActive(_selfActive)
        invoke(
            function()
                localPlayer.Local.ControlGui:SetActive(_ctrlGuiActive)
            end,
            0.5
        )
    end
end

-- 力度条变化
function GuiCannon:ForceBarChange(dt)
    if isAdd then
        forceBarFillAmount = forceBarFillAmount + dt
    else
        forceBarFillAmount = forceBarFillAmount - dt
    end
    if forceBarFillAmount > 1 then
        isAdd = false
    elseif forceBarFillAmount < 0 then
        isAdd = true
    end
    cannonGui.Figure.ForceBar.FillAmount = forceBarFillAmount
end

function GuiCannon:Update(dt)
    this:ForceBarChange(dt)
end

return GuiCannon
