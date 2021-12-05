//
//  Game.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/11/24.
//

import Foundation
import Combine
import UIKit

class BaseGame: GameProtocol, ObservableObject {
  @Published var engine: Katago
  @Published var title: String
  @Published var board: [Int]
  
  var root: GameNode
  var currentNode: GameNode
  var gameId: String
  var komi: Float = 6.5
  var handicap: Int = 0
  
  var chains: [[Move]] = []
  var prisoners: [Move] = []
  var lastCapture: [Move] = []
  
  var boardSize: (Int, Int)
  
  var engineCancellable: AnyCancellable? = nil
  
  init(engine: Katago, moveTree: GameNode? = nil, url: URL? = nil) {
    guard !(moveTree != nil && url != nil) else {
      fatalError("can't init game from both node and url")
    }
    self.engine = engine
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
    gameId = formatter.string(from: Date())
    
    if let url = url {
      root = try! SGF<GameNode>.parse_file(url: url)
    } else if let moveTree = moveTree {
      root = moveTree
      komi = moveTree.komi
      handicap = moveTree.handicap
    } else {
      root = GameNode()
    }

    currentNode = root
    title = root.title
    
    boardSize = root.board_size
    board = Array(repeating: -1, count: root.board_size.0 * root.board_size.1)
    
    engineCancellable = engine.objectWillChange.sink { [weak self] (_) in
      self?.objectWillChange.send()
    }
  }
  
  convenience init(engine: Katago, moveTree: GameNode? = nil, sgfFile: String? = nil) {
    let url: URL?
    if let sgfFile = sgfFile {
      url = Bundle.main.url(forResource: sgfFile, withExtension: "sgf")
    } else {
      url = nil
    }
    self.init(engine: engine, moveTree: moveTree, url: url)
  }
  
  func load(url: URL) throws {
    do {
      root = try SGF<GameNode>.parse_file(url: url)
      currentNode = root
      title = root.title
      init_state()
    } catch {
      NSLog("Failed to load: \(url)")
    }
  }
  
  fileprivate func init_state() {
    self.board = Array(repeating: -1, count: boardSize.0 * boardSize.1)
    self.chains = []
    self.prisoners = []
    self.lastCapture = []
  }
  
  fileprivate func calculateGroups() throws {
    self.init_state()
    do {
      for node in self.currentNode.nodes_from_root {
        for m in node.move_with_placements {
          try self.validateMoveAndUpdateChain(move: m, ignore_ko: true)
        }
        
        if !node.clear_placements.isEmpty {
          let clear_coords: Set<Coord> = Set( node.clear_placements.map { $0.coord! } )
          let stones = self.chains.reduce(into: []) {
            result, c in result += c.filter { clear_coords.contains($0.coord!) }
          }
          self.init_state()
          for m in stones {
            try self.validateMoveAndUpdateChain(move: m, ignore_ko: true)
          }
        }
      }
    } catch GameError.IllegalMoveError (let e) {
      throw "Illegal move \(e)"
    }
  }
  
  fileprivate func getLoc(x: Int, y: Int) -> Int {
    return y * boardSize.0 + x
  }
  
  fileprivate func getLoc(move: Move) -> Int {
    return getLoc(x: move.coord!.x, y: move.coord!.y)
  }
  
  fileprivate func validateMoveAndUpdateChain(move: Move, ignore_ko: Bool) throws {
    let sizeX = boardSize.0
    let sizeY = boardSize.1
    let loc = getLoc(x: move.coord!.x, y: move.coord!.y)
    
    let neighbours = { (moves: [Move]) -> Set<Int> in
      var res = Set<Int>()
      for m in moves {
        for delta in [(-1, 0), (1, 0), (0, -1), (0, 1)] {
          let _x = m.coord!.x + delta.0
          let _y = m.coord!.y + delta.1
          if 0 <= _x && _x < sizeX && 0 <= _y && _y < sizeY {
            res.insert(self.board[self.getLoc(x: _x, y: _y)])
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
  
  func play(move: Move, ignore_ko: Bool) throws {
    if !move.is_pass() && !(move.coord!.x >= 0 && move.coord!.y >= 0 && move.coord!.x < boardSize.0 && move.coord!.y < boardSize.1) {
      throw GameError.IllegalMoveError("Move \(move) outside of board coordinates")
    }
    
    do {
      try self.validateMoveAndUpdateChain(move: move, ignore_ko: ignore_ko)
    } catch GameError.IllegalMoveError(let message) {
      try self.calculateGroups()
      throw message
    }
    let node = currentNode.play(move: move) as! GameNode
    currentNode = node
  }
  
  func undo(n_times: UInt = 1) {
    for _ in 1...n_times {
      guard let parent = currentNode.parent else {
        return
      }
      currentNode = parent as! GameNode
      try! calculateGroups()
    }
  }
  
  func redo(n_times: UInt = 1) {
    for _ in 1...n_times {
      if currentNode.children.count == 1 {
        currentNode = currentNode.children[0] as! GameNode
        try! calculateGroups()
      }
    }
  }
  
  func set_current_node(node: GameNode) {
    currentNode = node
    
  }
}

/// Extensions related to analysis etc.
class Game: BaseGame {
  convenience init(engine: Katago) {
    self.init(engine: engine, moveTree: nil, sgfFile: nil)
    
    self.start()
  }
  
  var funcMapping = [
    "new_game": newGame
  ]
  
  var currentPlayer: Character = "B"
  var players: [Character: Player] = ["B": Player("B"), "W": Player("W")]
  var engineQueue = DispatchQueue(label: "engine.result", qos: .utility)
  
  func newGame(moveTree: NodeProtocol? = nil, analyzeFast: Bool = false, sgfFilename: String? = nil) {
    if let moveTree = moveTree {
      root = moveTree as! GameNode
    } else {
      root = GameNode()
    }
    
    currentNode = root
    currentPlayer = root.initial_player
    title = root.title
    init_state()
    
    players["W"]?.type = .ai
  }
  
  func start() {
    engineQueue.async { [weak self] in
      guard let self = self else {
        return
      }
      self.engineLoop()
    }
  }
  
  func play(x: Int, y: Int) throws {
    let move = Move(coord: (x, y), player: currentPlayer)
    try super.play(move: move, ignore_ko: false)
    currentPlayer = move.opponent()
    
    if players[currentPlayer]!.ai {
      engine.requestAnalysis(analysis_node: currentNode)
    }
  }
  
  func engineLoop() {
    while true {
      let result = self.engine.fetchResult()
      if result == nil {
        NSLog("engine loop end")
        break
      }
    }
  }
}
