--- 游戏同步数据基类
--- @module Sync Data Base, Both-side
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
MetaData = {}

-- _t = MetaData

-- t = {}

-- -- 原表
--  mt = {
--     IsServer = true,
--     __newindex = function(t, k, v)
--         print('xxxxxx')
--         _t[k] = v
--     end
-- }

-- setmetatable(t, mt)

-- function MetaData.New(_t)
--     _t = _t or {}
--     setmetatable(_t, MetaData.mt)
--     return _t
-- end

-- --给元表设置__index属性
-- MetaData.mt.__index = {}

-- --给元表设置__newindex 属性
-- other_fun = function(t, k, v)
--     print('保护对象表t,让用户不能给t表设置新的方法或者属性')
-- end
-- MetaData.mt.__newindex = other_fun

-- dog = MetaData.New({name = 'dog'})
-- print(dog.color)

-- print(dog.cloth)

-- dog.eyenum = 32
-- print(dot.eyenum)

return MetaData
