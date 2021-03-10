--- 周期金币刷新模块
--- @module PeriodCoinMgr Module
--- @copyright Lilith Games, Avatar Team
--- @author Changoo Wu
local PeriodCoinMgr, this = ModuleUtil.New("PeriodCoinMgr", ServerBase)
local Config = Config
function PeriodCoinMgr:Init()
	print("[Period] Init()")
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
	this.lotusLowValue = {}
	this.lotusMidValue = {}
	this.lotusHighValue = {}
	this.mashroomHighValueNum = Config.PeriodCoin[3][1].Num
	this.mashroomMidValueNum = Config.PeriodCoin[2][1].Num
	this.mashroomLowValueNum = Config.PeriodCoin[1][1].Num

	this.lotusLowValueNum = 0
	this.lotusMidValueNum = 0 
	this.lotusHighValueNum = 0 
	
	this:InitCreat()
end

--- 节点事件绑定
function PeriodCoinMgr:EventBind()
	
end

--- 刷新检测
function PeriodCoinMgr:Update(dt)
	this:CheckCoin(this.mashroomHighValue,3,Config.PeriodCoin[3].CoinType)
	this:CheckCoin(this.mashroomMidValue,2,Config.PeriodCoin[2].CoinType)
	this:CheckCoin(this.mashroomLowValue,1,Config.PeriodCoin[1].CoinType)
	
	--this:CheckCoin(this.lotusLowValue,4,'N1')
	--this:CheckCoin(this.lotusMidValue,5,'N10')
	--this:CheckCoin(this.lotusHighValue,6,'N100')


end

--- 状态检查
function PeriodCoinMgr:CheckCoin(_table,_fId,_CoinType)
	for k,v in pairs(_table) do
		if not v[2].ActiveSelf then
			local PosId = this:RandomPos(_table,_fId)
			print(PosId)
			table.remove(_table,k)
			this:FreshCoin(_table,_fId,PosId)
		end
	end
end

--- 随机一个未被占用的点
function PeriodCoinMgr:RandomPos(_table,_fId)
	local PosId = math.random(1,#Config.PeriodCoin[_fId])
	for k,v in pairs(_table) do
		if v and v[1] == PosId then
			this:RandomPos(_table,_fId)
		end
	end
	return PosId
end


--- 刷新金币
local CoinInfo
local Coin
function PeriodCoinMgr:FreshCoin(_table,_fId,_posId)
	Coin = CoinMgr:SpawnCoin(Config.PeriodCoin[_fId][_posId].CoinType,Config.PeriodCoin[_fId][_posId].Pos)
	CoinInfo = {_posId,Coin }
	table.insert(_table,CoinInfo)
	printTable(_table)
end

--- 首次创建
function PeriodCoinMgr:InitCreat()
	--- 蘑菇金币区
	for i=0,this.mashroomHighValueNum,1 do
		local PosId = this:RandomPos(this.mashroomHighValue,3)
		this:FreshCoin(this.mashroomHighValue,3,PosId)
	end
	for i=0,this.mashroomMidValueNum,1 do
		local PosId = this:RandomPos(this.mashroomMidValue,2)
		this:FreshCoin(this.mashroomMidValue,2,PosId)
	end
	for i=0,this.mashroomLowValueNum,1 do
		local PosId = this:RandomPos(this.mashroomLowValue,1)
		this:FreshCoin(this.mashroomLowValue,1,PosId)
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