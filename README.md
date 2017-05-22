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

   - [postgresql文档](https://www.postgresql.org/docs/manuals/)

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

     - 检查全局变量的命令 :lua-releng  -L *.lua 2>&1 | grep -v -e "lua\:" -e "VERSION"

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