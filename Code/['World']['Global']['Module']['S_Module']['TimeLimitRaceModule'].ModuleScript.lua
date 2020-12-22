---计时赛跑服务器管理模块
---@module TimeLimitRace
---@copyright Lilith Games, Avatar Team
---@author Changoo Wu

local TimeLimitRace,this = ModuleUtil.New('TimeLimitRace',ServerBase)
local nowKey = 1
local rankList={}

function TimeLimitRace:Init()
	this:RandomKey()
	this:NodeDef()
end

---节点定义
function TimeLimitRace:NodeDef()
    this.RankTable = world.MiniGames.Game_09_Race.RaceGame.RankList.RankTable
end

---收到游戏开始时间
function TimeLimitRace:RaceGameStartEventHandler(_player)
	this:ResponseRaceKey(_player)
end

---刷新现在挑战的序列
function TimeLimitRace:RandomKey()
	nowKey = math.random(1,#Config.RacePoint)
end

local function Compare2Data(A, B)
    if A.usedTime < B.usedTime then
        return 2
    elseif A.usedTime == B.usedTime then
        return 1
    else
        return -2
    end
end

---按用时整理排行
local function SortRankList(_rankList)
    if #_rankList > 1 then
        for i = 1, #_rankList do
            for j = 1, #_rankList - i do
                local result = Compare2Data(_rankList[j], _rankList[j + 1])
                if result < 0 then
                    local temp1 = table.shallowcopy(_rankList[j])
                    local temp2 = table.shallowcopy(_rankList[j + 1])
					_rankList[j],_rankList[j + 1]=temp2,temp1
                end
            end
        end
        local tempRank = 1
        for i = 1, #_rankList - 1 do
            if _rankList[i].usedTime ~= _rankList[i + 1].usedTime then
                _rankList[i].Rank = tempRank
				tempRank,_rankList[i + 1].Rank=tempRank + 1,tempRank
            else
				_rankList[i].Rank,_rankList[i + 1].Rank= tempRank,tempRank
            end
        end
    
	end
end

---把当前的序列反给玩家
function TimeLimitRace:EnterMiniGameEventHandler(_player, _gameId)
	if _gameId == 9 then
		NetUtil.Fire_C(
				"ClintInitRaceEvent",
				_player,
				nowKey
			)
	end
end

---玩家跑完了游戏
function TimeLimitRace:RaceGameOverEventHandler(_player,_usedTime,_rewardRate)
	if _rewardRate == 1 then
		this:FreshRank(_player,_usedTime)
	end
end


---刷新排行榜
function TimeLimitRace:FreshRank(_player,_usedTime)
	local recordData = {PlayerName = _player.Name, Rank = 1,usedTime = _usedTime}
	for k,v in pairs(rankList) do 
		if recordData.PlayerName == v.PlayerName and recordData.usedTime < v.usedTime then
			table.remove(rankList,k)
			TimeLimitRace:ResortData(recordData)
		end
	end
	
	if TimeLimitRace:CheckPlayerList(recordData.playerName) == nil then
		TimeLimitRace:ResortData(recordData)
	end
end

---检查玩家是不是已经在列表里
function TimeLimitRace:CheckPlayerList(_playerName)
    for k, v in pairs(rankList) do
        if v.playerName == _playerName then
            return k
        end
    end
    return nil
end

---排行榜重排序
function TimeLimitRace:ResortData(_recordData)
	table.insert(rankList, _recordData)
	SortRankList(rankList)
	for k,v in pairs(rankList) do
		for k1,v1 in pairs (this.RankTable:GetChildren()) do
			if v1.Name == tostring(k) then
				v1.txtName.Text = v.PlayerName
				v1.txtRecord.Text = v.usedTime
				v1.txtRank.Text = v.Rank
				v1:SetActive(true)
			end
		end
	end
end



---帧执行逻辑
local totalResetTime = 0
function TimeLimitRace:Update(_dt, _tt)
	totalResetTime = totalResetTime + _dt
	if totalResetTime > (60 * 30) then
		totalResetTime = 0
		this:RandomKey()
		--重置的其他表现
	end
end


return TimeLimitRace