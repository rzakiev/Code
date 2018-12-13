//
//  CompoundUITests.swift
//  CompoundUITests
//
//  Created by Robert Zakiev on 01/07/2018.
//  Copyright © 2018 Robert Zakiev. All rights reserved.
//

import XCTest

class CompoundUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testensureStockListTableExists() {
        let app = XCUIApplication()
        XCTAssert(app.tables["stockListTable"].exists)
    }
    
    func testcheckNavigationTitleInStocksViewController() {
        let app = XCUIApplication()
        XCTAssertTrue(app.navigationBars["Акции"].exists)
        
    }
    
    func testcheckButtonsAndTitleInNavigationBarOfNewStakeController() {
        let app = XCUIApplication()
        let tabBar = app.tabBars["RootTabBar"]
        tabBar.buttons["Портфолио"].tap()
        
        app.navigationBars["Портфолио"].buttons["newStake"].tap()
        sleep(2)
        XCTAssertTrue(app.navigationBars.buttons["cancelStake"].exists)
        XCTAssertTrue(app.navigationBars.buttons["Done"].exists)
        XCTAssertTrue(app.navigationBars["Новая Позиция"].exists)
    }
    
    func testTapRandomCompanyInStockListVC() {
        let app = XCUIApplication()
        let stockListTable = app.tables["stockListTable"]
        XCTAssert(stockListTable.exists)
        
        let randomCell = stockListTable.cells.element(matching: .cell, identifier: "stockListCell01")
        randomCell.tap()
        
    }
    
    
    
    
    
    
    
    
}
