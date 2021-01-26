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
            this:CreateItemObj(5022, Vector3(-39.4065, -11.6012, -0.4372))
            this:CreateItemObj(5023, Vector3(-20.9087, -14.2145, -1.6095))
            this:CreateItemObj(5022, Vector3(-103.577, -9.1927, 2.7578))
            this:CreateItemObj(5022, Vector3(-86.3498, -9.1927, -11.2409))
            this:CreateItemObj(5017, Vector3(-84.8463, -9.4947, 0.2409))
            this:CreateItemObj(5017, Vector3(-60.9962, -13.4307, 27.1079))
            this:CreateItemObj(5024, Vector3(-83.8917, -5.5198, -15.8766))
            this:CreateItemObj(5018, Vector3(31.6175, -12.8839, 127.295))
            this:CreateItemObj(5025, Vector3(106.888, -10.4713, 0.1005))
            this:CreateItemObj(5026, Vector3(-150.064, -13.1113, 69.8964))
            this:CreateItemObj(5027, Vector3(-158.677, -1.1168, 53.8572))
            this:CreateItemObj(5027, Vector3(-158.677, -3.0511, 116.602))
            this:CreateItemObj(5026, Vector3(-83.8917, -5.5198, -15.8766))
            this:CreateItemObj(5028, Vector3(40.8512, -11.2896, 28.5415))
            this:CreateItemObj(5019, Vector3(-62.5168, -6.5986, -59.9787))
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
