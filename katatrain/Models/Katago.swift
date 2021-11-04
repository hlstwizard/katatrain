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
  
  var engine: Engine
  var queue: DispatchQueue
  var mode: Mode = .vs
  var player: Player = 1
  var queueLable = "com.hlstwizard.analysis"
  var commands: [String] = []
  var results: [String] = []
  var running: Bool = false
  
  init() {
    engine = Engine.init("Katagob40", "analysis_example")
    queue = DispatchQueue(label: queueLable, qos: .utility)
    
    queue.async { [weak self] in
      guard let self = self else { return }
      self.engine.runLoop()
    }
  }
  
//  func setPositions() {
//    
//  }
  
  func getColors() -> [NSNumber] {
    return [NSNumber(1)]
  }
  
  func fetchResult() {
    
  }
  
  func play(loc: Loc) {
    switch mode {
    case .vs:
      print("Not implemented mode \(mode)")
    case .analyse:
      print("Not implemented mode \(mode)")
    
    }
    
    objectWillChange.send()
  }
}
