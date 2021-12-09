//
//  Move.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/11/20.
//

import Foundation

struct Coord: Equatable, Hashable, Comparable {
  static func < (lhs: Coord, rhs: Coord) -> Bool {
    return lhs.x < rhs.x && lhs.y < rhs.y
  }
  
  func toDrawCoord(boardSize: Int) -> (Int, Int) {
    return (x, boardSize - y - 1)
  }
  
  var x: Int
  var y: Int
  
  init(t: (Int, Int)) {
    x = t.0
    y = t.1
  }
}

/// Actually it's a move but with a bad naming
struct Move: Equatable, Hashable {
  static let PLAYERS = "BW"
  // Enough for size < 26
  // Not I in the COORD
  static let GTP_COORD = "ABCDEFGHJKLMNOPQRSTUVWXYZ"
  static let SGF_COORD = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

  static func == (lhs: Move, rhs: Move) -> Bool {
    if lhs.coord == nil && rhs.coord == nil {
      return lhs.player == rhs.player
    } else if lhs.coord != nil || rhs.coord != nil {
      return lhs.coord! == rhs.coord! && lhs.player == rhs.player
    }
    return false
  }
  
  var player: Character
  var coord: Coord? = nil
  
  init(coord: (Int, Int)?, player: Character) {
    if let coord = coord {
      self.coord = Coord(t: coord)
    }
    self.player = player
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(coord?.x)
    hasher.combine(coord?.y)
    hasher.combine(player)
  }
  
  /// `gtp_coords` e.g. `A12`, `H3`
  static func from_gtp(gtp_coords: String, player: Character = "B") -> Move {
    // TODO: Lots of ! here, using try
    
    let range = NSRange(location: 0, length: gtp_coords.utf16.count)
    let regex = try! NSRegularExpression(pattern: "([A-Z]+)(\\d+)")
    let matches = regex.matches(in: gtp_coords, options: [], range: range)
    let firstRange = Range(matches[0].range(at: 1), in: gtp_coords)
    let first = gtp_coords[firstRange!]
    let firstIndex = Move.GTP_COORD.firstIndex(of: first.first!)!
    
    let secondRange = Range(matches[0].range(at: 2), in: gtp_coords)
    let second = Int(gtp_coords[secondRange!])! - 1
    
    return Move(coord: (Move.GTP_COORD.distance(from: Move.GTP_COORD.startIndex, to: firstIndex), second), player: player)
  }
  
  /// `sgf_coords` e.g. `ab`, `tt` means pass
  static func from_sgf(sgf_coords: String, board_size: (Int, Int) = (19, 19), player: Character = "B") -> Move {
    if sgf_coords == "" || (sgf_coords == "tt" && board_size.0 <= 19 && board_size.1 <= 19 ) {
      return Move(coord: nil, player: player)
    }
    let upper = sgf_coords.uppercased()
    let first = Move.SGF_COORD.distance(from: Move.SGF_COORD.startIndex, to: Move.SGF_COORD.firstIndex(of: upper.first!)!)
    let second = Move.SGF_COORD.distance(from: Move.SGF_COORD.startIndex, to: Move.SGF_COORD.firstIndex(of: upper.last!)!)
    
    return Move(coord: (first, board_size.1 - second - 1), player: player)
  }
  
  var is_pass: Bool {
    return self.coord == nil
  }
  
  var opponent: Character {
    if self.player == "B" {
      return "W"
    } else {
      return "B"
    }
  }
  
  func gtp() -> String {
    if self.is_pass {
      return "pass"
    } else {
      let index = Move.GTP_COORD.index(Move.GTP_COORD.startIndex, offsetBy: self.coord!.x)
      return "\(Move.GTP_COORD[index])\(self.coord!.y + 1)"
    }
  }
  
  func sgf(boardSize: (Int, Int) = (19, 19)) -> String {
    if self.is_pass {
      return ""
    }
    return "\(Move.SGF_COORD[coord!.x])\(Move.SGF_COORD[boardSize.1 - coord!.y - 1])"
  }
}


extension Coord {
  static func ==(left: Coord, right: (Int, Int)) -> Bool {
    return left.x == right.0 && left.y == right.1
  }
}
