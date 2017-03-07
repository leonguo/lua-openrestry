--
-- User: wings
-- Date: 2017/3/6
-- Time: 17:57
--
local foo = {}

local function getName()
    return 'lucky'
end

foo.greeting = function ()
    print("my.lua<foo> hello: " .. getName())

end

return foo