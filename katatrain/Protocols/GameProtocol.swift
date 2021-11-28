//
//  GameProtocol.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/11/27.
//

import Foundation

protocol GameProtocol {
  func play(move: Move, ignore_ko: Bool)
  func undo(n_times: UInt)
  func redo(n_times: UInt)
}
