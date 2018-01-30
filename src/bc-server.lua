-- bc-server.lua
-- Very simple hhtp server for only one page, is used for handling the changes of configuration
-- Author: victoru

local function hex_to_char(x)
  return string.char(tonumber(x, 16))
end

local function uri_decode(input)
  return input:gsub("%+", " "):gsub("%%(%x%x)", hex_to_char)
end

local function parseArgs(args)
   local r = {}
   local i = 1
   if args == nil or args == "" then return r end
   for arg in string.gmatch(args, "([^&]+)") do
      local name, value = string.match(arg, "(.*)=(.*)")
      if name ~= nil then r[name] = uri_decode(value) end
      i = i + 1
   end
   return r
end


local function parseUri(uri)
   local r = {}
   local filename
   local ext
   local fullExt = {}

   if uri == nil then return r end
   if uri == "/" then uri = "/index.html" end
   local questionMarkPos, b, c, d, e, f = uri:find("?")
   if questionMarkPos == nil then
      r.file = uri:sub(1, questionMarkPos)
      r.args = {}
   else
      r.file = uri:sub(1, questionMarkPos - 1)
      r.args = parseArgs(uri:sub(questionMarkPos+1, #uri))
   end
   filename = r.file
   while filename:match("%.") do
      filename,ext = filename:match("(.+)%.(.+)")
      table.insert(fullExt,1,ext)
   end
   if #fullExt >= 1 then
      r.ext = fullExt[#fullExt]
   end
   return r
end



-- Parses the client's request. Returns a dictionary containing pretty much everything
-- the server needs to know about the uri.
function getRequest(request)
   --print("Request: \n", request)
   local e = request:find("\r\n", 1, true)
   if not e then return nil end
   local line = request:sub(1, e - 1)
   local r = {}
   local _, i
   _, i, r.method, r.request = line:find("^([A-Z]+) (.-) HTTP/[1-9]+.[0-9]+$")
   if not (r.method and r.request) then
      --print("invalid request: ")
      --print(request)
      return nil
   end
   r.uri = parseUri(r.request)
--   r.requestData = getRequestData(request)
   return r
end


function wificonfigHandler(args, conf)
    if args["SSID_GW"] ~= nil then
        conf.ssid_gw = args["SSID_GW"]
    end
    if args["PASS_GW"] ~= nil then
        conf.pass_gw = args["PASS_WG"]
    end
    if args["SSID_BC"] ~= nil then
        conf.ssid_bc = args["SSID_BC"]
    end
    if args["PASS_BC"] ~= nil then
        conf.pass_bc = args["PASS_BC"]
    end
    writeconfig(conf)

    local html = "<html><head><title>result</title></head><body>Wifi Configuration saved</body></html>"
    return html

end

function onoffHandler(args)
    local html = "<html><head><title>result</title></head><body>On/Off done</body></html>"
    return html

end

function resetHandler(args)
    node.restart()
    local html = "<html><head><title>result</title></head><body>Module reseted</body></html>"
    return html
end

-- Start a simple http server

local req = {}

function serverStart(indexhtml, stor, conf)
  srv=net.createServer(net.TCP)
  srv:listen(80,function(conn)
    conn:on("receive",function(conn,payload)
      print(payload)
      req = getRequest(payload)
      print(req.requestData)


      local html
      if req.uri.file == "/config" then
          configHandler = dofile("bc-server-cfghndl.lc")
          html = configHandler(req.uri.args, conf)
          conn:send(html)
          configHandler = nil
      elseif req.uri.file == "/wificonfig" then
          configHandler = dofile("bc-server-wificfghndl.lc")
          html = configHandler(req.uri.args, conf)
          conn:send(html)
          configHandler = nil          
      elseif req.uri.file == "/onoff" then
          html = onoffHandler(req.uri.args)
          conn:send(html)
      elseif req.uri.file == "/reset" then
          html = resetHandler(req.uri.args)
          conn:send(html)
      else
          req = nil
          collectgarbage()
 
          if file.open(indexhtml, "r") then
            local line
            repeat
                
                line = file.readline()
                if  (line) then
                    -- print(line)
                    line = string.gsub(line, "#temp", stor.temp_current)
                    if (gpio.read(PIN_HEATER) > 0) then
                        line = string.gsub(line, "#stat", "On");
                    else 
                        line = string.gsub(line, "#stat", "Off");
                    end
                    line = string.gsub(line, "#mintemp", conf.min_temp)
                    line = string.gsub(line, "#maxtemp", conf.max_temp)
                    line = string.gsub(line, "#freqt", conf.read_temp_time)
                    line = string.gsub(line, "#freqs", conf.send_data_time)
                    line = string.gsub(line, "#SSID_GW", conf.ssid_gw)
                    line = string.gsub(line, "#PASS_GW", conf.pass_gw)
                    line = string.gsub(line, "#SSID_BC", conf.ssid_bc)
                    line = string.gsub(line, "#PASS_BC", conf.pass_bc)
                            
                    conn:send(line)
                
                    -- print(line)
                end
            until line == nil
            file.close()
            line = nil        
          else
            conn:send("<html><head><title>404</title></head><body>404</body></html>")
          end
      end 
      req = nil
      html = nil
--      conn:close()
      collectgarbage()
    end)
    conn:on("sent",function(conn) conn:close() end)
  end)
end

collectgarbage()
