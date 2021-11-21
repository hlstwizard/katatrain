//
//  Move.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/11/20.
//

import Foundation

/// Actually it's a move but with a bad naming
struct SgfMove: Equatable {
  static let PLAYERS = "BW"
  // Enough for size < 26
  // Not I in the COORD
  static let GTP_COORD = "ABCDEFGHJKLMNOPQRSTUVWXYZ"

  typealias Coord = (Int, Int)
  
  static func == (lhs: SgfMove, rhs: SgfMove) -> Bool {
    if lhs.coord == nil && rhs.coord == nil {
      return lhs.player == rhs.player
    } else if lhs.coord != nil || rhs.coord != nil {
      return lhs.coord! == rhs.coord! && lhs.player == rhs.player
    }
    return false
  }
  
  /// `gtp_coords` e.g. `A12`, `H3`
  static func from_gtp(gtp_coords: String, board_size: Int = 19, player: Character = "B") -> SgfMove {
    // TODO: Lots of ! here, using try
    
    let range = NSRange(location: 0, length: gtp_coords.utf16.count)
    let regex = try! NSRegularExpression(pattern: "([A-Z]+)(\\d+)")
    let matches = regex.matches(in: gtp_coords, options: [], range: range)
    let firstRange = Range(matches[0].range(at: 1), in: gtp_coords)
    let first = gtp_coords[firstRange!]
    let firstIndex = SgfMove.GTP_COORD.firstIndex(of: first.first!)!
    
    let secondRange = Range(matches[0].range(at: 2), in: gtp_coords)
    let second = Int(gtp_coords[secondRange!])! - 1
    
    return SgfMove(coord: (SgfMove.GTP_COORD.distance(from: SgfMove.GTP_COORD.startIndex, to: firstIndex), second), player: player)
  }
  
  /// `sgf_coords` e.g. `tt`
  static func from_sgf(sgf_coords: String, board_size: Int = 19, player: Character = "B") -> SgfMove {
    let upper = sgf_coords.uppercased()
    let first = SgfMove.GTP_COORD.distance(from: SgfMove.GTP_COORD.startIndex, to: SgfMove.GTP_COORD.firstIndex(of: upper.first!)!)
    let second = SgfMove.GTP_COORD.distance(from: SgfMove.GTP_COORD.startIndex, to: SgfMove.GTP_COORD.firstIndex(of: upper.last!)!)
    
    return SgfMove(coord: (first, second), player: player)
  }
  
  var player: Character
  var coord: Coord?
  
  init(coord: Coord?, player: Character) {
    self.coord = coord
    self.player = player
  }
  
  func is_pass() -> Bool {
    return self.coord == nil
  }
  
  func opponent() -> Character {
    if self.player == "B" {
      return "W"
    } else {
      return "B"
    }
  }
}
