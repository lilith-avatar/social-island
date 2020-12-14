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
    this.refreshList = Config.MoleGlobalConfig.PlayerNumEffect
end

--绑定坑位
function MoleHit:PitListInit()
    for k,v in pairs(world.MoleHit:GetChildren()) do
        local data = {
            model = v,
            mole = nil
        }
        table.insert(this.pitList,data)
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
    --! only test
    local tmpTable = table.shallowcopy(this.pitList)
    for i=1,3 do
    end
end

local player
function MoleHit:PlayerHitEvent(_uid,_hitPit)
    if this.pitList[_hitPit].mole then
        player = world:GetPlayerByUserId(_uid)
        --对象池管理

        NetUtil.Fire_C('',player)
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
