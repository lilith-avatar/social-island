--- 服务器端玩家数据
--- @module Players Data Manager
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local DataMgr, this = ModuleUtil.New('DataMgr', ServerBase)

--! 初始化

function DataMgr:Init()
    print('[DataMgr] Init()')
end

--! Event handlers

-- 玩家受伤事件
function DataMgr:SPlayerHitEventHandler(_attackPlayer, _hitPlayer, _data)
    NetUtil.Fire_C('CPlayerHitEvent', _hitPlayer, _data)
end

return DataMgr
