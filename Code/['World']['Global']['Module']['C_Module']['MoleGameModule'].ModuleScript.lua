---@module MoleGame
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local MoleGame, this = ModuleUtil.New('MoleGame', ClientBase)

---初始化函数
function MoleGame:Init()
    print('[MoleGame] Init()')
    --this:GameStart()
end

---数据初始化
function MoleGame:DataInit()
end

---节点绑定
function MoleGame:NodeDef()
end

---事件绑定
function MoleGame:EventBindForStart()
end

---游戏结束，重置数据
function MoleGame:GameOver()
end

function MoleGame:GetScoreBonus()
end

---强化效果结算
function MoleGame:BoostEffect()
end

return MoleGame
