from selenium import webdriver
from configparser import ConfigParser

def init():
	global config
	global driver
	config =ConfigParser()
	#load configuration file
	config.read("/home/erik/Documentos/Proyectos/ocpp/ocppv16.conf")
	#open firefox
	driver=webdriver.Firefox()
	#open the login page
	driver.get(config["mainviews"]["login"])
