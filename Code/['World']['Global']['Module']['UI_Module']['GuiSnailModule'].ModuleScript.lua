--- 赌马Gui模块
--- @module Gui Snail, client-side
--- @copyright Lilith Games, Avatar Team
local GuiSnail, this = ModuleUtil.New("GuiSnail", ClientBase)

local gui
local snailBtn, betBtn = {}, {}
local snailIndex = 0

function GuiSnail:Init()
    print("[GuiSnail] Init()")
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

function GuiSnail:NodeRef()
    gui = localPlayer.Local.SnailGUI
    for i = 1, 4 do
        snailBtn[i] = gui.SnailPanel["SnailBtn" .. i]
        if gui.BetPanel["BetBtn" .. i] then
            betBtn[i] = gui.BetPanel["BetBtn" .. i]
        end
    end
end

function GuiSnail:DataInit()
end

function GuiSnail:EventBind()
    for k, v in pairs(snailBtn) do
        v.OnDown:Connect(
            function()
                snailIndex = k
                gui.SnailPanel:SetActive(false)
                gui.BetPanel:SetActive(true)
                NetUtil.Fire_C("InsertInfoEvent", localPlayer, "选择投注的金币数量", 1, false)
            end
        )
    end
    betBtn[1].OnDown:Connect(
        function()
            this:BetMoney(50)
        end
    )
    betBtn[2].OnDown:Connect(
        function()
            this:BetMoney(100)
        end
    )
    betBtn[3].OnDown:Connect(
        function()
            this:BetMoney(300)
        end
    )
    gui.BetPanel.LeaveBtn.OnDown:Connect(
        function()
            NetUtil.Fire_C("ChangeMiniGameUIEvent", localPlayer)
        end
    )
end

function GuiSnail:Update(dt)
end

-- 下注
function GuiSnail:BetMoney(_num)
    if Data.Player.coin >= _num then
        NetUtil.Fire_S("SnailBetEvent", localPlayer, snailIndex, _num)
        NetUtil.Fire_C("UpdateCoinEvent", localPlayer, -1 * _num)
        NetUtil.Fire_C("InsertInfoEvent", localPlayer, "你成功给" .. snailIndex .. "号蜗牛投注" .. _num, 3, true)
    else
        NetUtil.Fire_C("InsertInfoEvent", localPlayer, "你没钱啦", 3, true)
    end
    NetUtil.Fire_C("ChangeMiniGameUIEvent", localPlayer)
end

function GuiSnail:InteractCEventHandler(_id)
    if _id == 8 then
        print("GuiSnail:InteractCEventHandler")
        NetUtil.Fire_C("ChangeMiniGameUIEvent", localPlayer, 8)
        NetUtil.Fire_C("InsertInfoEvent", localPlayer, "选择一个颜色的蜗牛", 1, false)
        gui:SetActive(true)
        gui.SnailPanel:SetActive(true)
        gui.BetPanel:SetActive(false)
    end
end

return GuiSnail
