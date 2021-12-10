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
  var policy: [Double]? = nil
  var ownership: [Double]? = nil
  
  init(analysis_json: [String: Any]) {
    self.root = analysis_json["rootInfo"]! as! [String: Any]
    self.ownership = analysis_json["ownership"] as? [Double]
    self.policy = analysis_json["policy"] as? [Double]
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
  
  static func player_sign(player: Character) -> Int {
    return ["B": 1,"W": -1][player] ?? 0
  }
  
  var candidate_moves: [[String: Any]]? {
    if let moves = analysis?.moves {
      let root_score = analysis?.root["scoreLead"] as! Double
      let root_winrate = analysis?.root["winrate"] as! Double
      let move_dicts: [[String: Any]] = Array(moves.values.map { $0 as! [String: Any] })
      let top_move = move_dicts.filter { $0["order"] as? Int == 0 }
      let top_score_lead: Double
      if top_move.isEmpty {
        top_score_lead = analysis?.root["scoreLead"] as! Double
      } else {
        top_score_lead = top_move[0]["scoreLead"] as! Double
      }
      
      let move_dicts_with_lost: [[String: Any]] = move_dicts.map {
        var tmp: [String: Any] = [
          "pointsLost": GameNode.player_sign(player: next_player) * (root_score - ($0["scoreLead"] as! Double)),
          "relativePointsLost": GameNode.player_sign(player: next_player) * (top_score_lead - ($0["scoreLead"] as! Double)),
          "winrateLost": GameNode.player_sign(player: next_player) * (root_winrate - ($0["winrate"] as! Double)),
        ]
        
        tmp.merge($0, uniquingKeysWith: { cur, new in new })
        
        return tmp
      }
      return move_dicts_with_lost.sorted {
        ($0["order"] as! Double, $0["pointsLost"] as! Double) < ($1["order"] as! Double, $1["pointsLost"] as! Double)
      }
    }
    
    return nil
  }
  
  var policy_ranking: [(Double, Move)]? {
    if let policy = analysis?.policy {
      let (szx, szy) = root.board_size
      let policy_grid: [[Double]] = var_to_grid(array: policy, size: root.board_size)
      var moves: [(Double, Move)] = []
      for x in 0..<szx {
        for y in 0..<szy {
          moves.append((policy_grid[y][x], Move(coord: (x, y), player: next_player)))
        }
      }
      moves.append((policy.last!, Move(coord: nil, player: next_player)))
      return moves.sorted { $0.0 > $1.0 }
    }
    
    return nil
  }
  
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
    
    self.analysis = Analysis(analysis_json: analysis_json)
    
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
