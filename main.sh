set -x
#switches
on_switch=4
ready_switch=6
charge_switch=5
plug_switch=8
#tag uid
uid=DEADBEEF
#buffer
buffer=/tmp/lava_multi_node_cache.txt
#contador de peticiones
request=0
#respuesta del servidor
get_response ()
{
    #aceptada
    local accepted=$(head -n 1 $buffer | awk -F"=" '{ print $2}')
    #vaciar el buffer
    echo "" >> $buffer
    #comprobamos si es aceptada
    [ "$accepted" = "fail" ] && return 1 || return 0
}
#convertir a string pass/fail 
pass_fail ()
{
 [ $1 -eq 0 ] && echo "pass" || echo "fail"
}

quite()
{
 lava-send QUERY-$request query=1
 exit 1
}
#desactivamos la configuracion remota
ubus call  `hostname` set_configuration '{"remote_auth":false}'
#activamos el simulador
lava-send QUERY-$request query=5 rele=$on_switch state=on
lava-wait REPLY-$request
get_response
SWITCH_STATUS=$?
lava-test-case AC-SIMULATOR-ON --result  $(pass_fail $SWITCH_STATUS)
request=$((request + 1))
#[ $SWITCH_STATUS -eq 0 ] || quite

#peticion de pasar tarjeta
lava-send QUERY-$request query=3 uid=$uid
lua /tmp/scripts/carga-sin-ocpp/listenubus.lua tag "{tag_uid=\"$uid\",accepted=\"true\"}"
UID_ACCEPTED=$?
lava-test-case UID-ACCEPTED --result $(pass_fail $UID_ACCEPTED)
request=$((request + 1))
#[ $UID_ACCEPTED -eq 0 ] || quite

#activamos el boton ready del simulador 
lava-send QUERY-$request query=5 rele=$ready_switch state=on
lua /tmp/scripts/carga-sin-ocpp/listenubus.lua pilot '{mennekes_pilot=8}' 2
SWITCH_STATUS=$?
lava-test-case AC-SIMULATOR-READY --result  $(pass_fail $SWITCH_STATUS)
request=$((request + 1))
#[ $SWITCH_STATUS -eq 0 ] || quite

#activamos el boton de resencia de manguera
lava-send QUERY-$request query=5 rele=$plug_switch state=on
lua /tmp/scripts/carga-sin-ocpp/listenubus.lua plugged '{connector="true"}'
SWITCH_STATUS=$?
lava-test-case AC-SIMULATOR-PLUG-ON --result  $(pass_fail $SWITCH_STATUS)
request=$((request + 1))
#[ $SWITCH_STATUS -eq 0 ] || quite

#activamo el bton de charge
lava-send QUERY-$request query=5 rele=$charge_switch state=on
lua /tmp/scripts/carga-sin-ocpp/listenubus.lua pilot '{mennekes_pilot=5}' 2
SWITCH_STATUS=$?
lava-test-case AC-SIMULATOR-CHARGE-ON --result  $(pass_fail $SWITCH_STATUS)
request=$((request + 1))
#[ $SWITCH_STATUS -eq 0 ] || quite

#medimos la potencia
sleep 10
lua /tmp/scripts/carga-sin-ocpp/listenubus.lua power '{power=950}' 100 && POWER_STATUS=0 || POWER_STATUS=1
lava-test-case AC-POWER --result $(pass_fail $POWER_STATUS)
#[ $POWER_STATUS -eq 0 ] || quite  

#desactivamos el boton de charge
lava-send QUERY-$request query=5 rele=$charge_switch state=off
lua /tmp/scripts/carga-sin-ocpp/listenubus.lua pilot '{mennekes_pilot=8}' 2
SWITCH_STATUS=$?
lava-test-case AC-SIMULATOR-CHARGE-OFF --result  $(pass_fail $SWITCH_STATUS)
request=$((request + 1))
#[ $SWITCH_STATUS -eq 0 ] || quite

#sleep 1
#lua /tmp/scripts/carga-sin-ocpp/listenubus.lua power '{power=1}' 1 && POWER_STATUS=0 || POWER_STATUS=1
#lava-test-case AC-NO-POWER --result $(pass_fail $POWER_STATUS)
 
#desactivamos el boton de ready
lava-send QUERY-$request query=5 rele=$ready_switch state=off
lua /tmp/scripts/carga-sin-ocpp/listenubus.lua pilot '{mennekes_pilot=11}' 2
SWITCH_STATUS=$?
lava-test-case AC-SIMULATOR-READY-OFF --result  $(pass_fail $SWITCH_STATUS)
request=$((request + 1))
#[ $SWITCH_STATUS -eq 0 ] || quite

#quitamos la manguera
lava-send QUERY-$request query=5 rele=$plug_switch state=off
lua /tmp/scripts/carga-sin-ocpp/listenubus.lua plugged '{connector="false"}'
SWITCH_STATUS=$?
lava-test-case AC-SIMULATOR-PLUG-OFF --result  $(pass_fail $SWITCH_STATUS)
request=$((request + 1))

quite

