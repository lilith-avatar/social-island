---@module GuiChair
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local GuiChair, this = ModuleUtil.New("GuiChair", ClientBase)

local type = ""
local chairId = 0

---初始化函数
function GuiChair:Init()
    print("[GuiChair] Init()")
    this:NodeDef()
    this:DataInit()
    this:EventBind()
end

function GuiChair:DataInit()
    this.normalState = nil
    this.dirQte = nil
    this.startUpdate = false
    this.timer = 0
    this.buttonKeepTime = 0
end

function GuiChair:EventBind()
    this.boostBtn.OnClick:Connect(function()
        NetUtil.Fire_S('NormalChairSpeedUpEvent',Chair.chair)
    end)
    for k, v in pairs(this.qteBtn) do
        v.OnClick:Connect(
            function()
                this:QteButtonClick(k)
                v:SetActive(false)
            end
        )
    end
end

function GuiChair:NodeDef()
    this.sitBtn = localPlayer.Local.ControlGui.SitBtn
    this.gui = localPlayer.Local.ChairGui
    this.normalGui = this.gui.NormalPnl
    this.boostBtn=this.normalGui.BoostBtn

    this.QteGui = this.gui.QtePnl
    this.qteBtn = {
        Forward = this.QteGui.ForwardBtn,
        Left = this.QteGui.LeftBtn,
        Back = this.QteGui.BackBtn,
        Right = this.QteGui.RightBtn
    }
    this.qteTotalTime = this.QteGui.TimeTxt.NumTxt
end

function GuiChair:ClickSitBtn(_type, _chairId)
    NetUtil.Fire_S("PlayerClickSitBtnEvent", localPlayer.UserId, _type, _chairId)
    this.sitBtn:SetActive(false)
end


function GuiChair:InteractCEventHandler(_id)
    if _id == 10 then
        NetUtil.Fire_S("PlayerClickSitBtnEvent", localPlayer.UserId, type, chairId)
    end
end

function GuiChair:ShowSitBtnEventHandler(_type, _chairId)
    --[[this.sitBtn.OnClick:Clear()
    this.sitBtn.OnClick:Connect(
        function()
            this:ClickSitBtn(_type, _chairId)
        end
    )
    this.sitBtn:SetActive(true)]]
    type = _type
    chairId = _chairId
end

function GuiChair:HideSitBtnEventHandler()
    this.sitBtn:SetActive(false)
end

function GuiChair:EnterNormal()
    this.startUpdate = false
    this.gui:SetActive(true)
    this.QteGui:SetActive(false)
    this.normalGui:SetActive(true)
    this.boostBtn:SetActive(false)
    NetUtil.Fire_C("ChangeMiniGameUIEvent", localPlayer, 10)
end

function GuiChair:EnterQte()
    this.gui:SetActive(true)
    this.QteGui:SetActive(true)
    NetUtil.Fire_C("ChangeMiniGameUIEvent", localPlayer, 10)
end

function GuiChair:NormalShakeDirEventHandler(_upOrDown)
    if _upOrDown == "up" then
        this.normalBtn.down:SetActive(true)
        this.normalBtn.up:SetActive(false)
    else
        this.normalBtn.down:SetActive(false)
        this.normalBtn.up:SetActive(true)
    end
end

function GuiChair:NormalBack()
    this.normalGui:SetActive(false)
    this.QteGui:SetActive(false)
    this.gui:SetActive(false)
    this.qteTotalTime.Text = 0
    Chair:PlayerLeaveSit()
    localPlayer:Jump()
    NetUtil.Fire_S("PlayerLeaveChairEvent", Chair.chairType, Chair.chair, localPlayer.UserId)
    NetUtil.Fire_C("ChangeMiniGameUIEvent", localPlayer)
end

function GuiChair:GetQteForward(_dir, _speed)
    for _, v in pairs(this.qteBtn) do
        v:SetActive(false)
    end
    if not _dir then
        return
    end
    this.qteBtn[_dir]:SetActive(true)
    this.dirQte = _dir
    this.startUpdate = true
    NetUtil.Fire_S("QteChairMoveEvent", _dir, _speed, Chair.chair)
end

function GuiChair:QteButtonClick(_dir)
    --判断是否正确按钮
    if _dir ~= this.dirQte then
        --把玩家甩出去
        this:NormalBack()
    end

    this.startUpdate = false
    this.timer = 0
end

function GuiChair:ShowQteButton(_keepTime)
    this.buttonKeepTime = _keepTime
end

function GuiChair:ChangeTotalTime(_total)
    this.qteTotalTime.Text = tostring(math.floor(_total))
end

function GuiChair:Update(_dt)
    if this.startUpdate and this.buttonKeepTime ~= 0 then
        this.timer = this.timer + _dt
        if this.timer >= this.buttonKeepTime then
            this.GetQteForward()
            this:NormalBack() --! Only Test
            this.startUpdate = false
            this.timer = 0
        end
    end
end

return GuiChair
