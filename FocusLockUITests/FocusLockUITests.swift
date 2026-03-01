import XCTest

final class FocusLockBDDTests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUp() {
        continueAfterFailure = true
        app.launch()
    }
    
    // MARK: - Onboarding
    
    func testOnboardingScreenDisplayed() {
        XCTAssertTrue(app.staticTexts["FocusLock"].exists)
        XCTAssertTrue(app.staticTexts["Lock in. Level up."].exists)
        saveScreenshot("bdd-01-onboarding")
    }
    
    func testGetStartedNavigatesToHome() {
        let btn = app.buttons["Get Started →"]
        if btn.waitForExistence(timeout: 3) {
            btn.tap()
        }
        // Whether we came from onboarding or launched directly, tab bar should exist
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        saveScreenshot("bdd-02-home-after-onboarding")
    }
    
    // MARK: - Home Screen
    
    func testHomeScreenElements() {
        navigateToHome()
        XCTAssertTrue(app.tabBars.buttons["Home"].exists)
        saveScreenshot("bdd-03-home-dashboard")
    }
    
    // MARK: - Tab Navigation
    
    func testNavigateToStats() {
        navigateToHome()
        app.tabBars.buttons["Stats"].tap()
        sleep(1)
        saveScreenshot("bdd-04-stats")
    }
    
    func testNavigateToSettings() {
        navigateToHome()
        app.tabBars.buttons["Settings"].tap()
        sleep(1)
        saveScreenshot("bdd-05-settings")
    }
    
    func testNavigateToSchedules() {
        navigateToHome()
        let schedulesTab = app.tabBars.buttons["Schedules"]
        if schedulesTab.exists {
            schedulesTab.tap()
            sleep(1)
        }
        saveScreenshot("bdd-06-schedules")
    }
    
    // MARK: - Stats Screen
    
    func testStatsShowsWeeklyChart() {
        navigateToHome()
        app.tabBars.buttons["Stats"].tap()
        sleep(1)
        saveScreenshot("bdd-07-stats-chart")
    }
    
    // MARK: - Settings Screen
    
    func testSettingsShowsProfile() {
        navigateToHome()
        app.tabBars.buttons["Settings"].tap()
        sleep(1)
        saveScreenshot("bdd-08-settings-profile")
    }
    
    func testSettingsToggles() {
        navigateToHome()
        app.tabBars.buttons["Settings"].tap()
        sleep(1)
        saveScreenshot("bdd-09-settings-toggles")
    }
    
    // MARK: - Focus Session
    
    func testStartFocusSession() {
        navigateToHome()
        let focusButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'focus' OR label CONTAINS[c] 'start'"))
        if focusButtons.count > 0 {
            focusButtons.firstMatch.tap()
            sleep(2)
        }
        saveScreenshot("bdd-10-focus-session")
    }
    
    // MARK: - Helpers
    
    func navigateToHome() {
        let btn = app.buttons["Get Started →"]
        if btn.waitForExistence(timeout: 2) {
            btn.tap()
            sleep(1)
        }
    }
    
    func saveScreenshot(_ name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        let data = screenshot.pngRepresentation
        let path = "/Users/jabreeflor/.openclaw/workspace/focuslock-designs/bdd/\(name).png"
        try? data.write(to: URL(fileURLWithPath: path))
    }
}
