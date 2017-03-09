# lua-openrestry

- lua知识总结
   - 技巧
     - 变量申明尽量使用local
     
     - 错误处理需要使用pcall包装要执行的代码
     
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
               print('dada'..tostring(n))
              if n > 0 then
                  return foo(n-1)
              else
                  return 'over'
              end
          end
          local rr = foo(22)
    </code>
    </pre>
