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

func ai_move_callback(game: Game, ai_mode: AIStrategy, _ json: [String: Any], _ partial: Bool) {
  let cn = game.currentNode
  cn.set_analysis(analysis_json: json, partial_result: partial)
  
  var ai_thoughts: String = ""
  
  if AI_STRATEGIES_POLICY.contains(ai_mode.rawValue) && cn.analysis?.policy != nil {
    let policy_moves = cn.policy_ranking!
    let pass_policy = cn.analysis?.policy?.last
    
    let top_5_pass = policy_moves[..<5].filter { $0.1.is_pass }.count > 0
    ai_thoughts += "Using policy based strategy, base top 5 moves are \(policy_moves[..<5])"
  } else {
    // Engine based move
    if let candidate_ai_moves = cn.candidate_moves {
      let top_cand = Move.from_gtp(gtp_coords: candidate_ai_moves[0]["move"] as! String, player: cn.next_player)
      if top_cand.is_pass {
        ai_thoughts += "It's a pass."
      } else {
        let aimove = top_cand
        do {
          try game.play(move: aimove, ignore_ko: false)
          ai_thoughts += "AI played: \(aimove)"
        } catch {
          NSLog("\(error)")
        }
      }
    }
  }
  
  NSLog(ai_thoughts)
}

func generate_ai_move(game: Game, ai_mode: AIStrategy, ai_settings: [String: Any]? = nil) {
  let cn = game.currentNode
    
  if ai_mode == .handicap {
    let n_handicap = game.root.handicap
    let MOVE_VALUE: Double = 14
    let b_stone_advantage = max(n_handicap - 1, 0) - (Double(cn.komi) - MOVE_VALUE / 2) / MOVE_VALUE
    let pda = min(3, max(-3, -b_stone_advantage * (3 / 8)))
    
    game.engine.requestAnalysis(analysis_node: cn,
                                callback: { ai_move_callback(game: game, ai_mode: ai_mode, $0, $1) },
                                extra_settings: [
                                  "playoutDoublingAdvantage": pda,"playoutDoublingAdvantagePla": "BLACK"
                                ])
  } else if ai_mode == .antimirror {
    game.engine.requestAnalysis(analysis_node: cn,
                                callback: { ai_move_callback(game: game, ai_mode: ai_mode, $0, $1) },
                                extra_settings: ["antiMirror": true])
  }
  
  if AI_STRATEGIES_POLICY.contains(ai_mode.rawValue) {
    
  }
}
