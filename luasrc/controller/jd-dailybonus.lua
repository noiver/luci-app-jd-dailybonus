-- Copyright (C) 2020 jerrykuku <jerrykuku@gmail.com>
-- Licensed to the public under the GNU General Public License v3.
module("luci.controller.jd-dailybonus", package.seeall)
function index() 
    if not nixio.fs.access("/etc/config/jd-dailybonus") then 
        return 
    end
    
    entry({"admin", "services", "jd-dailybonus"}, alias("admin", "services", "jd-dailybonus", "client"), _("JD-DailyBonus"), 10).dependent = true -- 首页
    entry({"admin", "services", "jd-dailybonus", "client"}, cbi("jd-dailybonus/client"),_("Client"), 10).leaf = true -- 基本设置
    entry({"admin", "services", "jd-dailybonus", "log"},form("jd-dailybonus/log"),_("Log"), 80).leaf = true -- 日志页面
    entry({"admin", "services", "jd-dailybonus", "run"}, call("run")) -- 执行程序
    
end

-- 执行程序

function run()
    local e = {}
    local uci = luci.model.uci.cursor()
    local cookie = luci.http.formvalue("cookies")
    local cookie2 = luci.http.formvalue("cookies2")
    local auto_update = luci.http.formvalue("auto_update")
    local auto_update_time = luci.http.formvalue("auto_update_time")

    if cookie ~= " " then
        local cmd1 = 'uci set jd-dailybonus.@global[0].auto_update="' .. auto_update .. '"'
        local cmd2 = 'uci set jd-dailybonus.@global[0].auto_update_time="' .. auto_update_time .. '"'
        local cmd3 = 'uci set jd-dailybonus.@global[0].cookie="' .. cookie .. '"'
        local cmd3_1 = 'uci set jd-dailybonus.@global[0].cookie2="' .. cookie2 .. '"'
        local cmd4 = 'uci commit jd-dailybonus'
        local varb = "var Key = '".. cookie .."'"
        local cmd5 = "sed -i '18d' /usr/share/jd-dailybonus/JD_DailyBonus.js"
        local cmd6 = 'sed -i "17a '.. varb ..'" -i /usr/share/jd-dailybonus/JD_DailyBonus.js'
        local varb2 = "var DualKey = '".. cookie2 .."'"
        local cmd5_1 = "sed -i '20d' /usr/share/jd-dailybonus/JD_DailyBonus.js"
        local cmd6_1 = 'sed -i "19a '.. varb2 ..'" -i /usr/share/jd-dailybonus/JD_DailyBonus.js'

        luci.sys.call(cmd1)
        luci.sys.call(cmd2)
        luci.sys.call(cmd3)
        luci.sys.call(cmd3_1)
        luci.sys.call(cmd4)
        luci.sys.call(cmd5)
        luci.sys.call(cmd6)
        luci.sys.call(cmd5_1)
        luci.sys.call(cmd6_1)
        luci.sys.call("nohup node /usr/share/jd-dailybonus/JD_DailyBonus.js >/www/JD_DailyBonus.htm 2>/dev/null &")
        
        e.error = 0
    else
        e.error = 1
    end

    luci.http.prepare_content("application/json")
    luci.http.write_json(e)

end