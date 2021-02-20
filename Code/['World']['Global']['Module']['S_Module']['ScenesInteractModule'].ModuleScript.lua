--- 场景交互模块
--- @module ScenesInteract Module
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local ScenesInteract, this = ModuleUtil.New("ScenesInteract", ServerBase)

--- 变量声明
--交互物体
local interactOBJ = {}

--正在交互的ID
local curInteractID = {}

--- 初始化
function ScenesInteract:Init()
    print("[ScenesInteract] Init()")
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--- 节点引用
function ScenesInteract:NodeRef()
    for k, v in pairs(Config.ScenesInteract) do
        interactOBJ[k] = {
            obj = world.ScenesInteract[v.Path],
            itemID = v.ItemID,
            isGet = v.IsGet,
            useCount = v.UseCount
        }
    end
end

--- 数据变量初始化
function ScenesInteract:DataInit()
end

--- 节点事件绑定
function ScenesInteract:EventBind()
    for k, v in pairs(interactOBJ) do
        v.obj.OnCollisionBegin:Connect(
            function(_hitObject)
                if _hitObject.ClassName == "PlayerInstance" then
                    curInteractID[_hitObject.UserId] = k
                    NetUtil.Fire_C("OpenDynamicEvent", _hitObject, "Interact", 13)
                end
            end
        )
        v.obj.OnCollisionEnd:Connect(
            function(_hitObject)
                if _hitObject.ClassName == "PlayerInstance" then
                    print("v.obj.OnCollisionEnd")
                    curInteractID[_hitObject.UserId] = nil
                    NetUtil.Fire_C("ChangeMiniGameUIEvent", _hitObject)
                end
            end
        )
    end
end

function ScenesInteract:Update(dt)
end

function ScenesInteract:InteractSEventHandler(_player, _id)
    if _id == 13 then
        if curInteractID[_player.UserId] then
            if interactOBJ[curInteractID[_player.UserId]].useCount > 0 then
                if interactOBJ[curInteractID[_player.UserId]].isGet then
                    NetUtil.Fire_C("GetItemEvent", _player, interactOBJ[curInteractID[_player.UserId]].itemID)
                else
                    NetUtil.Fire_C("UseItemEvent", _player, interactOBJ[curInteractID[_player.UserId]].itemID)
                end
                interactOBJ[curInteractID[_player.UserId]].useCount =
                    interactOBJ[curInteractID[_player.UserId]].useCount - 1
            else
                interactOBJ[curInteractID[_player.UserId]].obj:SetActive(false)
            end
        end
        NetUtil.Fire_C("ChangeMiniGameUIEvent", _player)
    end
end

return ScenesInteract
