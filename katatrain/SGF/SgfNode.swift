//
//  SgfNode.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/11/20.
//

import Foundation

class SgfNode {
  var children: [SgfNode] = []
  var properties: [String: String] = [:]
  var parent: SgfNode?
  var move: SgfMove?
  
  init(move: SgfMove? = nil) {
    if let parent = parent {
      parent.children.append(self)
    }
    
    if let move = move {
      self.move = move
    }
  }
}
