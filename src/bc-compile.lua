-- httpserver-compile.lua
-- Part of Beehive Controller, compiles lua scripts after starting.
-- Author: victoru

local compileAndRemove = function(f)
   if file.exists(f) then
      print('Compiling:', f)
      node.compile(f)
      file.remove(f)
      collectgarbage()
   end
end

local bcFiles = {
   'bc-main.lua',
   'ds18b20.lua',
   'bc-conf.lua',
   'bc-server.lua',
   'bc-server-cfghndl.lua',
   'bc-server-wificfghndl.lua',
   'bc-writeconfig.lua',
}
for i, f in ipairs(bcFiles) do compileAndRemove(f) end


compileAndRemove = nil
bcFiles = nil
collectgarbage()

