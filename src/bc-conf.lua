-- bc-conf.lua 
-- Read and save global configurations
-- Author: victoru


local conf_file_name = "bc-init.cfg"
local config = {}

local function readconfig()

    local l = file.list();
    for k,v in pairs(l) do
       print("name:"..k..", size:"..v)
    end

	if file.open(conf_file_name, "r") then
		local line, pname, pvalue
  		repeat
			line = file.readline()
            
            if  (line) then
                line = string.sub (line, 1, line:find("\n")-1 )
			    pname = string.gsub( string.sub (line, 1, line:find("=")-1 ), " ", "")
			    pvalue = string.gsub( string.sub (line, line:find( "=")+1 ), " ", "")
			    print("pname=" .. pname)
                print("pvalue=" .. pvalue)
			    if pname == "SSID_BC" then config.ssid_bc = pvalue
			    elseif pname == "PASS_BC" then config.pass_bc = pvalue
			    elseif pname == "SSID_GW" then config.ssid_gw = pvalue
			    elseif pname == "PASS_GW" then config.pass_gw = pvalue
			    elseif pname == "READ_TEMP_TIME" then config.read_temp_time = pvalue
			    elseif pname == "SEND_DATA_TIME" then config.send_data_time = pvalue
			    elseif pname == "MIN_TEMP" then config.min_temp = pvalue
			    elseif pname == "MAX_TEMP" then config.max_temp = pvalue
			    end
             end
		until line == nil
        line = nil
        pname = nil
        pvalue = nil
  		file.close()
    else
        print("Can't open file " .. conf_file_name)
	end
    l = nil
    return config
end

config = readconfig()
--readconfig = nil
collectgarbage()


return config




