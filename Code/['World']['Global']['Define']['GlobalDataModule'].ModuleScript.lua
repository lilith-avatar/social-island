--- 全局变量的定义,全部定义在GlobalData这张表下面,用于全局可修改的参数
--- @module GlobalData Defines
--- @copyright Lilith Games, Avatar Team
local GlobalData = {}

---元素吸附角度
GlobalData.AdsorbAngle = 60
---服务端广播同步频率
GlobalData.SyncFrequency_S = 10
---客户端每隔几个渲染帧上行一次数据
GlobalData.SyncFrequency_C = 4
---选中元素抬高高度
GlobalData.SelectHigh = 0.2
---一个游戏中允许创建的房间数量
GlobalData.MaxRoomNum = 10
---一个房间中允许出现的最大的对象数量
GlobalData.MaxUnitNum = 200

return GlobalData
