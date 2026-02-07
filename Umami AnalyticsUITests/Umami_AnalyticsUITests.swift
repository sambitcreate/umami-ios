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
        let app = XCUIApplication()
        app.launch()

        let websitesTab = app.tabBars.buttons["Websites"]
        guard websitesTab.waitForExistence(timeout: 5) else {
            throw XCTSkip("Websites tab not available in current launch state.")
        }
        websitesTab.tap()

        let websiteCell = app.cells.firstMatch
        guard websiteCell.waitForExistence(timeout: 5) else {
            throw XCTSkip("No website list item available for detail smoke test.")
        }
        websiteCell.tap()

        let tabs = ["Overview", "Audience", "Events", "Sessions", "Realtime"]
        for tab in tabs {
            let button = app.buttons[tab]
            if button.waitForExistence(timeout: 5) {
                button.tap()
            } else {
                XCTFail("Missing detail tab button: \(tab)")
            }
        }
    }

    @MainActor
    func testDetailRefreshSmokeWhenDetailAccessible() throws {
        let app = XCUIApplication()
        app.launch()

        let websitesTab = app.tabBars.buttons["Websites"]
        guard websitesTab.waitForExistence(timeout: 5) else {
            throw XCTSkip("Websites tab not available in current launch state.")
        }
        websitesTab.tap()

        let websiteCell = app.cells.firstMatch
        guard websiteCell.waitForExistence(timeout: 5) else {
            throw XCTSkip("No website list item available for detail refresh smoke test.")
        }
        websiteCell.tap()

        let firstElement = app.scrollViews.firstMatch
        guard firstElement.waitForExistence(timeout: 5) else {
            throw XCTSkip("Detail scroll view is not available.")
        }

        firstElement.swipeDown()
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
