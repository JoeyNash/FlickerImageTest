//
//  FlickerImageTestTests.swift
//  FlickerImageTestTests
//
//  Created by Joseph Nash on 6/6/24.
//

import XCTest
@testable import FlickerImageTest

class FlickerImageTestTests: XCTestCase {

  func testGetIntValue() {
    let testString1 = "src=\"https://live.staticflickr.com/65535/53773511579_b20fc17c39_m.jpg\" width=\"192\" height=\"240\" alt=\"Fledged Barred Owlet\""
    let testString2 = "src=\"https://live.staticflickr.com/65535/53773460309_0accceb77b_m.jpg\" width=\"180\" height=\"180\""
    XCTAssertEqual(192, testString1.getIntValue(forKey: "width") ?? -1)
    XCTAssertEqual(240, testString1.getIntValue(forKey: "height") ?? -1)
    XCTAssertEqual(180, testString2.getIntValue(forKey: "width") ?? -1)
    XCTAssertEqual(180, testString2.getIntValue(forKey: "height") ?? -1)
  }

}
