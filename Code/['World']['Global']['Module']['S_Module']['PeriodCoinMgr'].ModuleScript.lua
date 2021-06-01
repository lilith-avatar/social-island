--- 周期金币刷新模块
--- @module PeriodCoinMgr Module
--- @copyright Lilith Games, Avatar Team
--- @author Changoo Wu
local PeriodCoinMgr, this = ModuleUtil.New("PeriodCoinMgr", ServerBase)
local Config = Config
function PeriodCoinMgr:Init()
	----print("[Period] Init()")
	this:NodeRef()
	this:DataInit()
	this:EventBind()
end
	
--- 节点引用
function PeriodCoinMgr:NodeRef()
	
end

--- 数据变量初始化
function PeriodCoinMgr:DataInit()
	this.mashroomHighValue = {}
	this.mashroomMidValue = {}
	this.mashroomLowValue = {}
	--this.lotusLowValue = {}
	--this.lotusMidValue = {}
	--this.lotusHighValue = {}
	this.cloud ={}
	this.sceneCoin = {}
	this.lutus = {}
	this.mashroomHighValueNum = Config.PeriodCoin[3][1].Num
	this.mashroomMidValueNum = Config.PeriodCoin[2][1].Num
	this.mashroomLowValueNum = Config.PeriodCoin[1][1].Num
	this.cloudNum = Config.PeriodCoin[4][1].Num
	this.sceneCoinNum = Config.PeriodCoin[5][1].Num
	this.lutusNum = Config.PeriodCoin[6][1].Num
	--this.lotusLowValueNum = 0
	--this.lotusMidValueNum = 0 
	--this.lotusHighValueNum = 0 
	
	this:InitCreat()
	this.tt = 0
end

--- 节点事件绑定
function PeriodCoinMgr:EventBind()
	
end

--- 刷新检测
function PeriodCoinMgr:Update(dt)
	this.tt = this.tt + dt
	if this.tt > 1.5 then
		this:CheckCoin(this.mashroomHighValue,3,Config.PeriodCoin[3].CoinType,2)
		this:CheckCoin(this.mashroomMidValue,2,Config.PeriodCoin[2].CoinType,2)
		this:CheckCoin(this.mashroomLowValue,1,Config.PeriodCoin[1].CoinType,2)
		this:CheckCoin(this.cloud,4,Config.PeriodCoin[4].CoinType,4)
		this:CheckCoin(this.sceneCoin,5,Config.PeriodCoin[5].CoinType,1)
		this:CheckCoin(this.lutus,6,Config.PeriodCoin[6].CoinType,3)
		this.tt=0
	end
	--
	--this:CheckCoin(this.lotusMidValue,5,'N10')
	--this:CheckCoin(this.lotusHighValue,6,'N100')


end

--- 状态检查
local PosId
function PeriodCoinMgr:CheckCoin(_table,_fId,_CoinType,_origin)
	for k,v in pairs(_table) do
		if not v[2].ActiveSelf then
			this:RandomPos(_table,_fId)
			table.remove(_table,k)
			this:FreshCoin(_table,_fId,PosId,_origin)
		end
	end
end

--- 随机一个未被占用的点
function PeriodCoinMgr:RandomPos(_table,_fId)
	PosId = math.random(1,#Config.PeriodCoin[_fId])
	for k,v in pairs(_table) do	
		if v and v[1] == PosId then
			this:RandomPos(_table,_fId)
		end
	end
end


--- 刷新金币
local CoinInfo
local Coin
local RadIndex
function PeriodCoinMgr:FreshCoin(_table,_fId,_posId,_origin)
	if Config.PeriodCoin[_fId][_posId].CoinType ~= "Random" then
		Coin = CoinMgr:SpawnCoin(Config.PeriodCoin[_fId][_posId].CoinType,Config.PeriodCoin[_fId][_posId].Pos,nil,_origin)
		CoinInfo = {_posId,Coin }
		table.insert(_table,CoinInfo)
	else
		RadIndex = math.random(0,10)
		if RadIndex > 9.5 then
			Coin = CoinMgr:SpawnCoin("N1000",Config.PeriodCoin[_fId][_posId].Pos,nil, _origin)
		elseif RadIndex > 8 then
			Coin = CoinMgr:SpawnCoin("N100",Config.PeriodCoin[_fId][_posId].Pos,nil, _origin)
		elseif RadIndex > 5 then
			Coin = CoinMgr:SpawnCoin("N10",Config.PeriodCoin[_fId][_posId].Pos,nil, _origin)
		else
			Coin = CoinMgr:SpawnCoin("N1",Config.PeriodCoin[_fId][_posId].Pos,nil, _origin)
		end
		CoinInfo = {_posId,Coin }
		table.insert(_table,CoinInfo)
	end
end

--- 首次创建
function PeriodCoinMgr:InitCreat()
	--- 蘑菇金币区
	for i=0,this.mashroomHighValueNum,1 do
		this:RandomPos(this.mashroomHighValue,3)
		this:FreshCoin(this.mashroomHighValue,3,PosId,2)
	end
	for i=0,this.mashroomMidValueNum,1 do
		this:RandomPos(this.mashroomMidValue,2)
		this:FreshCoin(this.mashroomMidValue,2,PosId,2)
	end
	for i=0,this.mashroomLowValueNum,1 do
		this:RandomPos(this.mashroomLowValue,1)
		this:FreshCoin(this.mashroomLowValue,1,PosId,2)
	end
	--- 云上金币区
	for i=0,this.cloudNum,1 do
		this:RandomPos(this.cloud,4)
		this:FreshCoin(this.cloud,4,PosId,4)
	end
	--- 场景彩蛋金币
	for i=0,this.sceneCoinNum,1 do
		this:RandomPos(this.sceneCoin,5)
		this:FreshCoin(this.sceneCoin,5,PosId,1)
	end
	--- 湖上荷叶金币
	for i=0,this.lutusNum,1 do
		this:RandomPos(this.lutus,6)
		this:FreshCoin(this.lutus,6,PosId,3)
	end
	--[[ 湖上荷叶金币区
	if #this.lotusHighValue < this.lotusLowValueNum then
		PeriodCoinMgr:FreshHighValue(this.mashroomHighValue)
	end
	if #this.lotusMidValue < this.lotusMidValueNum then
		PeriodCoinMgr:FreshMidValue(this.mashroomMidValue)
	end
	if #this.lotusLowValue < this.lotusHighValueNum then
		PeriodCoinMgr:FreshLowValue(this.mashroomLowValue)
	end]]
	
end

return PeriodCoinMgr