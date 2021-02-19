--- 人间大炮Gui模块
--- @module Player Cannon, client-side
--- @copyright Lilith Games, Avatar Team
local GuiCannon, this = ModuleUtil.New("GuiCannon", ClientBase)

local cannonGui

local forceBarFillAmount = 0
local isAdd = true

local circle = {}

function GuiCannon:Init()
    print("[GuiCannon] Init()")
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

function GuiCannon:NodeRef()
    cannonGui = localPlayer.Local.CannonGUI
end

function GuiCannon:DataInit()
    for k, v in pairs(localPlayer.Local.Independent.Cannon_Circle:GetChildren()) do
        v.CircleCol.OnCollisionBegin:Connect(
            function(_hitObj)
                if _hitObj == localPlayer then
                    localPlayer.Local.Independent.Cannon_Circle:SetActive(false)
                    NetUtil.Fire_C("UpdateCoinEvent", localPlayer, 50)
                end
            end
        )
        circle[#circle + 1] = v
    end
end

function GuiCannon:EventBind()
    cannonGui.Figure.FireBtn.OnDown:Connect(
        function()
            NetUtil.Fire_S("CannonFireEvent", forceBarFillAmount)
            invoke(
                function()
                    localPlayer.Local.Independent.Cannon_Circle:SetActive(false)
                end,
                5
            )
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

function GuiCannon:InteractCEventHandler(_id)
    if _id == 4 then
        localPlayer.Local.Independent.Cannon_Circle:SetActive(true)
    end
end

return GuiCannon
