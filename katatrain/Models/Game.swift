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
  var boardSize: (Int, Int)
  
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
    
    self.boardSize = root.board_size
    self.board = Array(repeating: -1, count: root.board_size.0 * root.board_size.1)
  }
  
  private func getLoc(x: Int, y: Int) -> Int {
    return y * boardSize.0 + x
  }
  
  private func validateMoveAndUpdateChain(move: Move, ignore_ko: Bool) throws {
    let sizeX = boardSize.0
    let sizeY = boardSize.1
    
    let neighbours = { (moves: [Move]) -> Set<Int> in
      var res = Set<Int>()
      for m in moves {
        for delta in [(-1, 0), (1, 0), (0, -1), (0, 1)] {
          if 0 <= (m.coord!.0 + delta.0) && (m.coord!.0 + delta.0) < sizeX &&
              0 <= (m.coord!.1 + delta.1) && (m.coord!.0 + delta.0) < sizeY {
            res.insert(self.getLoc(x: m.coord!.1 + delta.1, y: m.coord!.0 + delta.0))
          }
        }
      }
      return res
    }
    
    let koOrSnapback = lastCapture.count == 1 && lastCapture[0] == move
    self.lastCapture = []
    
    if move.is_pass() { return }
    
    if self.getLoc(x: move.coord!.1, y: move.coord!.0) != -1 {
      throw GameError.IllegalMoveError("Space already occupied")
    }
    
    // merge chains connected by this move, or create a new one
    
  }
}
