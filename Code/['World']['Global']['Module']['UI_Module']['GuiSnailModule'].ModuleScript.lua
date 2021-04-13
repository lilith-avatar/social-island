--- 赌马Gui模块
--- @module Gui Snail, client-side
--- @copyright Lilith Games, Avatar Team
local GuiSnail, this = ModuleUtil.New('GuiSnail', ClientBase)

local gui
local snailBtn = {}
local snailIndex = 0
local arrowEffect = {}

function GuiSnail:Init()
    print('[GuiSnail] Init()')
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

function GuiSnail:NodeRef()
    gui = localPlayer.Local.SnailGUI
    for i = 1, 4 do
        snailBtn[i] = gui.SnailPanel['SnailBtn' .. i]
        arrowEffect[i] = world.MiniGames.Game_08_Snail.Snail['Snail' .. i].ArrowEffect
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
                    NetUtil.Fire_C(
                        'SliderPurchaseEvent',
                        localPlayer,
                        8,
                        LanguageUtil.GetText(Config.GuiText.SnailGui_6.Txt)
                    )
                else
                    NetUtil.Fire_C(
                        'InsertInfoEvent',
                        localPlayer,
                        LanguageUtil.GetText(Config.GuiText.SnailGui_7.Txt),
                        3,
                        true
                    )
                    NetUtil.Fire_C('ChangeMiniGameUIEvent', localPlayer)
                end
            end
        )
    end
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
    NotReplicate(
        function()
            arrowEffect[snailIndex]:SetActive(true)
        end
    )
    NetUtil.Fire_S('SnailBetEvent', localPlayer, snailIndex, _num)
    --NetUtil.Fire_C("UpdateCoinEvent", localPlayer, -1 * _num)
    SoundUtil.Play2DSE(localPlayer.UserId, 8)
    NetUtil.Fire_C(
        'InsertInfoEvent',
        localPlayer,
        string.format(LanguageUtil.GetText(Config.GuiText.SnailGui_8.Txt), snailIndex, _num),
        3,
        true
    )
    NetUtil.Fire_C('ChangeMiniGameUIEvent', localPlayer)
end

-- 重置
function GuiSnail:CSnailResetEventHandler()
    NotReplicate(
        function()
            arrowEffect[snailIndex]:SetActive(false)
        end
    )
end

function GuiSnail:InteractCEventHandler(_id)
    if _id == 8 then
        NetUtil.Fire_C('ChangeMiniGameUIEvent', localPlayer, 8)
        NetUtil.Fire_C('InsertInfoEvent', localPlayer, LanguageUtil.GetText(Config.GuiText.SnailGui_9.Txt), 1, false)
        gui:SetActive(true)
        gui.SnailPanel:SetActive(true)
        gui.BetPanel:SetActive(false)
    end
end

return GuiSnail
