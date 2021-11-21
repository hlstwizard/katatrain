//
//  SgfNode.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/11/20.
//

import Foundation

class Node {
  var children: [Node] = []
  var properties: [String: [String]] = [:]
  var parent: Node?
  
  // MARK: - Properties
  var root: Node {
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
  
  var placement: [Move] {
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
  
  var is_root: Bool {
    return self.parent == nil
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
  
  // MARK: - Private
  private var _root: Node?
  private var _move: Move?
  
  init(parent: Node? = nil, properties: [String: [String]] = [:], move: Move? = nil) {
    self.parent = parent
    self.properties = properties
    
    if let parent = self.parent {
      parent.children.append(self)
    }
    
    if let move = move {
      self._move = move
    }
  }
}
