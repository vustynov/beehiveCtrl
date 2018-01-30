print("Starting...")
wifi.setmode(wifi.NULLMODE)
wifi.sleeptype(wifi.MODEM_SLEEP)
dofile("bc-compile.lua")
dofile("bc-main.lc")
dofile("bc-server.lc")


