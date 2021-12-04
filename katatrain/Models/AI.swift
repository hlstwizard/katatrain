//
//  AI.swift
//  katatrain
//
//  Created by Yiming Huang on 2021/12/3.
//

import Foundation

fileprivate func interp_ix<T: FloatingPoint>(lst: [T], x: T) -> (Int, T) {
  var i = 0
  while i + 1 < lst.count - 1 && lst[i + 1] < x {
    i += 1
  }
  let t = max(0, min(1, (x - lst[i]) / (lst[i + 1] - lst[i])))
  return (i, t)
}

fileprivate func interp1d(lst: [(Double, Double)], x: Double) -> Double {
  let (xs, ys) = unzip(lst)
  let (i, t) = interp_ix(lst: xs, x: x)
  return (1 - t) * ys[i] + t * ys[i+1]
}

fileprivate func interp2d(gridSpec: [Any], x: Double, y: Double) -> Double {
  let xs = gridSpec[0] as! [Double]
  let ys = gridSpec[1] as! [Double]
  let matrix = gridSpec[2] as! [[Double]]
  
  let (i, t) = interp_ix(lst: xs, x: x)
  let (j, s) = interp_ix(lst: ys, x: y)
  return matrix[j][i] * (1-t) * (1-s) +
  matrix[j][i+1] * t * (1-s) +
  matrix[j+1][i] * (1-t) * s +
  matrix[j+1][i+1] * t * s
}


func ai_rank_estimation(strategy: AIStrategy, settings: [String: Double]) -> Int {
  let elo: Double
  switch strategy {
  case .handicap, .jigo:
    return 9
  case .rank:
    return 1 - Int(settings["kyu_rank"]!)
  case .scoreloss:
    elo = interp1d(lst: AI_SCORELOSS_ELO.map { ($0.0, Double($0.1)) }, x: settings["strength"]!)
  case .weighted:
    elo = interp1d(lst: AI_WEIGHTED_ELO, x: settings["weaken_frac"]!)
  case .pick:
    elo = interp2d(gridSpec: AI_PICK_ELO_GRID, x: settings["pick_frac"]!, y: settings["pick_n"]!)
  case .local:
    elo = interp2d(gridSpec: AI_LOCAL_ELO_GRID, x: settings["pick_frac"]!, y: settings["pick_n"]!)
  case .tenuki:
    elo = interp2d(gridSpec: AI_TENUKI_ELO_GRID, x: settings["pick_frac"]!, y: settings["pick_n"]!)
  case .territory:
    elo = interp2d(gridSpec: AI_TERRITORY_ELO_GRID, x: settings["pick_frac"]!, y: settings["pick_n"]!)
  case .influence:
    elo = interp2d(gridSpec: AI_INFLUENCE_ELO_GRID, x: settings["pick_frac"]!, y: settings["pick_n"]!)
  case .antimirror, .policy, .simple_ownership, .settle_stones:
    return AI_STRENGTH[strategy]!
  default:
    return 9
  }
  let kyu = Int(interp1d(lst: CALIBRATED_RANK_ELO.map { ($0.0, Double($0.1)) }, x: elo))
  return 1 - kyu
}

/// Sync method, should be called in a dispatchqueue
func generate_ai_move(game: Game, ai_mode: String, ai_settings: [String: Any]) -> (Move, NodeProtocol) {
  let cn = game.currentNode
  
  if ai_mode == AIStrategy.handicap.rawValue {
    
  } else if ai_mode == AIStrategy.antimirror.rawValue {
    
  }
  
  if AI_STRATEGIES_POLICY.contains(ai_mode) {
    
  }
  
  return (Move(coord: nil, player: "B"), cn)
}
