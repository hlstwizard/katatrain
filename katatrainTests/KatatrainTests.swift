//
//  katatrainTests.swift
//  katatrainTests
//
//  Created by 黄轶明 on 2021/10/11.
//

import XCTest
import Combine
@testable import katatrain

class KatatrainTests: XCTestCase {
  let katago = Katago()
  
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testSendingAnalysisRequest() throws {
    let bundle = Bundle(for: type(of: self))
    let url = bundle.url(forResource: "test", withExtension: "sgf")
    let root = try! SGF<SgfNode>.parse_file(url: url!)
    
    let queue = DispatchQueue(label: "KatagoEngineTests")
    
    // Wait for katago init
    sleep(5)
    
    katago.requestAnalysis(analysis_node: root as! GameNode, queue: queue)
    XCTAssert(!katago.isIdle)
    
    queue.sync { }
    
    while !katago.isIdle {
      sleep(1)
    }
  }
  
  func testQueryVersion() throws {
    let queue = DispatchQueue(label: "KatagoEngineTests")
    
    // Wait for katago init
    sleep(5)
    
    katago.getKatagoVersion(queue: queue)
    queue.sync { }
  }
  
  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
}
