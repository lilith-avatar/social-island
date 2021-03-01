---@module ChairMgr
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local ChairMgr, this = ModuleUtil.New("ChairMgr", ServerBase)

local playerChair = {}

---初始化函数
function ChairMgr:Init()
    print("[ChairMgr] Init()")
    this:DataInit()
    this:ChairCreate()
end

function ChairMgr:DataInit()
end

function ChairMgr:ChairCreate()
end

function ChairMgr:PlayerClickSitBtnEventHandler(_uid, _type, _chairId)
end

function ChairMgr:Update(dt)
end

function ChairMgr:PlayerLeaveChairEventHandler(_type, _chairId, _uid)
end

function ChairMgr:NormalChairSpeedUpEventHandler(_chairId)
end

function ChairMgr:QteChairMoveEventHandler(_dir, _speed, _chairId)
end

return ChairMgr
