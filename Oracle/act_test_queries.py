#!/usr/bin/python3

import os
import time

from selenium import webdriver
from selenium.webdriver.common.keys import Keys

chrome_options = webdriver.ChromeOptions()
chrome_options.add_argument('--headless')
# window size matters:
# `Other element would receive the click: <div class="py-3 Footer"></div>`
chrome_options.add_argument('--window-size=1920,1080')
driver = webdriver.Chrome(executable_path="./chromedriver", options=chrome_options)

#login
print("Logging in...")
driver.get("http://herondev:8080/shrine-api/shrine-webclient/#/login")
user_box = driver.find_element_by_name('username')
user_box.send_keys(os.environ['ACT_USER'])
pass_box = driver.find_element_by_name('password')
pass_box.send_keys(os.environ['ACT_PASS'])
pass_box.send_keys(Keys.RETURN)

# race after login
time.sleep(1)

# on first login, we get some help boxes
driver.find_element_by_xpath('//*[@id="tippy-1"]/div/div/div/header/button').click()

print("Searching for flagged queries...")
# ensure we're on the find patients page
driver.find_element_by_xpath('//*[@id="app"]/header/div/div[3]/div[1]/div/div/button[2]/span[1]').click()
# wait for list to load
time.sleep(3)
# sort by flags
driver.find_element_by_xpath('//*[@id="app"]/div[1]/div[1]/div/div[1]/div/div[2]/table/thead/tr/th[4]/span/i').click()
time.sleep(2)
flagged_query_list = driver.find_elements_by_xpath("//i[@class='fa fa-flag hover-controls flagged']")

query_list_by_name = []

for i in flagged_query_list:
    query_name = i.find_element_by_xpath('..').find_element_by_xpath("../td[@class='MuiTableCell-root MuiTableCell-body queryHistoryName']").text
    print("Found query: " + query_name)
    query_list_by_name.append(query_name)

for i in query_list_by_name:
    time.sleep(1)
    print("Selecting " + i)
    driver.find_element_by_xpath("//td[contains(text(),'" + i + "')]").click()
    time.sleep(1)
    ## run query
    # edit button
    print("Running " + i)
    driver.find_element_by_xpath('//*[@id="app"]/div[1]/div[1]/div/div[2]/div[2]/div[1]/div/button').click()
    time.sleep(2)
    # topic dropdown
    driver.find_element_by_xpath("//div[@class='MuiInputBase-root MuiInput-root MuiInput-underline topic-select  MuiInputBase-formControl MuiInput-formControl']").click()
    time.sleep(1)
    # test topic
    driver.find_element_by_xpath("//li[contains(text(),'test')]").click()
    # run query
    driver.find_element_by_xpath('//*[@id="app"]/div[1]/div[1]/div/div[2]/div[2]/div[3]/div/div[1]/div/div[3]/button').click()
    # get results
    for attempt in range(60):
        try:
            try:
                result=driver.find_element_by_xpath("//div[@class='PatientCount']").text
            except:
                result=driver.find_element_by_xpath("//div[@class='SiteError']").text
            if result in ('10 patients or fewer', 'Site Error click for details'):
                print(i + " result: \033[93m" + result + "\033[0m")
            else:
                print(i + " result: " + result)
        except:
            time.sleep(1)
            continue
        break
    else:
        print("Query " + i + " \033[93mfailed to execute\033[0m")

driver.close()
