---@module ChairUIMgr
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local ChairUIMgr, this = ModuleUtil.New("ChairUIMgr", ClientBase)

---初始化函数
function ChairUIMgr:Init()
    print("ChairUIMgr: Init")
    this:NodeDef()
    this:DataInit()
    this:EventBind()
end

function ChairUIMgr:DataInit()
    this.normalState = nil
    this.dirQte = nil
    this.startUpdate = false
    this.timer = 0
    this.buttonKeepTime = 0
end

function ChairUIMgr:EventBind()
    for k, v in pairs(this.normalBtn) do
        v.OnClick:Connect(
            function()
                this:NormalShake(k)
            end
        )
    end
    for k, v in pairs(this.qteBtn) do
        v.OnClick:Connect(
            function()
                this:QteButtonClick(k)
                v:SetActive(false)
            end
        )
    end
    this.normalBackBtn.OnClick:Connect(
        function()
            this:NormalBack()
        end
    )
end

function ChairUIMgr:NodeDef()
    this.gui = localPlayer.Local.ChairGui
    this.normalGui = this.gui.NormalPnl
    this.normalBtn = {
        up = this.normalGui.UpBtn,
        down = this.normalGui.DownBtn
    }
    this.normalBackBtn = this.normalGui.BackBtn

    this.QteGui = this.gui.QtePnl
    this.qteBtn = {
        forward = this.QteGui.ForwardBtn,
        left = this.QteGui.LeftBtn,
        back = this.QteGui.BackBtn,
        right = this.QteGui.RightBtn
    }
end

function ChairUIMgr:EnterNormal()
    this.normalGui:SetActive(true)
    this.normalBtn.up:SetActive(true)
    this.normalBtn.down:SetActive(true)
end

function ChairUIMgr:EnterQte()
    this.QteGui:SetActive(true)
end

function ChairUIMgr:NormalShake(_upOrDown)
    NetUtil.Fire_S("NormalShakeEvent", Chair.chair, _upOrDown)
    if _upOrDown == "up" then
        this.normalBtn.down:SetActive(true)
        this.normalBtn.up:SetActive(false)
    else
        this.normalBtn.down:SetActive(false)
        this.normalBtn.up:SetActive(true)
    end
end

function ChairUIMgr:NormalBack()
    this.normalGui:SetActive(false)
    Chair:PlayerLeaveSit()
    localPlayer:Jump()
    NetUtil.Fire_S("PlayerLeaveChairEvent", Chair.chairType,Chair.chair, localPlayer.UserId)
end

function ChairUIMgr:GetQteForward(_dir, _speed)
    for _, v in pairs(this.qteBtn) do
        v:SetActive(false)
    end
    if not _dir then
        return
    end
    this.qteBtn[_dir]:SetActive(true)
    this.dirQte = _dir
    this.startUpdate = true
    NetUtil.Fire_S("QteChairMoveEvent", _dir, _speed)
end

function ChairUIMgr:QteButtonClick(_dir)
    --判断是否正确按钮
    if _dir ~= this.dirQte then
        --把玩家甩出去
        this:NormalBack()
    end
    
    this.startUpdate = false
    this.timer = 0
end

function ChairUIMgr:ShowQteButton(_keepTime)
    this.buttonKeepTime = _keepTime
end

function ChairUIMgr:Update(_dt)
    if this.startUpdate and this.buttonKeepTime ~= 0 then
        this.timer = this.timer + _dt
        if this.timer >= this.buttonKeepTime then
            --print('Back!!!!!!',this.buttonKeepTime)
            this.GetQteForward()
            this:NormalBack() --! Only Test
            this.startUpdate = false
            this.timer = 0
        end
    end
end

return ChairUIMgr
