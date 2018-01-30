-- bc-server-cfghndl.lua
-- The form configuration handler. Saves configuration data to a config file 
-- Author: victoru

return function (args, conf)
    if args["mintemp"] ~= nil then
        conf.min_temp = args["mintemp"]
    end
    if args["maxtemp"] ~= nil then
        conf.max_temp = args["maxtemp"]
    end
    if args["freqt"] ~= nil then
        conf.read_temp_time = args["freqt"]
    end
    if args["freqs"] ~= nil then
        conf.send_data_time = args["freqs"]
    end
    local writeconfig = dofile("bc-writeconfig.lc")
    writeconfig(conf)
    writeconfig = nil
    local html = "<html><head><title>result</title></head><body>Configuration saved</body></html>"
    return html
end
