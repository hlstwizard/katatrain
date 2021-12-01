//
//  GameTests.swift
//  katatrainTests
//
//  Created by Yiming Huang on 2021/12/1.
//

import XCTest
@testable import katatrain

class GameTests: XCTestCase {
  let game = Game(engine: Katago(), moveTree: {
    let bundle = Bundle(for: GameTests.self)
    let url = bundle.url(forResource: "capture", withExtension: "sgf")
    return try! SGF<GameNode>.parse_file(url: url!)
  }())
  
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  
  func testSgfCapture() throws {
    game.redo(n_times: 6)
    
    let child = game.currentNode.children[0]
    XCTAssert( child.children.isEmpty == true )
    XCTAssert( child.move!.player == "B" )
    XCTAssert( child.move!.coord! == (3,1) )
    
    // Capture
    game.redo()
    XCTAssert( game.lastCapture.isEmpty == false )
    XCTAssert( game.lastCapture[0].coord! == (3, 2) )
  }
  
}
