---@module ItemPool
---@copyright Lilith Games, Avatar Team
---@author Dead Ratman
local ItemPool, this = ModuleUtil.New("ItemPool", ServerBase)

local itemObjList = {}

---初始化函数
function ItemPool:Init()
    print("ItemPool:Init")
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--节点引用
function ItemPool:NodeRef()
end

--数据变量声明
function ItemPool:DataInit()
    invoke(
        function()
            this:CreateItemObj(1001, Vector3(-71.841, -8.1877, -21.5269))
            this:CreateItemObj(1002, Vector3(-75.3935, -9.2111, -18.2585))
            this:CreateItemObj(1002, Vector3(-99.9183, -8.804, -10.1632))
            this:CreateItemObj(1002, Vector3(-99.9183, -11.6391, 15.0819))
            this:CreateItemObj(1002, Vector3(-53.2886, -13.085, 24.5262))
            this:CreateItemObj(1002, Vector3(-62.3708, 0.3178, 52.4812))
            this:CreateItemObj(1003, Vector3(-151.711, -0.0495, 38.9364))
            this:CreateItemObj(1005, Vector3(-78.0894, -9.0665, -38.1849))
            this:CreateItemObj(1004, Vector3(-62.8771, -9.8104, -55.4324))
            this:CreateItemObj(1006, Vector3(-61.3199, -9.8104, -55.4324))
            this:CreateItemObj(1007, Vector3(-59.1549, -9.8104, -55.4324))
            this:CreateItemObj(1012, Vector3(-59.1549, -9.8104, -55.4324))
            this:CreateItemObj(1011, Vector3(-54.2712, -9.6638, -37.952))
            this:CreateItemObj(1013, Vector3(-52.8881, -9.6638, -37.952))
            this:CreateItemObj(1008, Vector3(27.0442, -12.0437, 110.723))
			this:CreateItemObj(1014, Vector3(12.5705, -12.0437, 128.175))
			this:CreateItemObj(1015, Vector3(26.4302, -12.0437, 128.175))
			this:CreateItemObj(1023, Vector3(-5.3712, -11.4378, 41.0612))
			this:CreateItemObj(1024, Vector3(-23.1931, -22.3361, 41.0612))
			this:CreateItemObj(1025, Vector3(-50.1465, -9.4653, -36.5908))
			this:CreateItemObj(1026, Vector3(-36.6274, -11.2975, -31.112))
			this:CreateItemObj(1027, Vector3(108.566, -9.6571, -1.2775))
			this:CreateItemObj(1028, Vector3(88.985, -9.6571, 11.5208))
			this:CreateItemObj(3002, Vector3(27.0442, -12.0437, 110.723))
			this:CreateItemObj(3003, Vector3(27.0442, -12.0437, 110.723))
			this:CreateItemObj(3004, Vector3(6.0932, -11.1887, 36.2908))
			this:CreateItemObj(1010, Vector3(-23.0199, 18.127, 110.965))
			this:CreateItemObj(1019, Vector3(-71.6044, -8.6186, -20.2272))
			this:CreateItemObj(1020, Vector3(-72.3977, -8.0854, -21.6197))
			this:CreateItemObj(1017, Vector3(-158.627, -3.8463, 102.664))
			this:CreateItemObj(1017, Vector3(-158.627, -3.8463, 102.664))
			this:CreateItemObj(1018, Vector3(-158.045, -3.8463, 104.342))
			this:CreateItemObj(1021, Vector3(-164.162, -3.8463, 110.194))
			this:CreateItemObj(1022, Vector3(-158.235, -3.8463, 113.369))
			this:CreateItemObj(2001, Vector3(-160.289, -1.3096, 22.5773))
			this:CreateItemObj(2002, Vector3(-164.162, -3.8463, 110.194))
			this:CreateItemObj(2003, Vector3(-149.891, -13.0704, 69.8315))
			this:CreateItemObj(5008, Vector3(-55.4177, 11.2112, 91.7479))
			this:CreateItemObj(5016, Vector3(-82.0614, -13.1499, 37.32))
			this:CreateItemObj(5018, Vector3(-73.7436, -8.5018, -8.0165))
			this:CreateItemObj(5019, Vector3(-33.2845, -8.5018, 30.6994))
			this:CreateItemObj(6004, Vector3(-39.0523, -11.8468, 0.0629))
			this:CreateItemObj(6005, Vector3(-27.5977, -13.3378, 1.7094))
			this:CreateItemObj(6006, Vector3(-99.3554, -11.6974, 19.1159))
			this:CreateItemObj(6007, Vector3(-99.3554, -4.0701, 78.7384))
			this:CreateItemObj(6008, Vector3(-88.829, -0.0681, 78.7384))
			this:CreateItemObj(6010, Vector3(-52.7532, 11.9923, 100.986))
			this:CreateItemObj(6009, Vector3(-13.6917, -11.2539, -36.537))
			this:CreateItemObj(6011, Vector3(2.8772, -8.6419, -41.5882))
			this:CreateItemObj(6012, Vector3(-96.4499, -8.6419, -6.6765))
			this:CreateItemObj(6013, Vector3(-88.1916, -11.0457, 14.821))
			this:CreateItemObj(6014, Vector3(-40.5341, -11.3205, -29.9711))
			this:CreateItemObj(6016, Vector3(40.4612, -11.3205, 26.5297))
			this:CreateItemObj(6017, Vector3(-42.4893, -10.6419, 64.3832))
			this:CreateItemObj(6018, Vector3(-54.4621, -15.8948, 37.7329))
			this:CreateItemObj(6019, Vector3(-60.4786, -13.2829, 41.5334))
			this:CreateItemObj(6020, Vector3(-54.4646, -11.687, 11.2603))
			this:CreateItemObj(6021, Vector3(-47.5253, -11.687, 20.4728))
			
			

			
        end,
        0.5
    )
end

--节点事件绑定
function ItemPool:EventBind()
end

--在地图上生成一个道具物体
function ItemPool:CreateItemObj(_id, _pos)
    local item =
        world:CreateInstance("Item", "Item" .. _id .. "_" .. #itemObjList + 1, world.Item, _pos, EulerDegree(0, 0, 0))
    item.ID.Value = _id
    item.col.OnCollisionBegin:Connect(
        function(_hitObject)
            if _hitObject.ClassName == "PlayerInstance" then
                NetUtil.Fire_C("OpenDynamicEvent", _hitObject, "Pick", item)
            end
        end
    )
    itemObjList[#itemObjList + 1] = item
end

function ItemPool:Update(dt)
end

return ItemPool
