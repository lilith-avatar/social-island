--- 赌马Gui模块
--- @module Gui Snail, client-side
--- @copyright Lilith Games, Avatar Team
local GuiSnail, this = ModuleUtil.New('GuiSnail', ClientBase)

local gui
local snailBtn = {}
local snailIndex = 0
local arrowEffect = {}

function GuiSnail:Init()
    --print('[GuiSnail] Init()')
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

function GuiSnail:NodeRef()
    gui = localPlayer.Local.SnailGUI
    for i = 1, 4 do
        snailBtn[i] = gui.SnailPanel['Snail' .. i].SnailBtn
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
                    SoundUtil.Play2DSE(localPlayer.UserId, 101)
                    snailIndex = k
                    NetUtil.Fire_S('SnailBetEvent', localPlayer, snailIndex)
                    gui.SnailPanel:SetActive(false)
                else
                    SoundUtil.Play2DSE(localPlayer.UserId, 6)
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
function GuiSnail:BetSuccessEventHandler(_num)
    this:BetMoney(_num)
end

-- 下注
function GuiSnail:BetMoney(_num)
    NotReplicate(
        function()
            arrowEffect[snailIndex]:SetActive(true)
        end
    )
    SoundUtil.Play2DSE(localPlayer.UserId, 8)
    NetUtil.Fire_C(
        'InsertInfoEvent',
        localPlayer,
        string.format(LanguageUtil.GetText(Config.GuiText.SnailGui_8.Txt), snailIndex),
        3,
        true
    )
    CloudLogUtil.UploadLog('snail', 'bet_client', {snailId = snailIndex, coin_num = _num})
    NetUtil.Fire_C('ChangeMiniGameUIEvent', localPlayer)
end

-- 检查上传失败的下注尝试
function GuiSnail:BetFailEventHandler()
    SoundUtil.Play2DSE(localPlayer.UserId, 6)
    CloudLogUtil.UploadLog('snail', 'bet_fail')
end

-- 获得下注奖励
function GuiSnail:GetBetRewardEventHandler(_num, _rank)
    local reward = 0
    if _rank == 2 then
        reward = 2
    elseif _rank == 1 then
        reward = 3
    end
    NetUtil.Fire_C('UpdateCoinEvent', localPlayer, _num * reward, false, 9)
    if _rank < 3 then
        NetUtil.Fire_C(
            'InsertInfoEvent',
            localPlayer,
            string.kyformat(LanguageUtil.GetText(Config.GuiText.SnailGui_4.Txt), {rank = _rank, coin = _num * reward}),
            3,
            false
        )
        SoundUtil.Play3DSE(localPlayer.Position, 11)
    else
        NetUtil.Fire_C(
            'InsertInfoEvent',
            localPlayer,
            string.format(LanguageUtil.GetText(Config.GuiText.SnailGui_5.Txt), _rank),
            3,
            false
        )
        SoundUtil.Play3DSE(localPlayer.Position, 12)
    end
    CloudLogUtil.UploadLog('snail', 'game_reward', {rank = _rank, coin_num = _num})
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
        SoundUtil.Play2DSE(localPlayer.UserId, 5)
        NetUtil.Fire_C('ChangeMiniGameUIEvent', localPlayer, 8)
        NetUtil.Fire_C('InsertInfoEvent', localPlayer, LanguageUtil.GetText(Config.GuiText.SnailGui_9.Txt), 1, false)
        gui:SetActive(true)
        gui.SnailPanel:SetActive(true)
    end
end

return GuiSnail
