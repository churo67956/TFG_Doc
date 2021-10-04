import sys
import time
import json
import steve
import globals

exitcode=0

try:
	globals.init()
	#perform and action over a model
	steve.perform(json.loads(sys.argv[1]))
except Exception as e:
	print(e)
	exitcode=1
#if driver is not None:
#	driver.close()
exit(exitcode)
