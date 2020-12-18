---@module ChairUIMgr
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local ChairUIMgr,this = ModuleUtil.New('ChairUIMgr',ClientBase)

---初始化函数
function ChairUIMgr:Init()
    print('ChairUIMgr: Init')
    this:NodeDef()
    this:DataInit()
    this:EventBind()
end

function ChairUIMgr:DataInit()
    this.normalState = nil
end

function ChairUIMgr:EventBind()
    for k,v in pairs(this.normalBtn) do
        v.OnClick:Connect(function()
            this:NormalShake(k)
        end)
    end
    this.normalBackBtn.OnClick:Connect(function()
        this:NormalBack()
    end)
end

function ChairUIMgr:NodeDef()
    this.gui = localPlayer.Local.ChairGui
    this.normalGui = this.gui.NormalPnl
    this.normalBtn = {
        up = this.normalGui.UpBtn,
        down = this.normalGui.DownBtn
    }
    this.normalBackBtn = this.normalGui.BackBtn
end

function ChairUIMgr:EnterNormal()
    this.normalGui:SetActive(true)
    this.normalBtn.up:SetActive(true)
    this.normalBtn.down:SetActive(true)
end

function ChairUIMgr:NormalShake(_upOrDown)
    NetUtil.Fire_S('NormalShakeEvent',Chair.chair,_upOrDown)
    if _upOrDown == 'up' then
        this.normalBtn.down:SetActive(true)
        this.normalBtn.up:SetActive(false)
    else
        this.normalBtn.down:SetActive(false)
        this.normalBtn.up:SetActive(true)
    end
end

function ChairUIMgr:NormalBack()
    this.normalGui:SetActive(false)
    NetUtil.Fire_S('PlayerLeaveChairEvent',Chair.chair,localPlayer.UserId)
end

return ChairUIMgr