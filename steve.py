import time
import globals
from selenium.webdriver.common.keys import Keys
from selenium.webdriver import ActionChains
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import Select

def anyrow(xpath):
	results= globals.driver.find_elements_by_xpath(xpath+"/tr")
	return len(results)

def getelementtag(xpath):
	element=globals.driver.find_element_by_xpath(xpath)
	outerhtml = element.get_attribute('outerHTML')
	tag_value=outerhtml.split(' ',1)[0][1:]
	print(tag_value)
	if ( tag_value == "input"  or  tag_value == "textarea" ):
		return 1
	elif ( tag_value == "select" ):
		return 2

def fillform(xpaths,payload):
	for key in payload:
		tag_element=getelementtag(xpaths[key])
		element=globals.driver.find_element_by_xpath(xpaths[key])
		if tag_element == 1:
			element.send_keys('')
			element.send_keys(payload[key])
			if 'dateTimePicker' in element.get_attribute('class').split():
				print(key)
				element.send_keys(Keys.ENTER)
				time.sleep(1)
		elif tag_element == 2:
			Select(element).select_by_visible_text(payload[key])
	globals.driver.find_element_by_xpath(xpaths["perform"]).click()

def gotohomeview():
	time.sleep(3)
	globals.driver.find_element_by_xpath(globals.config["mainviews"]["home"]).click()	
	print("tohome")

def gotochargepointsview():
	gotohomeview()
	globals.driver.find_element_by_xpath(globals.config["mainviews"]["chargepoints"]).click()

def gotoaddnewcpview():
	gotochargepointsview()
	globals.driver.find_element_by_xpath(globals.config["chargepointsview"]["addnew"]).click()

def gotoocpptagsview():
	gotohomeview()
	globals.driver.find_element_by_xpath(globals.config["mainviews"]["ocpptags"]).click()

def gotoaddnewotview():
	gotoocpptagsview()
	globals.driver.find_element_by_xpath(globals.config["addnewotview"]["addnew"]).click()

def gotooperationsv16view(view):
	gotohomeview()	
  	operationsmenu = globals.driver.find_element_by_xpath(globals.config["mainviews"]["operations"])
  	actions = ActionChains(globals.driver)
  	actions.move_to_element(operationsmenu).perform()
	wait = WebDriverWait(globals.driver, 3) 
  	wait.until(EC.element_to_be_clickable((By.XPATH,globals.config["operationsview"]["ocppv16"]))).click()
	globals.driver.find_element_by_xpath(view).click()	
	#wait to popule select options
	#time.sleep(10)
def debug(data):
	print(data)

def login():
	fillform(globals.config["loginview"],globals.config["login"])
	

def any_model(payload,query):
	view=config[payload.model+"view"]
	fillform(view,query)
	globals.drive.find_element_by_xpath(view["perform"]).click()
	time.sleep(10)
	results= any_results(view.results)
	return results

def perform(payload):
	print(payload)
	#login to steve
	login()
	if (payload["model"] == "chargepoints" or payload["model"] == "ocpptags") and (payload["action"] == "add" or payload["action"] == "delete"):
		if payload["model"] == "chargepoints":
			query={"chargeboxid":payload["payload"]["chargeboxid"],"ocppversion":payload["payload"]["ocppversion"]}
		elif payload.model == "ocpptags":
			query={"idtag":payload["payload"]["idtag"],"expired":"All","blocked":"All"}
		results = any_model(payload,query)
		if payload["action"] == "add" :
			#check if no exits add
			if results == 0:
				if  payload.model == "chargepoints":
					gotoaddnewcpview()
					fillform(config["addnewcpview"],payload.payload)
				elif payload.model == "ocpptags":
					gotoaddnewotview()
					fillform(config["addnewotview"],payload.payload)
		elif payload.action == "delete":
			if results == 1:
				if payload.model == "chargepoints":
					driver.find_element_by_xpath(config["chargepointsview"].results+"/tr/td[5]/form/input").click()
				elif payload.model == "ocpptags":
					driver.find_element_by_xpath(config["ocpptagsview"].results+"/tr/td[5]/form/input").click()
	elif payload["model"] == "operationsv16":
		debug("operationv16")
		gotooperationsv16view(globals.config["ocppv16views"][payload["action"]])
		fillform(globals.config[payload["action"]+"view"],payload["payload"])
	else:
		print("ERROR" + payload.model)
