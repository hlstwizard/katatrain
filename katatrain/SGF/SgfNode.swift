//
//  SgfNode.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/11/20.
//

import Foundation

class SgfNode {
  var children: [SgfNode] = []
  var properties: [String: [String]] = [:]
  var parent: SgfNode?
  var move: SgfMove?
  
  // MARK: - Properties
  var root: SgfNode {
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
    if let komi = Float(get_property(property: "KM") as! String) {
      return komi
    }
    return 6.5
  }
  
  var handicap: Int {
    if let ha = Int(get_property(property: "HA") as! String) {
      return ha
    }
    return 0
  }
  
  var ruleset: String {
    return get_property(property: "RU", default_value: "japanese") as! String
  }
  
  var placement: [SgfMove] {
    var res: [SgfMove] = []
    for p in SgfMove.PLAYERS {
      for sgf_coord in get_property(property: "A\(p)") as! [String] {
        res.append(SgfMove.from_sgf(sgf_coords: sgf_coord, player: p))
      }
    }
    
    return res
  }
  
  var is_root: Bool {
    return self.parent == nil
  }
  
  // MARK: - Public
  func add_list_property(property: String, values: [String]) {
    self.properties[property] = values
  }
  
  func get_property(property: String, default_value: Any? = nil) -> Any? {
    if let values = self.root.properties[property] {
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
  private var _root: SgfNode?
  
  init(parent: SgfNode? = nil, properties: [String: [String]] = [:], move: SgfMove? = nil) {
    self.parent = parent
    self.properties = properties
    
    if let parent = self.parent {
      parent.children.append(self)
    }
    
    if let move = move {
      self.move = move
    }
  }
}
