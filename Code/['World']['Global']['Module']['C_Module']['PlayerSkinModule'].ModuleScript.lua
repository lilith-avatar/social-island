--- 角色服装模块
--- @module Player Skin Module
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local PlayerSkin, this = ModuleUtil.New('PlayerSkin', ClientBase)

--声明变量
local defSkin = {}
local gender

--- 初始化
function PlayerSkin:Init()
    print('[PlayerSkin] Init()')
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--- 节点引用
function PlayerSkin:NodeRef()
end

--- 数据变量初始化
function PlayerSkin:DataInit()
    this:InitDefSkin()
end

--- 节点事件绑定
function PlayerSkin:EventBind()
end

--- 初始化默认服装
function PlayerSkin:InitDefSkin()
    invoke(
        function()
            gender = localPlayer.Avatar.Gender
            print('角色性别', gender)
            for k, v in pairs(Config.Skin[1][gender]) do
                defSkin[k] = localPlayer.Avatar[k]
            end
        end,
        .5
    )
end

-- 更新角色服装
function PlayerSkin:PlayerSkinUpdateEventHandler(_skinID)
    if _skinID ~= 0 then
        Data.Player.attr.SkinID = _skinID
        for k, v in pairs(Config.Skin[_skinID][gender]) do
            if localPlayer.Avatar[k] then
                if v ~= '' then
                    print(k, '->>>')
                    localPlayer.Avatar[k] = v
                    print(defSkin[k])
                else
                    print(k, '->>>')
                    localPlayer.Avatar[k] = defSkin[k]
                    print(defSkin[k])
                end
            end
        end
    else
        for k, v in pairs(defSkin) do
            if localPlayer.Avatar[k] and v ~= '' then
                localPlayer.Avatar[k] = v
            end
        end
    end
end

function PlayerSkin:Update(dt)
end

return PlayerSkin
