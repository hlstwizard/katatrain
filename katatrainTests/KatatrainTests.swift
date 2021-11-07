//
//  katatrainTests.swift
//  katatrainTests
//
//  Created by 黄轶明 on 2021/10/11.
//

import XCTest
@testable import katatrain

class KatatrainTests: XCTestCase {
  let katago = Katago()
  
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testGetOpp() throws {
    XCTAssertEqual (katago.getOpp(player: .P_BLACK), PlayerColor.P_WHITE)
    XCTAssertEqual (katago.getOpp(player: .P_WHITE), PlayerColor.P_BLACK)
  }
  
  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
}
