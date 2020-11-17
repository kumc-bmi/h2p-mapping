#!/usr/bin/python3

import logging

from selenium.webdriver.common.keys import Keys
from selenium.webdriver import ChromeOptions

log = logging.getLogger(__name__)


def main(argv, environ, sleep, Chrome,
         executable_path="./chromedriver"):
    origin = environ.get('ACT_ORIGIN') or 'http://herondev:8080'
    base = f"{origin}/shrine-api/shrine-webclient/"

    driver = Chrome(executable_path=executable_path,
                    options=big_headless('--visible' not in argv))
    only = argv[argv.index('--only') + 1] if '--only' in argv else None
    try:
        login(driver, sleep, base, environ['ACT_USER'], environ['ACT_PASS'])
        query_list_by_name = find_flagged_queries(driver, sleep)
        for i in query_list_by_name:
            if only and only not in i:
                log.warn('only running %s; skip %s', only, i)
                continue
            run_query(driver, sleep, i)
    finally:
        driver.close()
        driver.quit()


def big_headless(invisible=True):
    chrome_options = ChromeOptions()
    if invisible:
        chrome_options.add_argument('--headless')
    # window size matters:
    # `Other element would receive the click: <div class="py-3 Footer"></div>`
    chrome_options.add_argument('--window-size=1920,1080')
    return chrome_options


def login(driver, sleep, base, username, password):
    log.info("Logging in...")
    driver.get(f"{base}#/login")
    user_box = driver.find_element_by_name('username')
    user_box.send_keys(username)
    pass_box = driver.find_element_by_name('password')
    pass_box.send_keys(password)
    pass_box.send_keys(Keys.RETURN)

    # race after login
    sleep(1)

    # on first login, we get some help boxes
    driver.find_element_by_xpath(
        '//*[@id="tippy-1"]/div/div/div/header/button').click()


def find_flagged_queries(driver, sleep):
    log.info("Searching for flagged queries...")
    # ensure we're on the find patients page
    driver.find_element_by_xpath(
        '//*[@id="app"]/header/'
        'div/div[3]/div[1]/div/div/button[2]/span[1]').click()
    # wait for list to load
    sleep(3)
    # sort by flags
    driver.find_element_by_xpath(
        '//*[@id="app"]/div[1]/div[1]/div/div[1]/div/div[2]/'
        'table/thead/tr/th[4]/span/i').click()
    sleep(2)
    flagged_query_list = driver.find_elements_by_xpath(
        "//i[@class='fa fa-flag hover-controls flagged']")

    query_list_by_name = []

    for i in flagged_query_list:
        query_name = i.find_element_by_xpath('..').find_element_by_xpath(
            "../td[@class="
            "'MuiTableCell-root MuiTableCell-body queryHistoryName']").text
        log.info("Found query: " + query_name)
        query_list_by_name.append(query_name)
    return query_list_by_name


def run_query(driver, sleep, i):
    sleep(1)
    log.info("Selecting " + i)
    driver.find_element_by_xpath("//td[contains(text(),'" + i + "')]").click()
    sleep(1)
    # - run query
    # edit button
    log.info("Running " + i)
    driver.find_element_by_xpath(
        '//*[@id="app"]/div[1]/div[1]/div/'
        'div[2]/div[2]/div[1]/div/button').click()
    sleep(2)
    # topic dropdown
    driver.find_element_by_xpath(
        "//div[@class="
        "'MuiInputBase-root MuiInput-root MuiInput-underline topic-select "
        " MuiInputBase-formControl MuiInput-formControl']").click()
    sleep(1)
    # test topic
    driver.find_element_by_xpath("//li[contains(text(),'test')]").click()
    # run query
    driver.find_element_by_xpath(
        '//*[@id="app"]/div[1]/div[1]/div/div[2]/div[2]/div[3]/'
        'div/div[1]/div/div[3]/button').click()
    # get results
    for attempt in range(60):
        try:
            try:
                result = driver.find_element_by_xpath(
                    "//div[@class='PatientCount']").text
            except Exception:
                result = driver.find_element_by_xpath(
                    "//div[@class='SiteError']").text
            if result in ('10 patients or fewer',
                          'Site Error click for details'):
                log.info(i + " result: " + highlight(result))
            else:
                log.info(i + " result: " + result)
        except Exception:
            sleep(1)
            continue
        break
    else:
        log.info("Query " + i + " " + highlight("failed to execute"))


def highlight(txt):
    return f"\033[93m{txt}\033[0m"


if __name__ == '__main__':
    def _script_io():
        from os import environ
        from time import sleep
        from sys import argv, stderr

        from selenium.webdriver import Chrome
        from chromedriver_binary import chromedriver_filename

        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s %(levelname)s %(funcName)s: %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S',
            stream=stderr)

        main(argv[:], environ, sleep, Chrome,
             executable_path=chromedriver_filename)

    _script_io()
