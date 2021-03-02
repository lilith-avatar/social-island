---@module ChairMgr
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local ChairMgr, this = ModuleUtil.New("ChairMgr", ServerBase)

---初始化函数
function ChairMgr:Init()
    print("[ChairMgr] Init()")
    this:DataInit()
    this:ChairCreate()
end

function ChairMgr:DataInit()
    this.chairList = {}
end

function ChairMgr:ChairCreate()
    for k,v in pairs(Config.ChairInfo) do
        this.chairList[k] = ChairClass:new(v.Archetype, k, world.MiniGames.Game_10_Chair.JetChair, v.Position, v.Rotation)
    end
end

function ChairMgr:PlayerSitEventHandler(_player,_chairId)
    this.chairList[_chairId]:Sit(_player)
end

function ChairMgr:Update(dt)
    for k,v in pairs(this.chairList) do
        v:Update(dt)
    end
end

return ChairMgr
