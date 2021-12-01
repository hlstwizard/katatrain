//
//  NodeProtocol.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/11/27.
//

import Foundation

protocol NodeProtocol {
  var children: [NodeProtocol] { get set }
  var properties: [String: [String]] { get set }
  var parent: NodeProtocol? { get set }
  var root: NodeProtocol { get }
  
  var komi: Float { get }
  var handicap: Int { get }
  var ruleset: String { get }
  var placements: [Move] { get }
  var move_with_placements: [Move] { get }
  var clear_placements: [Move] { get }
  var move: Move? { get }
  var is_root: Bool { get }
  var initial_player: Character { get }
  var nodes_from_root: [NodeProtocol] { get }
  var board_size: (Int, Int) { get }
  var title: String { get }
  
  func add_list_property(property: String, values: [String])
  func get_property(property: String, default_value: Any?) -> Any?
  func get_properties(property: String, default_value: [Any]) -> [Any]
  
  init()
  init(parent: inout NodeProtocol?)
  init(parent: inout NodeProtocol?, properties: [String: [String]], move: Move?)
  
  func play(move: Move) -> NodeProtocol
}

extension NodeProtocol {
  func get_property(property: String, default_value: Any? = nil) -> Any? {
    return get_property(property: property, default_value: default_value)
  }
  
  func get_properties(property: String, default_value: [Any] = [] ) -> [Any] {
    return get_properties(property: property, default_value: default_value)
  }
}
