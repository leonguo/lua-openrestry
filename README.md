## lua-openrestry

- openrestry 知识总结
   - web框架
      - [lor](https://github.com/sumory/lor)
      - [vanilla](https://github.com/idevz/vanilla)
   
   - [lua单元测试](https://github.com/Olivine-Labs/busted)
   
   - [wrk-HTTP压测工具](https://github.com/wg/wrk)
      - [lua-POST压测脚本](https://github.com/leonguo/lua-openrestry/blob/master/wrk/post.lua)

   - ngx_lua模块API说明
      - Ngx指令
         - lua_code_cache on | off;
            <pre>
             作用:打开或关闭 Lua 代码缓存，影响以下指令： set_by_lua_file , content_by_lua_file, rewrite_by_lua_file, access_by_lua_file 及强制加载或者reload Lua 模块等.缓存开启时修改LUA代码需要重启nginx,不开启时则不用。开发阶段一般关闭缓存。
             作用域：main, server, location, location if
            </pre>

         - lua_regex_cache_max_entries 1024;
             <pre>
             作用：未知（貌似是限定缓存正则表达式处理结果的最大数量）
             </pre>

         - lua_package_path .../path... ;
             <pre>
             作用：设置用lua代码写的扩展库路径。
             例：lua_package_path '/foo/bar/?.lua;/blah/?.lua;;';
             </pre>
         - lua_package_cpath '/bar/baz/?.so;/blah/blah/?.so;;';
            <pre>
            作用：设置C扩展的lua库路径。
         </pre>
         - set_by_lua $var '<lua-script>' [$arg1 $arg2];
            <pre>
             set_by_lua_file $var <path-to-lua-script-file> [$arg1 $arg2 ...];
             作用：设置一个Nginx变量，变量值从lua脚本里运算由return返回，可以实现复杂的赋值逻辑；此处是阻塞的，Lua代码要做到非常快.
             另外可以将已有的ngx变量当作参数传进Lua脚本里去，由ngx.arg[1],ngx.arg[2]等方式访问。
             作用域：main, server, location, server if, location if
             处理阶段：rewrite
            </pre>
         - content_by_lua '<lua script>';
         <pre>
             content_by_lua_file luafile;
             作用域：location, location if
             说明：内容处理器，接收请求处理并输出响应，content_by_lua直接在nginx配置文件里编写较短Lua代码后者使用lua文件。
        </pre>
         - rewrite_by_lua '<lua script>'
            <pre>
             rewrite_by_lua_file lua_file;
             作用域：http, server, location, location if
             执行内部URL重写或者外部重定向，典型的如伪静态化的URL重写。其默认执行在rewrite处理阶段的最后.
             注意，在使用rewrite_by_lua时，开启rewrite_log on;后也看不到相应的rewrite log。
            </pre>
         - access_by_lua 'lua code';
         <pre>
             access_by_lua_file lua_file.lua;
             作用：用于访问控制，比如我们只允许内网ip访问，可以使用如下形式。
             access_by_lua '
             if ngx.req.get_uri_args()["token"] ~= "123" then
                return ngx.exit(403)
             end ';
             作用域：http, server, location, location if
        </pre>
         - header_filter_by_lua 'lua code';
         <pre>
             header_filter_by_lua_file path_file.lua;
             作用：设置header 和 cookie；
        </pre>
         - lua_need_request_body on|off;
         <pre>
             作用：是否读请求体，跟ngx.req.read_body()函数作用类似,但官方不推荐使用此方法。

         - lua_shared_dict shared_data 10m;
         <pre>
             作用：设置一个共享全局变量表，在所有worker进程间共享。在lua脚本中可以如下访问它：
             例：local shared_data = ngx.shared.shared_data
             10m 不知是什么意思。
        </pre>
         - init_by_lua 'lua code';
         <pre>
             init_by_lua_file lua_file.lua;
             作用域：http
             说明：ginx Master进程加载配置时执行；通常用于初始化全局配置/预加载Lua模块
        </pre>
         - init_worker_by_lua 'lua code';
            <pre>
             init_worker_by_lua_file luafile.lua;
             作用域：http
             说明：每个Nginx Worker进程启动时调用的计时器，如果Master进程不允许则只会在init_by_lua之后调用；通常用于定时拉取配置/数据，或者后端服务的健康检查。
             </pre>

   - 常用常量和方法
     - 详细说明
        <pre><code>
        ngx.arg[index]              #ngx指令参数，当这个变量在set_by_lua或者set_by_lua_file内使用的时候是只读的，指的是在配置指令输入的参数.
        ngx.var.varname             #读写NGINX变量的值,最好在lua脚本里缓存变量值，避免在当前请求的生命周期内内存的泄漏
        ngx.config.ngx_lua_version  #当前ngx_lua模块版本号
        ngx.config.nginx_version    #nginx版本
        ngx.worker.exiting          #当前worker进程是否正在关闭
        ngx.worker.pid              #当前worker进程的PID
        ngx.config.nginx_configure  #编译时的./configure命令选项
        ngx.config.prefix           #编译时的prefix选项

        core constans:              #ngx_lua 核心常量
            ngx.OK (0)
            ngx.ERROR (-1)
            ngx.AGAIN (-2)
            ngx.DONE (-4)
            ngx.DECLINED (-5)
            ngx.nil
        http method constans:       #经常在ngx.location.catpure和ngx.location.capture_multi方法中被调用.
            ngx.HTTP_GET
            ngx.HTTP_HEAD
            ngx.HTTP_PUT
            ngx.HTTP_POST
            ngx.HTTP_DELETE
            ngx.HTTP_OPTIONS
            ngx.HTTP_MKCOL
            ngx.HTTP_COPY
            ngx.HTTP_MOVE
            ngx.HTTP_PROPFIND
            ngx.HTTP_PROPPATCH
            ngx.HTTP_LOCK
            ngx.HTTP_UNLOCK
            ngx.HTTP_PATCH
            ngx.HTTP_TRACE
        http status constans:       #http请求状态常量
            ngx.HTTP_OK (200)
            ngx.HTTP_CREATED (201)
            ngx.HTTP_SPECIAL_RESPONSE (300)
            ngx.HTTP_MOVED_PERMANENTLY (301)
            ngx.HTTP_MOVED_TEMPORARILY (302)
            ngx.HTTP_SEE_OTHER (303)
            ngx.HTTP_NOT_MODIFIED (304)
            ngx.HTTP_BAD_REQUEST (400)
            ngx.HTTP_UNAUTHORIZED (401)
            ngx.HTTP_FORBIDDEN (403)
            ngx.HTTP_NOT_FOUND (404)
            ngx.HTTP_NOT_ALLOWED (405)
            ngx.HTTP_GONE (410)
            ngx.HTTP_INTERNAL_SERVER_ERROR (500)
            ngx.HTTP_METHOD_NOT_IMPLEMENTED (501)
            ngx.HTTP_SERVICE_UNAVAILABLE (503)
            ngx.HTTP_GATEWAY_TIMEOUT (504)

        Nginx log level constants：      #错误日志级别常量 ,这些参数经常在ngx.log方法中被使用.
            ngx.STDERR
            ngx.EMERG
            ngx.ALERT
            ngx.CRIT
            ngx.ERR
            ngx.WARN
            ngx.NOTICE
            ngx.INFO
            ngx.DEBUG
        </code></pre>

     - API中的方法：
        <pre><code>
        ngx.arg
        ngx.var.VARIABLE
        print                                       #与 ngx.print()方法有区别，print() 相当于ngx.log()
        ngx.ctx                                     #这是一个lua的table，用于保存ngx上下文的变量，在整个请求的生命周期内都有效,详细参考官方
        ngx.location.capture                        #发出一个子请求，详细用法参考官方文档。
        ngx.location.capture_multi                  #发出多个子请求，详细用法参考官方文档。
        ngx.status                                  #读或者写当前请求的相应状态. 必须在输出相应头之前被调用.
        ngx.header.HEADER                           #访问或设置http header头信息，详细参考官方文档。
        ngx.resp.get_headers
        ngx.req.is_internal
        ngx.req.start_time
        ngx.req.http_version
        ngx.req.raw_header
        ngx.req.get_method
        ngx.req.set_method
        ngx.req.set_uri                             #设置当前请求的URI,详细参考官方文档
        ngx.req.set_uri_args                        #根据args参数重新定义当前请求的URI参数.
        ngx.req.get_uri_args                        #返回一个LUA TABLE，包含当前请求的全部的URL参数
        ngx.req.get_post_args                       #返回一个LUA TABLE，包括所有当前请求的POST参数
        ngx.req.get_headers
        ngx.req.set_header
        ngx.req.clear_header
        ngx.req.read_body
        ngx.req.discard_body
        ngx.req.get_body_data                       #以字符串的形式获得客户端的请求body内容
        ngx.req.get_body_file
        ngx.req.set_body_data
        ngx.req.set_body_file
        ngx.req.init_body
        ngx.req.append_body
        ngx.req.finish_body
        ngx.req.socket
        ngx.exec
        ngx.redirect                                #执行301或者302的重定向。
        ngx.send_headers                            #发送指定的响应头
        ngx.headers_sent                            #判断头部是否发送给客户端ngx.headers_sent=true
        ngx.print                                   #发送给客户端的响应页面
        ngx.say                                     #输出客户端内容
        ngx.log
        ngx.flush
        ngx.exit
        ngx.eof
        ngx.sleep
        ngx.escape_uri
        ngx.unescape_uri
        ngx.encode_args
        ngx.decode_args
        ngx.encode_base64
        ngx.decode_base64
        ngx.crc32_short
        ngx.crc32_long
        ngx.hmac_sha1
        ngx.md5
        ngx.md5_bin
        ngx.sha1_bin
        ngx.quote_sql_str
        ngx.today
        ngx.time
        ngx.now
        ngx.update_time
        ngx.localtime
        ngx.utctime
        ngx.cookie_time
        ngx.http_time
        ngx.parse_http_time
        ngx.is_subrequest
        ngx.re.match
        ngx.re.find
        ngx.re.gmatch
        ngx.re.sub
        ngx.re.gsub
        ngx.shared.DICT
        ngx.shared.DICT.get
        ngx.shared.DICT.get_stale
        ngx.shared.DICT.set
        ngx.shared.DICT.safe_set
        ngx.shared.DICT.add
        ngx.shared.DICT.safe_add
        ngx.shared.DICT.replace
        ngx.shared.DICT.delete
        ngx.shared.DICT.incr
        ngx.shared.DICT.lpush
        ngx.shared.DICT.rpush
        ngx.shared.DICT.lpop
        ngx.shared.DICT.rpop
        ngx.shared.DICT.llen
        ngx.shared.DICT.flush_all
        ngx.shared.DICT.flush_expired
        ngx.shared.DICT.get_keys
        ngx.socket.udp
        udpsock:setpeername
        udpsock:send
        udpsock:receive
        udpsock:close
        udpsock:settimeout
        ngx.socket.stream
        ngx.socket.tcp
        tcpsock:connect
        tcpsock:sslhandshake
        tcpsock:send
        tcpsock:receive
        tcpsock:receiveuntil
        tcpsock:close
        tcpsock:settimeout
        tcpsock:settimeouts
        tcpsock:setoption
        tcpsock:setkeepalive
        tcpsock:getreusedtimes
        ngx.socket.connect
        ngx.get_phase
        ngx.thread.spawn
        ngx.thread.wait
        ngx.thread.kill
        ngx.on_abort
        ngx.timer.at
        ngx.timer.running_count
        ngx.timer.pending_count
        ngx.config.subsystem
        ngx.config.debug
        ngx.config.prefix
        ngx.config.nginx_version
        ngx.config.nginx_configure
        ngx.config.ngx_lua_version
        ngx.worker.exiting
        ngx.worker.pid
        ngx.worker.count
        ngx.worker.id
        ngx.semaphore
        ngx.balancer
        ngx.ssl
        ngx.ocsp
        ndk.set_var.DIRECTIVE
        coroutine.create
        coroutine.resume
        coroutine.yield
        coroutine.wrap
        coroutine.running
        coroutine.status
    </code></pre>

   - lua技巧
     - 变量申明尽量使用local
     
     - 错误处理
        - 使用pcall包装要执行的代码
     
     - 使用require加载模块
     
     - 请求返回可以继续执行任务(fastcgi_finish, ngx.eof())
     
     - 连接池使用
     
     - Lua中数组的索引是从1开始的
        - 可以使用#号(所有数字索引总和).
        - table.maxn(最后一个数字索引键值)两种方法来获取数组的长度
       
     - 判断table对象为空 table = {}
       <pre><code>if next(a) ~=nil then dosomething end`</code></pre>
       
   - 函数、闭包、尾调用
     - 函数 
     <pre>
     <code>
        local function func_name (args-list)
            statements-list
        end
        
        local foo = function (x) return 2*x end
        
        local function test(a,b,...) 
            reurn a,b
        end
      </code>
      </pre>
    
     - 闭包 
     <pre>
     <code>
         local function fn()
             local i = 0
             return function() -- 注意这里是返回函数的地址，不是执行
                 i = i+1
             return i
             end
         end
         local c1 = fn()           -- 接收函数返回的地址
         print(c1())  --> 1          --c1()才表示执行
         print(c1())  --> 2
   </code>
   </pre>
   
   - 函数尾调用
    <pre>
      <code>
          local function foo(n)
              if n > 0 then
                  return foo(n-1)
              else
                  return 'over'
              end
          end
          local rr = foo(22)
    </code>
    </pre>

   - string.find()
   <pre>
      <code>
    s = 'crate.png'
    i, j = string.find(s, '.')
    
    Do either string.find(s, '%.') or string.find(s, '.', 1, true)
    </code>
    </pre>