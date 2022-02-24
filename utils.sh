main() {
 #CONFIGURACION
 lava-sync $test_id-start
 STEP=-1
 if [ -z "$1" ]
 then
   rc=1
 else
  transaction "$1"
  rc=$?
 fi
 lava-send $test_id-req-$msg 'res={"action":"end"}'
 lava-sync $test_id-end
 return $rc
}

wait_transaction() {
    local resp; local code; local max_time
    [ -n "$3" ] && max_time=$3 || max_time=120
    non_blocking_wait $1
    code=$?
    case $code in 
     100)
       lava-send $test_id-req-$msg "$2" 
       lava-wait $test_id-rep-$msg
       msg=$(( $msg + 1 ))
       resp=$(tail -n 1 $buffer | awk -F'=' '{print $2}' | jsonfilter -e '@.result')
       if [[ $resp == "fail" ]]
       then
          kill $1
          return 1
       else
         SECONDS=0
         while :
         do
            if [ $SECONDS -gt $max_time ]
            then
              kill $1
              return 1
            fi
            non_blocking_wait $1
            code=$?
            if [ $code -ne 100 ]
            then
               return $code 
            fi
            sleep 1
         done
         sleep 15
       fi
     ;;
     *)
      return 1
     ;;
     esac
}

non_blocking_wait() {
 if [ ! -d "/proc/$1" ]
 then
  wait $1
  return $?
 else
  return 100
 fi
}


transaction() {
    local state;local uid;local rele;local name; local connector="$1"
    STEP=0
    name=$(jsonfilter -s "$connector" -e '@.name')
    ubus call  `hostname` set_configuration '{"remote_auth":false}'
    state=$(ubus call `hostname` get_status | jsonfilter -e  '@.'$name'.state')
    [[ "$state" != "available" ]] && return 1
    rele=$(jsonfilter -s "$connector" -e '@.simacgnd')
    lava-send $test_id-req-$msg 'res={"action":"ready","state":"on","rele":"'$rele'"}'
    lava-wait $test_id-rep-$msg
    msg=$(( $msg + 1 ))
    resp=$(tail -n 1 $buffer | awk -F'=' '{print $2}' | jsonfilter -e '@.result')
    [[ "$resp" == "fail" ]] && return 1
    #start transaction
    STEP=1
    uid=$(jsonfilter -s "$connector" -e '@.tag')
    lua "$TEST_SUITES_ROOT_PATH/$TEST_SUITE/utils_dut1/listenubus.lua" `hostname`.tag "default" "{tag_uid=\"$uid\",accepted=\"true\"}" &
    wait_transaction $! 'res={"action":"emulate_tag","tag":"'$uid'"}' || return 1
    #on btn
    STEP=2
    rele=$(jsonfilter -s "$connector" -e '@.simacon')
    lua $TEST_SUITES_ROOT_PATH/$TEST_SUITE/utils_dut1/listenubus.lua `hostname`.$name.pilot "number" '{mennekes_pilot=8}' 2 &
    wait_transaction $! 'res={"action":"onoff","state":"on","rele":"'$rele'"}' || return 1
    #on btn
    STEP=3
    rele=$(jsonfilter -s "$connector" -e '@.simacplug')
    lua $TEST_SUITES_ROOT_PATH/$TEST_SUITE/utils_dut1/listenubus.lua `hostname`.$name.plugged "default" '{connector="true"}' &
    wait_transaction $! 'res={"action":"onoff","state":"on","rele":"'$rele'"}' || return 1
    #cha btn
    STEP=4
    rele=$(jsonfilter -s "$connector" -e '@.simaccha')
    lua $TEST_SUITES_ROOT_PATH/$TEST_SUITE/utils_dut1/listenubus.lua `hostname`.$name.pilot "number" '{mennekes_pilot=5}' 2 &
    wait_transaction $! 'res={"action":"onoff","state":"on","rele":"'$rele'"}' || return 1
    #valid power
    STEP=5
    sleep 30
    maxpower=$(jsonfilter -s "$connector" -e '@.maxpower')
    lua $TEST_SUITES_ROOT_PATH/$TEST_SUITE/utils_dut1/listenubus.lua `hostname`.$name.power "number" '{power='"$maxpower"'}' 50 || return 1
    #end transaction
    STEP=6
    lua $TEST_SUITES_ROOT_PATH/$TEST_SUITE/utils_dut1/listenubus.lua `hostname`.tag "default" "{tag_uid=\"$uid\",accepted=\"true\"}" &
    wait_transaction $! 'res={"action":"emulate_tag","tag":"'$uid'"}' || return 1
    sleep 45
    #cha btn
    STEP=7
    rele=$(jsonfilter -s "$connector" -e '@.simaccha')
    lua $TEST_SUITES_ROOT_PATH/$TEST_SUITE/utils_dut1/listenubus.lua `hostname`.$name.pilot "number" '{mennekes_pilot=8}' 2 &
    wait_transaction $! 'res={"action":"onoff","state":"off","rele":"'$rele'"}' || return 1
    #on btn
    STEP=8
    rele=$(jsonfilter -s "$connector" -e '@.simacon')
    lua $TEST_SUITES_ROOT_PATH/$TEST_SUITE/utils_dut1/listenubus.lua `hostname`.$name.pilot "number" '{mennekes_pilot=12}' 2 &
    wait_transaction $! 'res={"action":"onoff","state":"off","rele":"'$rele'"}' || return 1
    #plug btn
    STEP=9
    rele=$(jsonfilter -s "$connector" -e '@.simacplug')
    lua $TEST_SUITES_ROOT_PATH/$TEST_SUITE/utils_dut1/listenubus.lua `hostname`.$name.plugged "default" '{connector="false"}' &
    wait_transaction $! 'res={"action":"onoff","state":"off","rele":"'$rele'"}' || return 1
    return 0
}
