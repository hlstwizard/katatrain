//
//  BoardView+Action.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/10/21.
//

import Foundation

@available(iOS 15.0, *)
extension BoardView {
  func play(point:(x:Int, y: Int)) {
    if point.x == -1 || point.y == -1 {
      return
    }
    if game.engine.isIdle {
      NSLog("Be patient..")
      return
    }
    do {
      try game.play(x: point.x, y: boardSize - point.y - 1)
    } catch {
      NSLog("\(error)")
    }
  }
}
