//
//  SgfNode.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/11/20.
//

import Foundation

public protocol NodeProtocol {
  var children: [NodeProtocol] { get set }
  var properties: [String: [String]] { get set }
  var parent: NodeProtocol? { get set }
  var root: NodeProtocol { get }
  
  var komi: Float { get }
  var handicap: Int { get }
  var ruleset: String { get }
  var placement: [Move] { get }
  var move: Move? { get }
  var is_root: Bool { get }
  var nodes_from_root: [NodeProtocol] { get }
  
  func add_list_property(property: String, values: [String])
  func get_property(property: String, default_value: Any?) -> Any?
  
  init()
  init(parent: inout NodeProtocol?)
  init(parent: inout NodeProtocol?, properties: [String: [String]], move: Move?)
}

extension NodeProtocol {
  func get_property(property: String, default_value: Any? = nil ) -> Any? {
    return get_property(property: property, default_value: default_value)
  }
}

open class SgfNode: NodeProtocol {
  public var children: [NodeProtocol] = []
  public var parent: NodeProtocol?
  public var properties: [String: [String]]
  
  private var _root: NodeProtocol?
  private var _move: Move?
  
  required public init(parent: inout NodeProtocol?, properties: [String: [String]], move: Move?) {
    self.parent = parent
    self.properties = properties
    
    if self.parent != nil {
      self.parent!.children.append(self)
    }
    
    if let move = move {
      self._move = move
    }
  }
  
  required convenience public init() {
    var parent: NodeProtocol?
    self.init(parent: &parent, properties: [:], move: nil)
  }
  
  required convenience public init(parent: inout NodeProtocol?) {
    self.init(parent: &parent, properties: [:], move: nil)
  }
  
  // MARK: - Properties
  public var root: NodeProtocol {
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
  
  public var komi: Float {
    if let komi = Float(self.root.get_property(property: "KM") as! String) {
      return komi
    }
    return 6.5
  }
  
  public var handicap: Int {
    if let ha = Int(self.root.get_property(property: "HA") as! String) {
      return ha
    }
    return 0
  }
  
  public var ruleset: String {
    return self.root.get_property(property: "RU", default_value: "japanese") as! String
  }
  
  public var placement: [Move] {
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
  
  public var move: Move? {
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
  
  public var is_root: Bool {
    return self.parent == nil
  }
  
  public var nodes_from_root: [NodeProtocol] {
    var nodes: [NodeProtocol] = [self]
    var n: NodeProtocol = self as NodeProtocol
    while !n.is_root {
      n = n.parent!
      nodes.append(n)
    }
    return nodes
  }
  
  // MARK: - Public
  public func add_list_property(property: String, values: [String]) {
    self.properties[property] = values
  }
  
  public func get_property(property: String, default_value: Any? = nil) -> Any? {
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
