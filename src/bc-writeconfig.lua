-- bc-writeconfig.lua
-- return function for writing configuration from conf table to the file
-- Author: victoru

local conf_file_name = "bc-init.cfg"

return function ( conf )
    if file.open(conf_file_name, "w") then
        file.write( "SSID_BC = " .. tostring(conf.ssid_bc) .. "\n")
        file.write( "PASS_BC = " .. tostring(conf.pass_bc) .. "\n")
        file.write( "SSID_GW = " .. tostring(conf.ssid_gw) .. "\n")
        file.write( "PASS_GW = " .. tostring(conf.pass_gw) .. "\n")
        file.write( "READ_TEMP_TIME = " .. tostring(conf.read_temp_time) .. "\n")
        file.write( "SEND_DATA_TIME = " .. tostring(conf.send_data_time) .. "\n")
        file.write( "MIN_TEMP = " .. tostring(conf.min_temp) .. "\n")
        file.write( "MAX_TEMP = " .. tostring(conf.max_temp) .. "\n")
        file.flush()
        file.close()
    end 
end
