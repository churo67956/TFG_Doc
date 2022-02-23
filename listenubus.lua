require "ubus"
require "uloop"

params = { ... }
-- evento a escuchar                                                                                                                                                                                                                                                                                                      
event_name = params[1]
-- el patron a compara con la lectura real                                                                                                                                                                                                                                                                                
print(params[2])
loadstring("target="..params[2])()
-- para los numericos un error permitido                                                                                                                                                                                                                                                                                  
error = params[3]
print(error)
-- functiones de validacion                                                                                                                                                                                                                                                                                               
local validation = {
    default = function(msg)
      conn:close()
      for k, v in pairs(target) do
          print("clave "..k.." valor "..tostring(msg[k]))
          if ( msg[k] == nill or tostring(msg[k]) ~= tostring(v) )
          then
            print("default es distinto: esperado : ".. v .." leido ".. tostring(msg[k]))
            os.exit(1)
          end
      end
      os.exit(0)
    end,
    number = function(msg)
      conn:close()
      for k, v in pairs(target) do
         if ( msg[k] == nill )
         then
           print("numeric Error : clave "..k.. " es nula")
           os.exit(1)
         else
           x= math.abs(tonumber(v)- tonumber(msg[k]))
           if ( x > tonumber(error))
           then
            print("Error: esperado " .. tostring(v) .. " lectura " ..tostring(msg[k]) .. " error_max "..tostring(error))
            os.exit(1)
           end
         end
      end
      os.exit(0)
    end,
    echo = function(msg)
      print("evento")
    end,
}

local my_events = {
   tag = {
     ["6S0A182C0002.tag"] = validation["default"],
   },
   plugged = { 
    ["6S0A182C0002.mennekesright.plugged"] = validation["default"],
   },
   pilot = {
    ["6S0A182C0002.mennekesright.pilot"] = validation["number"],
   },
   power = {
    ["6S0A182C0002.mennekesright.power"] = validation["number"]
   }
}


uloop.init()
conn = ubus.connect()
if not conn then
  error("Failed to connect to ubus")
end
conn:listen(my_events[event_name])
uloop.run()


