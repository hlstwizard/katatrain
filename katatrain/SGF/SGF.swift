//
//  SGF.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/11/20.
//

import Foundation
import SwiftUI

let SGF_PAT_STR = #"\(;(.*)\)"#
let SGF_PROP_PAT_STR = #"\s*(?:\(|\)|;|"# +
  #"(?<property>\w+)"# +
  #"(?<values>(\s*\[([^\]\\]|\\.)*\])+))"#

class SGF<Node: NodeProtocol> {
  enum SGFError: Error {
    case failedToLoadFile
    case noNodeInFile
  }
  
  private(set) var content: String
  private var idx: String.Index
  
  var root: Node

  static func parse_file(url: URL) throws -> Node {
    let SGF_PAT = try! NSRegularExpression(pattern: SGF_PAT_STR, options: [.dotMatchesLineSeparators])
    
    do {
      let data = try Data(contentsOf: url)
      let content = String(decoding: data, as: UTF8.self)
      
      let matches = SGF_PAT.matches(in: content, options: [], range: NSRange(location: 0, length: content.utf8.count))
      if matches.count == 1 {
        let clipped_str = content[Range(matches[0].range(at: 1), in: content)!]
        return SGF(content: String(clipped_str)).root
      } else {
        throw SGFError.noNodeInFile
      }
    } catch {
      throw SGFError.failedToLoadFile
    }
  }
  
  init(content: String) {
    self.content = content.replacingOccurrences(of: "\n", with: "")
    self.idx = self.content.startIndex
    
    root = Node()
    self.parse_branch(root)
  }
  
  private func parse_branch(_ node: Node) {
    let SGF_PROP_PAT = try! NSRegularExpression(pattern: SGF_PROP_PAT_STR, options: [.dotMatchesLineSeparators])
    var current_node = node

    while self.idx != self.content.endIndex {
      let scanPointer = self.content.distance(from: self.content.startIndex, to: self.idx)
      let resetLength = self.content.count - scanPointer
      let matches = SGF_PROP_PAT.matches(in: content, options: [], range: NSRange(location: scanPointer, length: resetLength))
      
      for match in matches {
        self.content.formIndex(&self.idx, offsetBy: match.range.length)
        let sub = content[Range(match.range(at: 0), in: content)!]
        
        if sub == ")" {
          return
        }
        var _parent: NodeProtocol? = current_node as NodeProtocol
        if sub == "(" {
          self.parse_branch(Node(parent: &_parent))
        } else if sub == ";" {
          current_node = Node(parent: &_parent)
        } else {
          let property = content[Range(match.range(withName: "property"), in: content)!]
          let nsrange = match.range(withName: "values")
          
          // \0 by the end, so -2
          let range = Range(NSRange(location: nsrange.location + 1, length: nsrange.length - 2), in: content)
          let value_str = content[range!]
          let values: [String] = try! NSRegularExpression(pattern: #"\]\s*\["#).splitn(String(value_str))
          
          current_node.add_list_property(property: String(property), values: values)
        }
      }
      
    }
  }
}
