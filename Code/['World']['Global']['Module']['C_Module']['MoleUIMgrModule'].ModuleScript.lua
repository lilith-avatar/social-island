---@module MoleUIMgr
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local MoleUIMgr, this = ModuleUtil.New("MoleUIMgr", ClientBase)

---初始化函数
function MoleUIMgr:Init()
    this:NodeDef()
    this:DataInit()
    this:EventBind()
end

---节点定义
function MoleUIMgr:NodeDef()
    this.gui = localPlayer.Local.MoleHitGui
    this.startButton = this.gui.StartBtn
    this.hitButton = this.gui.HitBtn
end

---数据初始化
function MoleUIMgr:DataInit()
end

---事件绑定
function MoleUIMgr:EventBind()
    this.startButton.OnClick:Connect(
        function()
            this:StartGame()
        end
    )
    this.hitButton.OnClick:Connect(
        function()
            this:Hit()
        end
    )
end

---蓄力槽增加
function MoleUIMgr:BoostAdd(_num)
end

function MoleUIMgr:Hit()
    NetUtil.Fire_S("PlayerHitEvent", localPlayer.UserId, MoleGame.rangeList)
end

function MoleUIMgr:AddScoreAndBoostEventHandler(_type, _reward, _boostReward)
    print("类型：" .. _type .. " 奖励：" .. _reward .. " 蓄力槽积攒：" .. _boostReward)
end

function MoleUIMgr:StartGame()
    NetUtil.Fire_S("PlayerStartMoleHitEvent", localPlayer.UserId)
end

---强化过程表现
function MoleUIMgr:Boosting()
end

---Update函数
function MoleUIMgr:Update()
end

return MoleUIMgr
