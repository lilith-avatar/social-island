---@module MoleHit
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local MoleHit, this = ModuleUtil.New("MoleHit", ServerBase)

---初始化函数
function MoleHit:Init()
    this:DataInit()
    this:PitListInit()
end

function MoleHit:DataInit()
    this.playerList = {}
    this.pitList = {}
    this.timer = 0
    this.refreshTime = 4 --! Only Test
    this.refreshList = {} --Todo : lua table
end

--绑定坑位
function MoleHit:PitListInit()
    for k,v in pairs(world.MoleHit:GetChildren()) do
        this.pitList[v.Name] = {
            model = v,
            mole = nil
        }
    end
end

function MoleHit:PlayerStartMoleHit(_uid)
    this.playerList[_uid] = {
        inGame = true
    }
end

function MoleHit:PlayerLeaveMoleHit(_uid)
    this.playerList[_uid] = nil
end

---根据玩家人数刷地鼠
function MoleHit:RefreshMole(_playerNum)
end

function MoleHit:PlayerHitEvent(_uid,_hitPit)
    if this.pitList[_hitPit].mole then
        --对象池管理
    end
end

---Update函数
function MoleHit:Update(dt, tt)
    if table.nums(this.playerList) ~= 0 then
        this.timer = this.timer + dt
        if this.timer >= this.refreshTime then
        --刷地鼠
        end
    end
end

return MoleHit
