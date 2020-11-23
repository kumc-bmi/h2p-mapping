#!/usr/bin/python3
"""test_queries -- run flagged SHRINE queries using a headless browser

Installation / Configuration
----------------------------

  1. start SHRINE client (for example,
     as from https://github.com/kumc-bmi/shrine-docker-image )
     - start i2b2 with star schema, metadata if necessary
  2. export ACT_ORIGIN to match
  3. run some SHRINE queries
  4. flag some of them in the SHRINE UI
  5. set ACT_USER ACT_PASS to grant this test tool access to log in.
  6. pip install selenium
     - install chromedriver, chrome / chromium, if necessary

Usage
-----

$ python act_test_queries.py
11:44:59 INFO login: Logging in...
11:45:01 INFO find_flagged_queries: Searching for flagged queries...
11:45:07 INFO find_flagged_queries: Found query: 0-9 years old@17:16:35
11:45:24 INFO run_query: Selecting 0-9 years old@17:16:35
11:45:25 INFO run_query: Running 0-9 years old@17:16:35
11:45:31 INFO run_query: 0-9 years old@17:16:35 result: 5,170 ± 10 patients
"""

import logging

from selenium.webdriver import ChromeOptions
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait

log = logging.getLogger(__name__)


def main(argv, environ, sleep, Chrome):
    origin = environ.get('ACT_ORIGIN') or 'http://herondev:8080'
    base = f"{origin}/shrine-api/shrine-webclient/"

    executable_path = environ.get('CHROMEDRIVER') or '/usr/bin/chromedriver'
    driver = Chrome(executable_path=executable_path,
                    options=big_headless('--visible' not in argv,
                                         environ.get('PATH')))
    driver.implicitly_wait(2)
    only = argv[argv.index('--only') + 1] if '--only' in argv else None
    failures = []
    try:
        login(driver, sleep, base, environ['ACT_USER'], environ['ACT_PASS'])
        query_list_by_name = find_flagged_queries(driver, sleep)
        for i in query_list_by_name:
            if only and only not in i:
                log.warn('only running %s; skip %s', only, i)
                continue
            ok = run_query(driver, sleep, i)
            if not ok:
                failures.append(i)
        if failures:
            log.error('failures: %s', failures)
            raise SystemExit(1)
    finally:
        driver.close()
        driver.quit()


def big_headless(invisible=True, PATH=None):
    chrome_options = ChromeOptions()
    # --no-sandbox seems to be necessary in Docker
    # cf https://github.com/joyzoursky/docker-python-chromedriver/blob/master/test_script.py # noqa
    chrome_options.add_argument('--no-sandbox')
    chrome_options.add_argument('--disable-gpu')
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


def find_flagged_queries(driver, sleep):
    log.info("Searching for flagged queries...")

    def by_css(sel):
        wait = WebDriverWait(driver, 10)
        return wait.until(
            EC.element_to_be_clickable((By.CSS_SELECTOR, sel))
        )

    # Dismiss shepherd box
    by_css('button.shepherd-cancel-icon').click()
    sleep(0.5)

    # View results is the 2nd button in the header
    by_css('header button:nth-child(2)').click()

    # wait for list to load
    sleep(3)
    # sort by flags
    by_css('.SortHeader .fa-flag').click()

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

    def by(by, sel):
        wait = WebDriverWait(driver, 10)
        return wait.until(
            EC.element_to_be_clickable((by, sel))
        )

    # assigning to lambda seems find to me. todo: turn off E731
    by_css = lambda sel: by(By.CSS_SELECTOR, sel)  # noqa
    by_xpath = lambda path: by(By.XPATH, path)  # noqa

    by_xpath("//td[contains(text(),'" + i + "')]").click()
    sleep(1)
    # - run query
    # edit button
    log.info("Running " + i)
    by_css('button.details').click()
    sleep(2)
    # topic dropdown
    by_css('.topic-select div').click()
    sleep(1)
    # test topic
    by_xpath("//li[contains(text(),'test')]").click()
    sleep(0.25)
    # run query
    by_css('*.startQueryFormRight button').click()
    # get results
    ok = False
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
                log.error(i + " result: " + highlight(result))
            else:
                ok = True
                log.info(i + " result: " + result)
        except Exception:
            sleep(1)
            continue
        break
    else:
        log.error("Query " + i + " " + highlight("failed to execute"))
    return ok


def highlight(txt):
    return f"\033[93m{txt}\033[0m"


if __name__ == '__main__':
    def _script_io():
        from os import environ
        from time import sleep
        from sys import argv, stderr

        from selenium.webdriver import Chrome

        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s %(levelname)s %(funcName)s: %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S',
            stream=stderr)

        main(argv[:], environ, sleep, Chrome)

    _script_io()
