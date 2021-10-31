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
  var mode: Mode = .vs
  var player: Player = 1
  
  init() {
    engine = Engine.init("Katagob40")
  }
  
//  func setPositions() {
//    
//  }
  
  func getColors() -> [NSNumber] {
    return engine.getColors() as! [NSNumber]
  }
  
  func play(loc: Loc) {
    switch mode {
    case .vs:
      _ = engine.play(loc, player)
      let opp = player ^ 3
      let botMove = engine.genmove(opp)
      engine.play(Loc(botMove), opp)
    case .analyse:
      print("Not implemented mode \(mode)")
    
    }
    
    objectWillChange.send()
  }
}
