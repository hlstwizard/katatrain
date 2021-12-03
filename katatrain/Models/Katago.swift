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
  @Published var isIdle: Bool = false
  
  var queryCounter = 0
  var analysisResult: [String] = []
  
  var size_x = 19
  var size_y = 19
  
  var initFinished: Bool {
    initProgress == 1.0
  }

  private var analyseQueue: DispatchQueue
  
  var engine: Engine
  var appendingResults: Set<String> = []
  var running: Bool = false
  
  init() {
    engine = Engine.init("Katagob40", "analysis_example")
    analyseQueue = DispatchQueue(label: "com.katatrain.analyse", qos: .utility)
    
    analyseQueue.async { [weak self] in
      guard let self = self else { return }
      self.engine.runLoop()
    }
  }
  
  deinit {
    
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
  
  func clearCache(queue: DispatchQueue? = nil) {
    self.requestAnalysis(action: ["action": "clear_cache", "id": UUID().uuidString], queue: queue)
  }
  
  func getKatagoVersion(queue: DispatchQueue? = nil) {
    self.requestAnalysis(action: ["action": "query_version", "id": UUID().uuidString], queue: queue)
  }
  
  func terminateQuery(query_id: String, queue: DispatchQueue? = nil) {
    self.requestAnalysis(action: ["action": "terminate", "terminatedId": query_id], queue: queue)
  }
  
  func requestAnalysis(action: Any, queue: DispatchQueue? = nil) {
    let sending = { [weak self] in
      guard let self = self else { return }
    
      do {
        if let request = String(data: try JSONSerialization.data(withJSONObject: action, options: []), encoding: .utf8) {
          NSLog("Sending request: \(action)")
          self.engine.addInputRequest(request)
        }
      } catch {
        NSLog("Failed to JSONify request: \(action)")
      }
    }
    
    if let queue = queue {
      queue.async {
        sending()
      }
    } else {
      DispatchQueue.global(qos: .userInitiated).async {
        sending()
      }
    }
  }
  
  func requestAnalysis(analysis_node: NodeProtocol, queue: DispatchQueue? = nil) {
    let nodes = analysis_node.nodes_from_root
    
    let moves: [Move] = nodes.reduce(into: []) { result, nextNode in
      if let move = nextNode.move {
        result.append(move)
      }
    }
    
    let initial_stones = nodes.reduce(into: []) { result, nextNode in
      _ = nextNode.placements.map {
        result.append($0)
      }
    }
    
    queryCounter += 1
    
    let query: [String: Any] = [
      "id": "\(queryCounter)",
      "rules": Katago.get_rules(ruleset: analysis_node.ruleset),
      "analyzeTurns": [moves.count],
      "komi": analysis_node.komi,
      "boardXSize": size_x,
      "boardYSize": size_y,
      "initialStones": initial_stones.map { [String($0.player), $0.gtp()] },
      "initialPlayer": String(analysis_node.initial_player),
      "moves": moves.map { [String($0.player), $0.gtp()] }
    ]
    
    isIdle = true
    appendingResults.insert("\(queryCounter)")
    
    let sending = { [weak self] in
      guard let self = self else { return }
      
      do {
        if let request = String(data: try JSONSerialization.data(withJSONObject: query, options: []), encoding: .utf8) {
          NSLog("Sending request: \(query)")
          self.engine.addInputRequest(request)
        }
      } catch {
        NSLog("Failed to JSONify request: \(query)")
      }
    }
    
    if let queue = queue {
      queue.async {
        sending()
      }
    } else {
      DispatchQueue.global(qos: .userInitiated).async {
        sending()
      }
    }
  }
  
  /// Blocking fetch
  func fetchResult() -> [String: Any]? {
    let result = self.engine.fetchResult()
    if result != "terminate" {
      if let data = result.data(using: String.Encoding.utf8) {
        do {
          let parsedResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
          if let engineInitProcess = parsedResult?["initProcess"] {
            DispatchQueue.main.async { [unowned self] in
              self.initProgress = engineInitProcess as! Double
            }
            return nil
          }
          if let id = parsedResult?["id"] as? String {
            if !appendingResults.contains(id) {
              NSLog("Query result \(id) discarded -- recent new game or node reset?")
              return nil
            } else {
              appendingResults.remove(id)
              if appendingResults.isEmpty {
                DispatchQueue.main.async { [unowned self] in
                  self.isIdle = true
                }
              }
            }
            NSLog("Get result of \(id)")
          }
          
          return parsedResult
        } catch {
          NSLog(error.localizedDescription)
          return nil
        }
      }
    }
    NSLog("Result queue closed. (or some other reason)")
    return nil
  }
}
