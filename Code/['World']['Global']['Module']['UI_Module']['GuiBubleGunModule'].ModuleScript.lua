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
    this.timer = 0
    this.startUpdate = false
end

function GuiBubleGun:NodeDef()
    this.gui = localPlayer.Local.SpecialTopUI.BubleGunGui
    this.AttackBtn = this.gui.AttackBtn
    this.exitBtn = this.gui.LeaveBtn
end

function GuiBubleGun:ShowGui()
    this.gui:SetActive(true)
    this.AttackBtn:SetActive(true)
end

function GuiBubleGun:HideBtn()
    this.AttackBtn:SetActive(false)
end

function GuiBubleGun:HideGui()
    this.gui:SetActive(false)
end

function GuiBubleGun:EventBind()
    this.AttackBtn.OnClick:Connect(function()
        this.AttackBtn.Clickable = false
        this.startUpdate = true
        NetUtil.Fire_S('CreateBubleEvent',localPlayer)
    end)
    this.exitBtn.OnClick:Connect(function()
        NetUtil.Fire_S("LeaveInteractSEvent", localPlayer, 25)
        NetUtil.Fire_C("LeaveInteractCEvent", localPlayer, 25)
    end)
end

function GuiBubleGun:InteractCEventHandler(_gameId)
    if _gameId == 25 then
        NetUtil.Fire_C("ChangeMiniGameUIEvent", localPlayer, 25)
        --NetUtil.Fire_C("FsmTriggerEvent", localPlayer, "BubleGunIdle")
        this:ShowGui()
    end
end

function GuiBubleGun:LeaveInteractCEventHandler(_gameId)
    if _gameId == 25 then
        NetUtil.Fire_C("ChangeMiniGameUIEvent", localPlayer)
        this:HideGui()
    end
end

---Update函数
function GuiBubleGun:Update(dt)
    if this.startUpdate then
        this.timer = this.timer + dt
        if this.timer >= 1 then
            this.startUpdate = false
            this.AttackBtn.Clickable = true
            this.timer = 0
        end
    end
end

return GuiBubleGun