--
-- User: xingjun
-- Date: 2017/3/4
-- Time: 22:07
--

print("hello.lua<> : " .. "hello world")

local t = {
    web = "www.google.com", --索引为字符串，key = "web",
    [2] = dada,
    dad = 231,
    ['dad'] = 232
}


local t2 = {
    {
        'a', 'b', 'c'
    }, {
        'a', 'b', 'c'
    },
    web = 'kkk',
    p = 'op',
    [8]=90,
}

for k, v in pairs(t2) do
    print("hello.lua<22> : " .. k)

end

local x = 3
if x > 0 then
    print("hello.lua<34> : " ..'dada' )

end