# Generated by Selenium IDE
# pylint: skip-file

import pytest
import time
import json
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.support import expected_conditions
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
from selenium.common.exceptions import NoSuchElementException, ElementClickInterceptedException

class TestKibanatest():
    def setup_method(self, method):  # pylint: disable=unused-argument
        """setup method."""
        chrome_options = Options()
        chrome_options.add_argument("--headless")
        chrome_options.add_argument('--disable-dev-shm-usage')
        chrome_options.add_argument("disable-infobars")
        chrome_options.add_argument("--disable-extensions")
        chrome_options.add_argument("--disable-gpu")
        chrome_options.add_argument("--no-sandbox")
        chrome_options.add_argument('ignore-certificate-errors')

        self.driver = webdriver.Chrome(
            options=chrome_options)  # pylint: disable=attribute-defined-outside-init
        self.driver.implicitly_wait(10)

    def teardown_method(self, method):  # pylint: disable=unused-argument
        """teardown method."""
        self.driver.quit()
  
    def test_kibana(self, params):
        # Navigating to Initial Installation Page
        # testing dashboard, discover, canvas, maps, logs, observability, analytics, ml, stack monitoring of sample data, dev tools and management
        self.driver.get("http://{}:{}/".format(params["server"], params["port"]))
        self.driver.set_window_size(1296, 688)
        # self.driver.implicitly_wait(10)
        time.sleep(20)
        self.driver.find_element(By.XPATH, "//a/span/span").click()
        self.driver.execute_script("window.scrollTo(0,0)")
        element = self.driver.find_element(By.CSS_SELECTOR, ".euiAccordion__buttonContent")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.find_element(By.CSS_SELECTOR, ".euiAccordion__buttonContent").click()
        element = self.driver.find_element(By.CSS_SELECTOR, "body")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.find_element(By.XPATH, "//div/div/div/div[3]/div/div/div/button/span/span").click()
        self.driver.execute_script("window.scrollTo(0,525.3333129882812)")
        self.driver.execute_script("window.scrollTo(0,525.3333129882812)")
        self.driver.find_element(By.XPATH, "//div[2]/div/div/button/span/span/span").click()
        self.driver.find_element(By.XPATH, "//span[contains(.,\'Discover\')]").click()
        self.driver.execute_script("window.scrollTo(0,0)")
        element = self.driver.find_element(By.XPATH, "//li[3]/div/div/div/button")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        element = self.driver.find_element(By.CSS_SELECTOR, "body")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        element = self.driver.find_element(By.XPATH, "//strong[contains(.,\'Empty fields\')]")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        element = self.driver.find_element(By.CSS_SELECTOR, "body")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.find_element(By.CSS_SELECTOR, ".eui-textTruncate > .euiIcon > path").click()
        self.driver.find_element(By.XPATH, "//button[contains(.,\'Last 7 days\')]").click()
        self.driver.find_element(By.XPATH, "//div[4]/div/button").click()
        self.driver.find_element(By.XPATH, "//div[6]/div/button").click()
        self.driver.find_element(By.XPATH, "//li[3]/div/div/div/button/span[2]/span/span").click()
        self.driver.find_element(By.CSS_SELECTOR, ".euiHeaderSectionItem > .euiButtonEmpty path").click()
        self.driver.find_element(By.XPATH, "//span[contains(.,\'Dashboards\')]").click()
        self.driver.find_element(By.XPATH, "//span[contains(.,\'[eCommerce] Revenue Dashboard\')]").click()
        self.driver.execute_script("window.scrollTo(0,117.33333587646484)")
        self.driver.find_element(By.XPATH, "//canvas").click()
        self.driver.execute_script("window.scrollTo(0,302)")
        self.driver.execute_script("window.scrollTo(0,408)")
        self.driver.find_element(By.XPATH, "//div/div/div/div[2]/div/div/div/span/button").click()
        self.driver.find_element(By.XPATH, "//div[2]/div/div[2]/button/span/span").click()
        self.driver.execute_script("window.scrollTo(0,439.3333435058594)")
        self.driver.execute_script("window.scrollTo(0,1411.3333740234375)")
        self.driver.execute_script("window.scrollTo(0,1411.3333740234375)")
        self.driver.execute_script("window.scrollTo(0,1411.3333740234375)")
        self.driver.find_element(By.XPATH, "//div[9]/div[2]/div[2]/div/div/div/div/input").click()
        element = self.driver.find_element(By.XPATH, "//div[7]/button/div/div")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.execute_script("window.scrollTo(0,932)")
        self.driver.find_element(By.XPATH, "//span/button/span").click()
        element = self.driver.find_element(By.CSS_SELECTOR, ".euiSuperUpdateButton .euiIcon")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        element = self.driver.find_element(By.CSS_SELECTOR, "body")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.execute_script("window.scrollTo(0,178)")
        self.driver.execute_script("window.scrollTo(0,1589.3333740234375)")
        self.driver.find_element(By.XPATH, "//div[3]/div[2]/div[2]/div/div/div/div/input").click()
        self.driver.find_element(By.XPATH, "//button[contains(.,\'Refresh\')]").click()
        self.driver.execute_script("window.scrollTo(0,753.3333129882812)")
        self.driver.execute_script("window.scrollTo(0,577.3333129882812)")
        self.driver.find_element(By.CSS_SELECTOR, ".euiHeaderSectionItem > .euiButtonEmpty path").click()
        element = self.driver.find_element(By.CSS_SELECTOR, ".euiHeaderSectionItem > .euiButtonEmpty path")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        element = self.driver.find_element(By.CSS_SELECTOR, "body")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.find_element(By.XPATH, "//span[contains(.,\'Maps\')]").click()
        self.driver.find_element(By.XPATH, "//span[contains(.,\'[eCommerce] Orders by Country\')]").click()
        self.driver.find_element(By.XPATH, "//div[3]/div/div/div/span/button/span/span").click()
        self.driver.find_element(By.XPATH, "//span[contains(.,\'Show this layer only\')]").click()
        self.driver.find_element(By.XPATH, "//button[4]/span").click()
        element = self.driver.find_element(By.XPATH, "//span[contains(.,\'Select dashboard\')]")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.find_element(By.XPATH, "//div[8]/div[2]/div/div[2]/div").click()
        self.driver.find_element(By.XPATH, "//div[4]/button/span").click()
        self.driver.execute_script("window.scrollTo(0,0)")
        self.driver.find_element(By.XPATH, "//div[2]/div/div/button/span").click()
        self.driver.find_element(By.XPATH, "//span[contains(.,\'Machine Learning\')]").click()
        element = self.driver.find_element(By.XPATH, "//div[4]/button/span/span")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        element = self.driver.find_element(By.CSS_SELECTOR, "body")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.find_element(By.XPATH, "//span[contains(.,\'Select data view\')]").click()
        self.driver.execute_script("window.scrollTo(0,0)")
        self.driver.find_element(By.XPATH, "//button[contains(.,\'[eCommerce] Orders\')]").click()
        element = self.driver.find_element(By.XPATH, "//span/button/span")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        element = self.driver.find_element(By.CSS_SELECTOR, "body")
        actions = ActionChains(self.driver)
        actions.move_to_element(element, 0, 0).perform()
        element = self.driver.find_element(By.XPATH, "//div/div/div/div[3]/div/div/button/span/span")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        element = self.driver.find_element(By.CSS_SELECTOR, "body")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.find_element(By.XPATH, "//span[2]").click()
        self.driver.find_element(By.XPATH, "//span[2]").click()
        self.driver.find_element(By.XPATH, "//span[2]").click()
        self.driver.find_element(By.XPATH, "//button[6]/span/span").click()
        self.driver.find_element(By.CSS_SELECTOR, ".euiHeaderSectionItem > .euiButtonEmpty .euiIcon").click()
        self.driver.find_element(By.XPATH, "//div[2]/nav/div/div/div").click()
        self.driver.find_element(By.XPATH, "//a[contains(.,\'Visualize Library\')]").click()
        self.driver.find_element(By.XPATH, "//span[contains(.,\'[eCommerce] Orders by Country\')]").click()
        element = self.driver.find_element(By.XPATH, "//div[5]/div/div/div/span/button/span/span")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        element = self.driver.find_element(By.CSS_SELECTOR, "body")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        element = self.driver.find_element(By.XPATH, "//div/div/button[2]/span")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.find_element(By.XPATH, "//canvas").click()
        self.driver.find_element(By.XPATH, "//canvas").click()
        element = self.driver.find_element(By.XPATH, "//canvas")
        actions = ActionChains(self.driver)
        actions.double_click(element).perform()
        self.driver.find_element(By.XPATH, "//div[2]/div/div/button/span/span/span").click()
        self.driver.find_element(By.XPATH, "//span[contains(.,\'Logs\')]").click()
        element = self.driver.find_element(By.XPATH, "//div[2]/div[2]/div[3]/a/span/span")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        element = self.driver.find_element(By.CSS_SELECTOR, "body")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        element = self.driver.find_element(By.XPATH, "//div[2]/div[2]/div[4]/a/span/span")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.find_element(By.CSS_SELECTOR, ".euiHeaderSectionItem > .euiButtonEmpty path").click()
        self.driver.find_element(By.XPATH, "//span[contains(.,\'Dev Tools\')]").click()
        self.driver.execute_script("window.scrollTo(0,0)")
        self.driver.find_element(By.CSS_SELECTOR, ".euiHeaderSectionItem > .euiButtonEmpty path").click()
        self.driver.find_element(By.XPATH, "//span[contains(.,\'Integrations\')]").click()
        element = self.driver.find_element(By.ID, "azure")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        element = self.driver.find_element(By.CSS_SELECTOR, "body")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.find_element(By.CSS_SELECTOR, ".euiHeaderSectionItem > .euiButtonEmpty path").click()
        self.driver.execute_script("window.scrollTo(0,182)")
        self.driver.find_element(By.LINK_TEXT, "Home").click()
        self.driver.find_element(By.XPATH, "//div[2]/div/div/div/a/span/span").click()
        self.driver.execute_script("window.scrollTo(0,0)")
        element = self.driver.find_element(By.XPATH, "//button[4]/span/span")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.find_element(By.XPATH, "//div[2]/div/div/button/span").click()
        self.driver.find_element(By.XPATH, "//span[contains(.,\'Home\')]").click()
        self.driver.find_element(By.XPATH, "//a/span/span").click()
        self.driver.execute_script("window.scrollTo(0,118)")
        self.driver.find_element(By.XPATH, "//span[contains(.,\'Other sample data sets\')]").click()
        self.driver.find_element(By.XPATH, "//div/div/div/div[3]/div/div/div/button/span/span").click()
        self.driver.execute_script("window.scrollTo(0,526)")
        self.driver.close()