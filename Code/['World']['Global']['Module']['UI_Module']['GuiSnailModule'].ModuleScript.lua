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
                if Data.Player.coin >= 1 then
                    snailIndex = k
                    gui.SnailPanel:SetActive(false)
                    NetUtil.Fire_C("SliderPurchaseEvent", localPlayer, 8, "请选择投注数量")
                else
                    NetUtil.Fire_C("InsertInfoEvent", localPlayer, "你没钱啦", 3, true)
                    NetUtil.Fire_C("ChangeMiniGameUIEvent", localPlayer)
                end
            end
        )
    end
    gui.BetPanel.LeaveBtn.OnDown:Connect(
        function()
            NetUtil.Fire_C("ChangeMiniGameUIEvent", localPlayer)
        end
    )
end

function GuiSnail:Update(dt)
end

--确认支付事件
function GuiSnail:PurchaseCEventHandler(_purchaseCoin, _interactID)
    if _interactID == 8 then
        this:BetMoney(_purchaseCoin)
    end
end

-- 下注
function GuiSnail:BetMoney(_num)
    NetUtil.Fire_S("SnailBetEvent", localPlayer, snailIndex, _num)
    --NetUtil.Fire_C("UpdateCoinEvent", localPlayer, -1 * _num)
    --NetUtil.Fire_C("PlayEffectEvent", localPlayer, 8)
    NetUtil.Fire_C("InsertInfoEvent", localPlayer, "你成功给" .. snailIndex .. "号蜗牛投注" .. _num, 3, true)
    NetUtil.Fire_C("ChangeMiniGameUIEvent", localPlayer)
end

function GuiSnail:InteractCEventHandler(_id)
    if _id == 8 then
        NetUtil.Fire_C("ChangeMiniGameUIEvent", localPlayer, 8)
        NetUtil.Fire_C("InsertInfoEvent", localPlayer, "选择一个颜色的蜗牛", 1, false)
        gui:SetActive(true)
        gui.SnailPanel:SetActive(true)
        gui.BetPanel:SetActive(false)
    end
end

return GuiSnail
