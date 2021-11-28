//
//  SGFTests.swift
//  katatrainTests
//
//  Created by 黄轶明 on 2021/11/20.
//

import XCTest
@testable import katatrain

class SgfTests: XCTestCase {
  
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testSgfMoveFromGTP() throws {
    let move = Move.from_gtp(gtp_coords: "A12")
    XCTAssert(move.coord! == (0, 11))
              
    let move1 = Move.from_gtp(gtp_coords: "T19")
    XCTAssert(move1.coord! == (18, 18))
  }
  
  func testSgfMoveFromSGF() throws {
    let move = Move.from_sgf(sgf_coords: "aa", board_size: (19, 19))
    XCTAssert(move.coord! == (0, 0))
  }
  
  func testSgfMoveEqual() throws {
    let move = Move.from_gtp(gtp_coords: "A12")
    let move1 = Move.from_gtp(gtp_coords: "T19")
    
    let move2 = Move(coord: (0, 11), player: "B")
    
    XCTAssert(move != move1)
    XCTAssert(move == move2)
  }
  
  func testSgfToGTP() throws {
    let move = Move.from_sgf(sgf_coords: "aa", board_size: (19, 19))
    XCTAssert(move.gtp() == "A1")
  }
  
  func testSgfLoadFile() throws {
    let bundle = Bundle(for: type(of: self))
    let url = bundle.url(forResource: "test", withExtension: "sgf")
    let root = try! SGF<SgfNode>.parse_file(url: url!)
    
    XCTAssert(root.komi == 6.5)
    let placement = root.placements
    XCTAssert(placement.count == 4)
    XCTAssert(placement[0].coord! == (3, 3))
    XCTAssert(placement[0].player == "B")
    XCTAssert(root.handicap == 4)
    
    let firstNode = root.children[0]
    XCTAssert(firstNode.move!.coord! == (5,2))
    XCTAssert(firstNode.move!.player == "W")
    XCTAssert(firstNode.children.count == 2)
    
    XCTAssert(root.children[0].ruleset == "japanese")
    
    XCTAssert(root.initial_player == "W")
  }
  
  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
}
