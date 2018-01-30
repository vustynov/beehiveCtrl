-- bc-server-wificfghndl.lua
-- Handling of webform for wifi congiguration changing
-- Author: victoru


return function(args, conf)
    if args["SSID_GW"] ~= nil then
        conf.ssid_gw = tostring(args["SSID_GW"])
    end
    if args["PASS_GW"] ~= nil then
        print("1 conf.pass_gw = " .. conf.pass_gw)
        conf.pass_gw = tostring(args["PASS_GW"])
        print("2 conf.pass_gw = " .. conf.pass_gw)
    end
    if args["SSID_BC"] ~= nil then
        conf.ssid_bc = tostring(args["SSID_BC"])
    end
    if args["PASS_BC"] ~= nil then
        conf.pass_bc = tostring(args["PASS_BC"])
    end
    local writeconfig = dofile("bc-writeconfig.lc")
    writeconfig(conf)
    writeconfig = nil
    local html = "<html><head><title>result</title></head><body>Wifi Configuration saved</body></html>"
    return html
end
