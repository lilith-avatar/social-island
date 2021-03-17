---@module GuiBubleGun
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local GuiBubleGun,this = ModuleUtil.New('GuiBubleGun',ClientBase)

---初始化函数
function GuiBubleGun:Init()
    this:NodeDef()
    this:DataInit()
    this:EventBind()
end

function GuiBubleGun:DataInit()
end

function GuiBubleGun:NodeDef()
    this.gui = localPlayer.Local.BubleGunGui
    this.AttackBtn = this.gui.AttackBtn
end

function GuiBubleGun:ShowGui()
    this.gui:SetActive(true)
    this.AttackBtn:SetActive(true)
end

function GuiBubleGun:HideBtn()
    this.AttackBtn:SetActive(false)
end

function GuiBubleGun:EventBind()
    this.AttackBtn.OnClick:Connect(function()
        print('发射')
    end)
end

function GuiBubleGun:InteractCEventHandler(_gameId)
    if _gameId == 24 then
        NetUtil.Fire_C("ChangeMiniGameUIEvent", localPlayer, 24)
    end
end

function GuiBubleGun:LeaveInteractCEventHandler(_gameId)
    if _gameId == 24 then
        NetUtil.Fire_C("ChangeMiniGameUIEvent", localPlayer)
    end
end

---Update函数
function GuiBubleGun:Update()
end

return GuiBubleGun