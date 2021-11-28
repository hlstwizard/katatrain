//
//  SgfNode.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/11/20.
//

import Foundation

class SgfNode: NodeProtocol {
  var children: [NodeProtocol] = []
  var parent: NodeProtocol?
  var properties: [String: [String]]
  
  private var _root: NodeProtocol?
  private var _move: Move?
  
  required init(parent: inout NodeProtocol?, properties: [String: [String]], move: Move?) {
    self.parent = parent
    self.properties = properties
    
    if self.parent != nil {
      self.parent!.children.append(self)
    }
    
    if let move = move {
      self._move = move
    }
  }
  
  required convenience init() {
    var parent: NodeProtocol?
    self.init(parent: &parent, properties: [:], move: nil)
  }
  
  required convenience init(parent: inout NodeProtocol?) {
    self.init(parent: &parent, properties: [:], move: nil)
  }
  
  private func expanded_placements(player: Character?) -> [Move] {
    let sgf_pl: Character
    if let player = player {
      sgf_pl = player
    } else {
      sgf_pl = "E"
    }
    let placements = get_property(property: "A\(sgf_pl)", default_value: []) as! [String]
    if placements.isEmpty {
      return []
    }
    let to_be_expanded = placements.filter { $0.contains(":") }
    if to_be_expanded.isEmpty {
      return placements.map { Move.from_sgf(sgf_coords: $0, board_size: self.board_size, player: sgf_pl) }
    } else {
      return []
    }
  }
  
  // MARK: - Properties
  var root: NodeProtocol {
    if _root != nil {
      return _root!
    }
    if self.parent != nil {
      self._root = self.parent!.root
      return self._root!
    } else {
      return self
    }
  }
  
  var komi: Float {
    if let komi = Float(self.root.get_property(property: "KM") as! String) {
      return komi
    }
    return 6.5
  }
  
  var handicap: Int {
    if let ha = Int(self.root.get_property(property: "HA") as! String) {
      return ha
    }
    return 0
  }
  
  var ruleset: String {
    return self.root.get_property(property: "RU", default_value: "japanese") as! String
  }
  
  var placements: [Move] {
    var res: [Move] = []
    for p in Move.PLAYERS {
      if let sgf_coords = get_property(property: "A\(p)") as? [String] {
        for sgf_coord in sgf_coords {
          res.append(Move.from_sgf(sgf_coords: sgf_coord, player: p))
        }
      }
    }
    
    return res
  }
  
  var move: Move? {
    if let move = self._move {
      return move
    } else {
      var res: [Move] = []
      for p in Move.PLAYERS {
        if let sgf_coord = get_property(property: "\(p)") as? String {
          res.append(Move.from_sgf(sgf_coords: sgf_coord, player: p))
        }
      }
      // Discard if there are more moves.
      if res.isEmpty { return nil }
      self._move = res[0]
      return self._move
    }
  }
  
  var clear_placements: [Move] {
    return []
  }
  
  var move_with_placements: [Move] {
    if let move = move {
      return self.placements + [move]
    } else {
      return self.placements
    }
  }
  
  var is_root: Bool {
    return self.parent == nil
  }
  
  var initial_player: Character {
    if let player = root.get_property(property: "PL") as? String {
      if player.uppercased().trimmingCharacters(in: .whitespacesAndNewlines) == "B" {
        return "B"
      } else {
        return "W"
      }
    } else if !root.children.isEmpty {
      for child in root.children {
        for color in ["B", "W"] {
          if let player = child.get_property(property: color) as? Character {
            return player
          }
        }
      }
    }
    
    if self.properties["AB"] != nil && self.properties["AW"] == nil {
      return "W"
    } else {
      return "B"
    }
  }
  
  var nodes_from_root: [NodeProtocol] {
    var nodes: [NodeProtocol] = [self]
    var n: NodeProtocol = self as NodeProtocol
    while !n.is_root {
      n = n.parent!
      nodes.append(n)
    }
      return nodes.reversed()
  }
  
  var board_size: (Int, Int) {
    if let board_size: String = self.root.get_property(property: "SZ", default_value: "19") as? String {
      if board_size.contains(":") {
        let size_tuple = board_size.components(separatedBy: ":").map { String($0) }
        return (Int(size_tuple[0]) ?? 19, Int(size_tuple[1]) ?? 19)
      } else {
        return (Int(board_size) ?? 19, Int(board_size) ?? 19)
      }
    } else {
      return (19, 19)
    }
  }
  
  // MARK: - Public
  func add_list_property(property: String, values: [String]) {
    self.properties[property] = values
  }
  
  func get_property(property: String, default_value: Any? = nil) -> Any? {
    if let values = self.properties[property] {
      if values.count == 1 {
        return values[0]
      } else {
        return values
      }
    }
    if let default_value = default_value {
      return default_value
    }
    return nil
  }
}

final class GameNode: SgfNode {
  var analysis_visits_requested: Int = 0
  var analysis: [String: Any] = [:]
  var analysis_from_sgf: [String] = []
  
  func analyse(engine: Katago) {
    
  }
  
  override func add_list_property(property: String, values: [String]) {
    if property == "KT" {
      self.analysis_from_sgf = values
    } else if property == "C" {
      // TODO: Comment in SGF
    } else {
      super.add_list_property(property: property, values: values)
    }
  }
}
