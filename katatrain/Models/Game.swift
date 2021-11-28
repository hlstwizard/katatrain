//
//  Game.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/11/24.
//

import Foundation

class BaseGame: GameProtocol {
  
  let engine: Katago
  var root: GameNode
  var currentNode: GameNode
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

    currentNode = root
    
    boardSize = root.board_size
    board = Array(repeating: -1, count: root.board_size.0 * root.board_size.1)
  }
  
  private func init_state() {
    self.board = Array(repeating: -1, count: boardSize.0 * boardSize.1)
    self.chains = []
    self.prisoners = []
    self.lastCapture = []
  }
  
  private func calculateGroups() throws {
    self.init_state()
    for node in self.currentNode.nodes_from_root {
      for m in node.move_with_placements {
        do {
          try self.validateMoveAndUpdateChain(move: m, ignore_ko: true)
        } catch GameError.IllegalMoveError (let e) {
          throw "Illegal move \(e)"
        }
      }
      
    }
  }
  
  private func getLoc(x: Int, y: Int) -> Int {
    return y * boardSize.0 + x
  }
  
  private func getLoc(move: Move) -> Int {
    return getLoc(x: move.coord!.0, y: move.coord!.1)
  }
  
  private func validateMoveAndUpdateChain(move: Move, ignore_ko: Bool) throws {
    let sizeX = boardSize.0
    let sizeY = boardSize.1
    let loc = getLoc(x: move.coord!.0, y: move.coord!.1)
    
    let neighbours = { (moves: [Move]) -> Set<Int> in
      var res = Set<Int>()
      for m in moves {
        for delta in [(-1, 0), (1, 0), (0, -1), (0, 1)] {
          if 0 <= (m.coord!.0 + delta.0) && (m.coord!.0 + delta.0) < sizeX &&
              0 <= (m.coord!.1 + delta.1) && (m.coord!.0 + delta.0) < sizeY {
            res.insert(self.board[self.getLoc(x: m.coord!.1 + delta.1, y: m.coord!.0 + delta.0)])
          }
        }
      }
      return res
    }
    
    let koOrSnapback = lastCapture.count == 1 && lastCapture[0] == move
    self.lastCapture = []
    
    if move.is_pass() { return }
    
    if self.board[loc] != -1 {
      throw GameError.IllegalMoveError("Space already occupied")
    }
    
    // merge chains connected by this move, or create a new one
    let nb_chains = Array(neighbours([move]).filter { $0 >= 0 && self.chains[$0][0].player == move.player })
    var this_chain: Int
    if nb_chains.isEmpty {
      this_chain = self.chains.count
      self.chains.append([move])
    } else {
      this_chain = nb_chains[0]
      for i in 0..<self.board.count {
        let sq = self.board[i]
        if nb_chains.contains(sq) {
          self.board[i] = this_chain
        }
      }
      
      for oc in nb_chains[1...] {
        self.chains[this_chain] += self.chains[oc]
        // Keep the chain for undo/redo
        self.chains[oc] = []
      }
      self.chains[this_chain].append(move)
    }
    self.board[loc] = this_chain
    
    // check captures
    let opp_nb_chains = neighbours([move]).filter { $0 >= 0 && self.chains[$0][0].player != move.player }
    for c in opp_nb_chains {
      // no liberties
      if !neighbours(self.chains[c]).contains(-1) {
        self.lastCapture += self.chains[c]
        for om in self.chains[c] {
          self.board[getLoc(move: om)] = -1
        }
        self.chains[c] = []
      }
    }
    if koOrSnapback && self.lastCapture.count == 1 && !ignore_ko {
      throw GameError.IllegalMoveError("Ko")
    }
    self.prisoners += self.lastCapture
    
    if !neighbours(self.chains[this_chain]).contains(-1) {
      throw GameError.IllegalMoveError("Suicide")
    }
  }
  
  func play(move: Move, ignore_ko: Bool) {
    
  }
  
  func undo(n_times: UInt = 1) {
    
  }
  
  func redo(n_times: UInt) {
    
  }
  
  func set_current_node(node: GameNode) {
    currentNode = node
    
  }
}
