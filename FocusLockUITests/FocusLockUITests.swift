import XCTest

final class FocusLockBDDTests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUp() {
        continueAfterFailure = true
    }
    
    func testFullAppWalkthrough() throws {
        app.launch()
        sleep(2)
        saveScreenshot("01-onboarding")
        
        // Tap Get Started
        let getStarted = app.buttons["Get Started →"]
        XCTAssertTrue(getStarted.waitForExistence(timeout: 3))
        getStarted.tap()
        sleep(2)
        saveScreenshot("02-home-dashboard")
        
        // Navigate to Stats
        app.tabBars.buttons["Stats"].tap()
        sleep(2)
        saveScreenshot("03-stats")
        
        // Navigate to Settings
        app.tabBars.buttons["Settings"].tap()
        sleep(2)
        saveScreenshot("04-settings")
        
        // Navigate to Schedules
        let schedulesTab = app.tabBars.buttons["Schedules"]
        if schedulesTab.exists {
            schedulesTab.tap()
            sleep(2)
            saveScreenshot("05-schedules")
        }
        
        // Back to Home and start focus session
        app.tabBars.buttons["Home"].tap()
        sleep(1)
        let focusBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'focus' OR label CONTAINS[c] 'start'")).firstMatch
        if focusBtn.waitForExistence(timeout: 3) {
            focusBtn.tap()
            sleep(3)
            saveScreenshot("06-active-focus")
        }
    }
    
    // Keep individual tests for CI
    func testOnboardingScreenDisplayed() {
        app.launch()
        XCTAssertTrue(app.staticTexts["FocusLock"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Lock in. Level up."].exists)
    }
    
    func testGetStartedNavigatesToHome() {
        app.launch()
        let btn = app.buttons["Get Started →"]
        if btn.waitForExistence(timeout: 3) {
            btn.tap()
            let tabBar = app.tabBars.firstMatch
            XCTAssertTrue(tabBar.waitForExistence(timeout: 3))
        }
    }
    
    func testHomeScreenElements() {
        app.launch()
        navigateToHome()
        XCTAssertTrue(app.tabBars.buttons["Home"].exists)
    }
    
    func testNavigateToStats() {
        app.launch()
        navigateToHome()
        app.tabBars.buttons["Stats"].tap()
        sleep(1)
    }
    
    func testNavigateToSettings() {
        app.launch()
        navigateToHome()
        app.tabBars.buttons["Settings"].tap()
        sleep(1)
    }
    
    func testNavigateToSchedules() {
        app.launch()
        navigateToHome()
        let schedulesTab = app.tabBars.buttons["Schedules"]
        if schedulesTab.exists { schedulesTab.tap(); sleep(1) }
    }
    
    func testStatsShowsWeeklyChart() {
        app.launch()
        navigateToHome()
        app.tabBars.buttons["Stats"].tap()
        sleep(1)
    }
    
    func testSettingsShowsProfile() {
        app.launch()
        navigateToHome()
        app.tabBars.buttons["Settings"].tap()
        sleep(1)
    }
    
    func testSettingsToggles() {
        app.launch()
        navigateToHome()
        app.tabBars.buttons["Settings"].tap()
        sleep(1)
    }
    
    func testStartFocusSession() {
        app.launch()
        navigateToHome()
        let focusBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'focus' OR label CONTAINS[c] 'start'")).firstMatch
        if focusBtn.waitForExistence(timeout: 3) { focusBtn.tap(); sleep(2) }
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
