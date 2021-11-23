//
//  Katago.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/10/29.
//

import Foundation
import Combine

class Katago: ObservableObject {
  @Published var initProgress: Double = 0
  @Published var isThinking: Bool = false
  @Published var lastMove: Loc = -1
  
  @Published var canUndo: Bool = false
  @Published var canReplay: Bool = false
  @Published var inTrial: Bool = false
  
  var size_x = 19
  var size_y = 19
  
  var initFinished: Bool {
    initProgress == 1.0
  }
  
  enum Mode {
    case vs
    case analyse
  }
  
  private enum State {
    case suspended
    case resumed
  }
  
  private var state: State = .suspended
  private var analyseQueue: DispatchQueue
  private lazy var fetchResultTimer: DispatchSourceTimer = {
    let queue = DispatchQueue(label: "com.katatrain.result", qos: .utility)
    let t = DispatchSource.makeTimerSource(flags: .strict, queue: queue)
    t.schedule(deadline: .now(), repeating: .seconds(1))
    t.setEventHandler(handler: { [weak self] in
      self?.eventHandler?()
    })
    return t
  }()
  
  func resume() {
    if state == .resumed {
      return
    }
    state = .resumed
    fetchResultTimer.resume()
  }
  
  func suspend() {
    if state == .suspended {
      return
    }
    state = .suspended
    fetchResultTimer.suspend()
  }
  
  var eventHandler: (() -> Void)?
  
  var engine: Engine
  var game: Game
  
  var mode: Mode = .vs
  var player: PlayerColor = .P_BLACK
  var appendingResults: Set<String> = []
  var potentialStones: Set<Loc> = []
  var running: Bool = false
  
  init() {
    engine = Engine.init("Katagob40", "analysis_example")
    game = Game.init("tromp-taylor")
    analyseQueue = DispatchQueue(label: "com.katatrain.analyse", qos: .utility)
    
    analyseQueue.async { [weak self] in
      guard let self = self else { return }
      self.engine.runLoop()
    }
    eventHandler = self.fetchResultHandle
    fetchResultTimer.activate()
    state = .resumed
  }
  
  func getOpp(player: PlayerColor) -> PlayerColor {
    return PlayerColor(rawValue: player.rawValue ^ 3)!
  }
  
  deinit {
    fetchResultTimer.setEventHandler {}
    fetchResultTimer.cancel()
    resume()
    eventHandler = nil
  }
  
  func request_analysis(action: String? = nil) {
    let id = UUID().uuidString
    appendingResults.insert(id)
    isThinking = true
    
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      guard let self = self else { return }
      if let action = action {
        self.engine.addInputRequest("{\"id\":\"\(id)\",\"action\":\"\(action)\"}")
      } else {
        let request = self.game.toRequestJson(id)
        NSLog(request)
        self.engine.addInputRequest(request)
      }
    }
  }
  
  static func get_rules(ruleset: String) -> String {
    let RULESET = [
      "jp": "japanese",
      "cn": "chinese",
      "ko": "korean",
      "aga": "aga",
      "tt": "tromp-taylor",
      "nz": "new zealand",
      "stone_scoring": "stone_scoring"
    ]
    
    if let result = RULESET[ruleset] {
      return result
    } else if RULESET.values.contains(ruleset) {
      return ruleset
    } else {
      return "japanese"
    }
  }
  
  func request_analysis(analysis_node: NodeProtocol) {
    let nodes = analysis_node.nodes_from_root
    
    let moves = nodes.reduce(into: []) { result, nextNode in
      if let move = nextNode.move {
        result.append(move)
      }
    }
    
    let initial_stones = nodes.reduce(into: []) { result, nextNode in
      _ = nextNode.placement.map {
        result.append($0)
      }
    }
    
    let query: [String: Any] = [
      "rules": Katago.get_rules(ruleset: analysis_node.ruleset),
      "analyzeTurns": [moves.count],
      "komi": analysis_node.komi,
      "boardXSize": size_x,
      "boardYSize": size_y
      
    ]
  }
  
  func getColors() -> [NSNumber] {
    return game.getColors().compactMap({ $0 as? NSNumber })
  }
  
  func fetchResultHandle() {
    let result = self.engine.fetchResult()
    if !result.isEmpty {
      if let data = result.data(using: String.Encoding.utf8) {
        do {
          let parsedResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
          if let engineInitProcess = parsedResult?["initProcess"] {
            DispatchQueue.main.async { [unowned self] in
              self.initProgress = engineInitProcess as! Double
            }
            return
          }
          if let id = parsedResult?["id"]! as? String {
            if let error = parsedResult?["error"] as? String {
              NSLog("Query result \(id) error -- \(error)")
              return
            }
            if !appendingResults.contains(id) {
              NSLog("Query result \(id) discarded -- recent new game or node reset?")
              return
            }
            NSLog("Get result of \(id)")
            let moveInfos = parsedResult?["moveInfos"] as! [Any]
            let topMoveInfo = moveInfos[0] as! [String: Any]
            var loc: Loc = 0
            
            // pointer from objective-c++
            let result = withUnsafeMutablePointer(to: &loc) {
              Game.tryLoc(of: topMoveInfo["move"] as! String, $0, 19, 19)
            }
            
            if !result {
              NSLog("Failed to parse loc \(String(describing: topMoveInfo["move"]))")
            }
            let opp = Player(getOpp(player: player).rawValue)
            
            DispatchQueue.main.async { [unowned self] in
              self.isThinking = false
              game.makeMove(loc, opp)
              lastMove = game.getLastMove().int16Value
            }
            appendingResults.remove(id)
            
          }
        } catch {
          NSLog(error.localizedDescription)
        }
      }
    }
  }
  
  func play(loc: Loc, player: PlayerColor = .P_BLACK) {
    game.makeMove(loc, Int8(player.rawValue))
    lastMove = game.getLastMove().int16Value
    canUndo = true
    if player == .P_BLACK {
      request_analysis()
    }
  }
  
  func undo() {
    canUndo = game.undo()
    canReplay = true
    lastMove = game.getLastMove().int16Value
  }
  
  func replay() {
    canReplay = game.replay()
    canUndo = true
    lastMove = game.getLastMove().int16Value
  }
  
  func reset() {
    game.reset()
    lastMove = game.getLastMove().int16Value
  }
  
  func newGame(handicap: UInt8) {
    game.newGame(handicap)
    if handicap > 0 {
      request_analysis()
    }
    objectWillChange.send()
  }
  
  func enterTrial() {
    game.enterTrial()
    canUndo = false
    canReplay = false
    inTrial = true
  }
  
  func exitTrial() {
    game.exitTrial()
    inTrial = false
  }
}
