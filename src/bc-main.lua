-- bc-main.lua
-- Main application of Beehive Controller.
-- Author: victoru


-- Loading the ds18b20.lua module
ds18b20 = dofile("ds18b20.lc")

GPIO5 = 1
GPIO13 = 7

----------------------------------------------------
-- GPIO pin of temperature sensor (INPUT) 
PIN_TEMP_SENSOR = GPIO5

-- GPIO pin of turning ON and OFF the heater (OUTPUT)
PIN_HEATER = GPIO13

-----------------------------------------------------
-- Setup GPIO pins mode
gpio.mode(PIN_HEATER, gpio.OUTPUT)
gpio.write(PIN_HEATER, gpio.LOW)
gpio.mode(PIN_TEMP_SENSOR, gpio.INPUT)
-----------------------------------------------------

-- configuration from bc-init.cfg
conf = {}

-- global statistic values storage
stor = {}

conf = dofile("bc-conf.lc")

local t_timer = tmr.create()
local heater_stat = false

ds18b20.setup(PIN_TEMP_SENSOR)

t = ds18b20.read()

stor.temp_current = t
stor.temp_switchon = 0
stor.temp_switchoff = 0

local r_timer = tmr.create()

function relay_antistick()
    if gpio.read(PIN_HEATER) == gpio.HIGH then
       gpio.write(PIN_HEATER, gpio.LOW)
       r_timer:alarm( 1000, tmr.ALARM_SINGLE, 
            function() 
                gpio.write(PIN_HEATER, gpio.HIGH)
            end)
    else
       gpio.write(PIN_HEATER, gpio.HIGH)
       r_timer:alarm( 1000, tmr.ALARM_SINGLE, 
            function() 
                gpio.write(PIN_HEATER, gpio.LOW)
            end)
    end
end

local received = 0

--- function sendData sends the data to api.thingspeak.com 
--- after connecting to the site and close connection after 
--- receives some answers
function sendData()
  
  conn=net.createConnection(net.TCP, 0) 

  -- set the on-event functions for connection events
  
  conn:on("receive", function(conn, payload) 
      print(payload) 
      received = 1 
      conn:close() 
      end)


  conn:on("connection", 
    function(conn)
      received = 0 
      print("on-connection: connected, start sending")
      conn:send("GET https://api.thingspeak.com/update?api_key=B6G7CL03OYDOWP9U&field1="..
stor.temp_current.."&field2="..gpio.read(PIN_HEATER).." HTTP/1.0\r\nHost: thingspeak.com\r\nUser-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\nAccept: */*\r\nConnection: close\r\n\r\n") 

    end)

  conn:on("sent", function(conn)
                      
                      print("on-sent: non Closing connection")
                     
                  end)
  conn:on("disconnection", function(conn)
                                print("on-disconnection: Got disconnection...")
                           end)

  -- try to connect
  conn:connect(80,'thingspeak.com')

end



t_timer:alarm( tonumber(conf.read_temp_time), tmr.ALARM_AUTO, 
	function() 
		t=ds18b20.read()
        stor.temp_current = t
        print("t = " .. t )
		if tonumber(t) < tonumber(conf.min_temp) then
            print("p1 PI_HEATER")
			gpio.write(PIN_HEATER, gpio.HIGH)
            stor.temp_switchon = t
            print("p1: " .. gpio.read(PIN_HEATER))
        elseif tonumber(t) < tonumber(conf.max_temp) then
            print("p2 PI_HEATER")
            if (gpio.read(PIN_HEATER) == 0) then
                gpio.write(PIN_HEATER, gpio.HIGH)
                stor.temp_switchon = t
                print("p2: " .. gpio.read(PIN_HEATER))
            end
		end

		if  tonumber(t) > tonumber(conf.max_temp) or t == nil then
            if gpio.read(PIN_HEATER) == gpio.HIGH then
			    gpio.write(PIN_HEATER, gpio.LOW)
                stor.temp_switchoff = t
            -- anti-sticking protection:
            elseif tonumber(t)+2 > tonumber(stor.temp_switchoff) then
                --relay_antistick()
                --stor.temp_switchoff = t
            end
            print("p3: " .. gpio.read(PIN_HEATER))
		end 
	end
)

-- trying the connection to wifi gateway 
-- and send data to the Internet server
tmr.alarm(1, 1000, tmr.ALARM_AUTO, 
     function()
         if wifi.sta.getip()== nil then
         --print("ip=nil")
         else
           tmr.stop(1)
           print("Config done, IP is "..wifi.sta.getip())
           sendData()
     
           tmr.alarm(0, 3000, tmr.ALARM_SEMI, function()
               tmr.stop(0)
--               wifi.sleeptype(wifi.MODEM_SLEEP)
               wifi.sta.disconnect()
--               wifi.setmode(wifi.NULLMODE)
               print("wifi disconnected")         
    end)
  end
end)


station_cfg={}
station_cfg.ssid=tostring(conf.ssid_gw)
station_cfg.pwd=tostring(conf.pass_gw)
station_cfg.auto=false


function wifiStart()
    wifi.setmode(wifi.STATIONAP)
    cfg={}
    cfg.ssid=tostring(conf.ssid_bc)
    cfg.pwd=tostring(conf.pass_bc)
    cfg.channel=6
    wifi.ap.config(cfg)
    cfd ={}
    cfd.ip="192.168.2.1"
    cfd.netmask="255.255.255.0"
    cfd.gateway="192.168.2.1"
    wifi.ap.setip(cfd)
    print("Access Point IP:  " .. wifi.ap.getip())
    print("Access Point MAC: " .. wifi.ap.getmac())
end

wifiStart()



dofile("bc-server.lc")

serverStart("index.html", stor, conf)

-- every 30 minutes
tmr.alarm(3, tonumber(conf.send_data_time), tmr.ALARM_AUTO, 
     function()
--         if  wifi.getmode() == wifi.NULLMODE then
--           tmr.stop(0)
--           print("Connecting to wifi station...")
--           wifi.setmode(wifi.STATIONAP)
--           print(station_cfg.ssid)
--           print(station_cfg.pwd)
           wifi.sta.config( station_cfg )
           wifi.sta.connect()
           tmr.start(1)
--         end
     end
)


