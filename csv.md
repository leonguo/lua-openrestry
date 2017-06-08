# openrestry 导出csv

 <pre>
    <code>
        local fileName = "专辑列表.csv"
        ngx.header.content_type = "text/csv;charset=utf-8"
        ngx.header["Content-disposition"] = "attachment;filename=" .. ngx.escape_uri(fileName)
        ngx.print(string.char(239) .. string.char(187) .. string.char(191))
        ngx.say("xx")

        foreach data数据
        根据查询内容一行一行写入
        ngx.say(say_str)
        ngx.flush()
    </code>
 </pre>