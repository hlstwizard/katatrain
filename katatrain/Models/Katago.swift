//
//  Katago.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/10/29.
//

import Foundation
import Combine

class Katago: ObservableObject {
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
  var appendingResults: [String] = []
  var running: Bool = false
  
  init() {
    engine = Engine.init("Katagob40", "analysis_example")
    game = Game.init("tromp-taylor")
    analyseQueue = DispatchQueue(label: "com.katatrain.analyse", qos: .utility)
    
    analyseQueue.async { [weak self] in
      guard let self = self else { return }
      self.engine.runLoop()
    }
    eventHandler = self.fetchResultLoop
    fetchResultTimer.activate()
    state = .resumed
  }
  
  deinit {
    fetchResultTimer.setEventHandler {}
    fetchResultTimer.cancel()
    resume()
    eventHandler = nil
  }
  
  func request_analysis(action: String? = nil) {
    let id = UUID()
    appendingResults.append(id.uuidString)
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      guard let self = self else { return }
      if let action = action {
        self.engine.addInputRequest("{\"id\":\"\(id.uuidString)\",\"action\":\"\(action)\"}")
      } else {
        let request = self.game.toRequestJson()
        NSLog(request)
        self.engine.addInputRequest(request)
      }
    }
  }
  
  func getColors() -> [NSNumber] {
    return game.getColors().compactMap({ $0 as? NSNumber })
  }
  
  func fetchResultLoop() {
    let result = self.engine.fetchResult()
    if !result.isEmpty {
        print("main loop: \(result)")
    }
  }
  
  func play(loc: Loc) {
    game.makeMove(loc, Int8(player.rawValue))
    request_analysis()
    
    switch mode {
    case .vs:
      print("Not implemented mode \(mode)")
    case .analyse:
      print("Not implemented mode \(mode)")
    }
    
    objectWillChange.send()
  }
}
