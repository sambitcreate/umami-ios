//
//  Umami_AnalyticsUITests.swift
//  Umami AnalyticsUITests
//
//  Created by Sambit Biswas on 4/17/25.
//

import XCTest

final class Umami_AnalyticsUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }

    private func launchAuthenticatedFixture() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments.append("-uiTestingAuthenticated")
        app.launch()
        return app
    }

    private func tapDetailTab(_ title: String, in app: XCUIApplication) {
        if title == "Realtime" {
            let tabPicker = app.scrollViews["detail-tab-picker"]
            XCTAssertTrue(tabPicker.waitForExistence(timeout: 5), "Missing detail tab picker")
            tabPicker.swipeLeft()
            tabPicker.swipeLeft()
        }

        let button = app.buttons[title]
        XCTAssertTrue(button.waitForExistence(timeout: 5), "Missing detail tab button: \(title)")
        button.tap()
    }

    @MainActor
    func testAppLaunchesAndShowsPrimarySurface() throws {
        let app = XCUIApplication()
        app.launch()

        let dashboardTab = app.tabBars.buttons["Dashboard"]
        let loginLabel = app.staticTexts["Umami Analytics"]

        XCTAssertTrue(dashboardTab.waitForExistence(timeout: 5) || loginLabel.waitForExistence(timeout: 5))
    }

    @MainActor
    func testWebsiteDetailTabSmokeWhenDataAvailable() throws {
        let app = launchAuthenticatedFixture()

        let websitesTab = app.tabBars.buttons["Websites"]
        XCTAssertTrue(websitesTab.waitForExistence(timeout: 5))
        websitesTab.tap()

        let websiteCell = app.cells.firstMatch
        XCTAssertTrue(websiteCell.waitForExistence(timeout: 5))
        websiteCell.tap()

        let tabs = ["Overview", "Audience", "Events", "Sessions", "Realtime"]
        for tab in tabs {
            tapDetailTab(tab, in: app)
        }
    }

    @MainActor
    func testDetailRefreshSmokeWhenDetailAccessible() throws {
        let app = launchAuthenticatedFixture()

        let websitesTab = app.tabBars.buttons["Websites"]
        XCTAssertTrue(websitesTab.waitForExistence(timeout: 5))
        websitesTab.tap()

        let websiteCell = app.cells.firstMatch
        XCTAssertTrue(websiteCell.waitForExistence(timeout: 5))
        websiteCell.tap()

        let firstElement = app.scrollViews.firstMatch
        XCTAssertTrue(firstElement.waitForExistence(timeout: 5))

        firstElement.swipeDown()
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
