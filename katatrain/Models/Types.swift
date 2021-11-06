//
//  Types.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/10/30.
//

import Foundation

enum PlayerColor: Int {
  case P_BLACK = 1
  case P_WHITE
}

enum StoneColor: Int {
  case C_EMPTY = 0
  case C_BLACK
  case C_WHITE
  case C_WALL
}

typealias SwLoc = (x: Int, y: Int)
typealias SWMove = (loc: SwLoc, pla: Player)
