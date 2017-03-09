--
-- User: wings
-- Date: 2017/3/9
-- Time: 20:57
--
-- 测试多用户发送post数据
local counter = 1
local threads = {}

function setup(thread)
    thread:set("id", counter)
    table.insert(threads, thread)
    counter = counter + 1
end

function init(args)
    requests = 0
    responses = 0

    local msg = "thread %d created"
    print(msg:format(id))
end

function request()
    requests = requests + 1
    wrk.method = "POST"
    -- TOKEN可以根据算法生成，不用固定。暂时测试方便
    local dev_id, taken_id, res_id
    local dev_ids = { "C825E17732C2", "C825E17732C3", "C825E17732C4", "C825E17732C5", "C825E17732C6", "C825E17732C7" }
    local token_ids = {"111111", "222222","333333", "444444", "555555","666666"}
    local res_ids = { 118059, 118060, 118061, 118062, 118063, 118064 }
    local sum_dev_ids = #dev_ids
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    local id
    for i = 1, 5 do
        id = math.random(sum_dev_ids)
    end
    -- 可以分别随机各个参数的值
    dev_id = dev_ids[id]

    taken_id = token_ids[id]
    res_id = res_ids[id]
    wrk.body = '{}'
    wrk.headers["X-YF-AppId"] = "api_v1"
    wrk.headers["X-YF-rid"] = "1"
    wrk.headers["X-YF-Platform"] = "test"
    wrk.headers["X-YF-Version"] = "2.8.1"
    wrk.headers["X-YF-Sign"] = "2233444"
    wrk.headers["X-YF-Token"] = taken_id
    return wrk.format(wrk.method, nil, wrk.headers, wrk.body)
end

function response(status, headers, body)
    responses = responses + 1
end

function done(summary, latency, requests)
    for index, thread in ipairs(threads) do
        local id = thread:get("id")
        local requests = thread:get("requests")
        local responses = thread:get("responses")
        local msg = "thread %d made %d requests and got %d responses"
        print(msg:format(id, requests, responses))
    end
end

