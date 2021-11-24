//
//  Game.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/11/24.
//

import Foundation

open class BaseGame {
  let engine: Katago
  var root: GameNode
  var gameId: String
  var komi: Float = 6.5
  var handicap: Int = 0
  
  var chains: [[Move]] = []
  var prisoners: [Move] = []
  var lastCapture: [Move] = []
  
  var board: [Int]
  
  init(engine: Katago, moveTree: GameNode? = nil) {
    self.engine = engine
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
    gameId = formatter.string(from: Date())
    
    if let moveTree = moveTree {
      root = moveTree
      komi = moveTree.komi
      handicap = moveTree.handicap
    } else {
      root = GameNode()
    }
    
    self.board = Array(repeating: -1, count: root.board_size.0 * root.board_size.1)
  }
}
