require "ubus"
require "uloop"

params = { ... }
-- evento a escuchar                                                                                                                                                                                                                                                                                                      
event_name = params[1]
--- validador
validator = params[2]
-- el patron a compara con la lectura real                                                                                                                                                                                                                                                                                
loadstring("target="..params[3])()
-- para los numericos un error permitido                                                                                                                                                                                                                                                                                  
error = params[4]
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

---  ["right.plug"] = { ["6S0A182C0002.mennekesright.plugged"] = validation["default"], },
--- ["right.pilot"] = { ["6S0A182C0002.mennekesright.pilot"] = validation["number"],},
--- ["right.power"] = { ["6S0A182C0002.mennekesright.power"] = validation["number"] },
--- ["left.plug"] = { ["6S0A182C0002.mennekesleft.plugged"] = validation["default"],},
--- ["left.pilot"] = { ["6S0A182C0002.mennekesleft.pilot"] = validation["number"],},
--- ["left.power"] = { ["6S0A182C0002.mennekesright.power"] = validation["number"]}

local my_event = {
  [event_name] = validation[validator]
}

uloop.init()
conn = ubus.connect()
if not conn then
  error("Failed to connect to ubus")
end
conn:listen(my_event)
uloop.run()


