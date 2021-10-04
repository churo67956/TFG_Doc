#python ocppv16.py '{"model":"operationsv16", "action": "changeavailability", "payload":{"chargepoinlist":"INGE-6S0A182C0002","connectorid":"0","availabilitytype":"OPERATIVE"}}'
#python ocppv16.py '{"model":"operationsv16", "action": "changeconfiguration", "payload":{"chargepoinlist":"INGE-6S0A182C0002","configurationkey":"AuthorizationCacheEnabled (boolean)","value":"true"}}'
#python ocppv16.py '{"model":"operationsv16", "action": "clearcache", "payload":{"chargepoinlist":"INGE-6S0A182C0002"}}'
#python ocppv16.py '{"model":"operationsv16", "action": "getdiagnostics", "payload":{"chargepoinlist":"INGE-6S0A182C0002","location":"http://192.168.0.26","startdatetime":"2021-01-01 12:12","enddatetime":"2021-04-12 00:00"}}'
#TO-DO-TEST
#python ocppv16.py '{"model":"operationsv16", "action": "remotestarttransaction", "payload":{"chargepoinlist":"INGE-6S0A182C0002","connectorid":"0","ocppidtag":"DEADBEEF"}}'
#TO-DO-TEST
#python ocppv16.py '{"model":"operationsv16", "action": "remotestoptransaction", "payload":{"chargepoinlist":"INGE-6S0A182C0002","idactivetransaction":"3"}}'
#python ocppv16.py '{"model":"operationsv16", "action": "reset", "payload":{"chargepoinlist":"INGE-6S0A182C0002","resettype":"SOFT"}}'
#python ocppv16.py '{"model":"operationsv16", "action": "updatefirmware", "payload":{"chargepoinlist":"INGE-6S0A182C0002","location":"http://192.168.","retrivedatetime":""}}'
#python ocppv16.py '{"model":"operationsv16", "action": "reservenow", "payload":{"chargepoinlist":"INGE-6S0A182C0002","connectorid":"1","expirydatetime":"","ocppidtag":"DEADBEEF"}}'
#python ocppv16.py  '{"model":"operationsv16", "action": "cancelreservation", "payload":{"chargepoinlist":"INGE-6S0A182C0002","idexistingreservation":"??"}}'
#data mandatory to submit the form
#python ocppv16.py '{"model":"operationsv16", "action": "datatransfer", "payload":{"chargepoinlist":"INGE-6S0A182C0002","vendorid":"???"}}'
#python ocppv16.py '{"model":"operationsv16", "action": "getconfiguration", "payload":{"chargepoinlist":"INGE-6S0A182C0002","confkeylist":"??"}}'
#python ocppv16.py '{"model":"operationsv16", "action": "getlocallistversion", "payload":{"chargepoinlist":"INGE-6S0A182C0002"}}'
#python ocppv16.py '{"model":"operationsv16", "action": "sendlocallist", "payload":{"chargepoinlist":"INGE-6S0A182C0002","listversion":"1","updatetype":"FULL"}}'
#python ocppv16.py '{"model":"operationsv16", "action": "triggermessage", "payload":{"chargepoinlist":"INGE-6S0A182C0002","configurationkey":"AuthorizationCacheEnabled (boolean)","value":"true"}}'
#python ocppv16.py '{"model":"operationsv16", "action": "getcompositeschedule", "payload":{"chargepoinlist":"INGE-6S0A182C0002","configurationkey":"AuthorizationCacheEnabled (boolean)","value":"true"}}'
#python ocppv16.py '{"model":"operationsv16", "action": "setchargingprofile", "payload":{"chargepoinlist":"INGE-6S0A182C0002","configurationkey":"AuthorizationCacheEnabled (boolean)","value":"true"}}'


