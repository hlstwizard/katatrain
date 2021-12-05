//
//  GameNode.swift
//  katatrain
//
//  Created by Yiming Huang on 2021/12/5.
//

import Foundation


struct Analysis {
  var root: [String: Any]
  var moves: [String: Any] = [:]
  var complete: Bool = false
  
  init(analysis_json: [String: Any]) {
    self.root = analysis_json["rootInfo"]! as! [String: Any]
  }
  
  mutating func update_move_analysis(move_analysis: [String: Any], gtp: String) {
    if moves[gtp] != nil {
      
    } else {
      moves[gtp] = move_analysis
    }
  }
}


final class GameNode: SgfNode {
  var analysis_visits_requested: Int = 0
  var analysis: Analysis? = nil
  var analysis_from_sgf: [String] = []
  
  /// Callback function when analysis done.
  func set_analysis(analysis_json: [String: Any], partial_result: Bool) {
    set_analysis(analysis_json: analysis_json, refine_move: nil, addtional_moves: false, region_of_interest: nil, partial_result: partial_result)
    
  }
  
  func set_analysis(analysis_json: [String: Any],
                    refine_move: Move? = nil,
                    addtional_moves: Bool = false,
                    region_of_interest: [Int]? = nil,
                    partial_result: Bool = false) {
    NSLog("callback \(analysis_json), \(partial_result)")
    
    analysis = Analysis(analysis_json: analysis_json)
    
    for move_analysis in analysis_json["moveInfos"] as! [[String: Any]] {
      analysis?.update_move_analysis(move_analysis: move_analysis, gtp: move_analysis["move"] as! String)
    }
    
    analysis?.complete = true
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
