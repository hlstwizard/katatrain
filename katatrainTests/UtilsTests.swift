//
//  UtilsTests.swift
//  katatrainTests
//
//  Created by Yiming Huang on 2021/12/6.
//

import Foundation


import XCTest
@testable import katatrain

class UtilsTests: XCTestCase {
  
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  
  func testVarToGrid() throws {
    let a = [1,2,3,4,5,6]
    let r1 = var_to_grid(array: a, size: (2, 3))
    XCTAssert(r1[0] == [5,6])
    XCTAssert(r1[1] == [3,4])
    XCTAssert(r1[2] == [1,2])
  }
}
