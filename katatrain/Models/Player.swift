//
//  Player.swift
//  katatrain
//
//  Created by Yiming Huang on 2021/12/3.
//

import Foundation

enum PlayerType: String {
  case human = "player:human"
  case ai = "player:ai"
}

enum PlayerSubType: String {
  case normal = "game:normal"
  case teach = "game:teach"
}

enum AIStrategy: String {
  case `default` = "ai:default"
  case handicap = "ai:handicap"
  case scoreloss = "ai:scoreloss"
  case weighted = "ai:p:weighted"
  case jigo = "ai:jigo"
  case antimirror = "ai:antimirror"
  case policy = "ai:policy"
  case pick = "ai:p:pick"
  case local = "ai:p:local"
  case tenuki = "ai:p:tenuki"
  case influence = "ai:p:influence"
  case territory = "ai:p:territory"
  case rank = "ai:p:rank"
  case simple_ownership = "ai:simple"
  case settle_stones = "ai:settle"
}

struct Player {
  var pla: String = "B"
  var type: PlayerType = .human
  var subType: PlayerSubType = .normal
  var name: String = ""
  var periods_used: Int = 0
  
  var ai: Bool { type == .ai }
  var human: Bool { type == .human }
  
  var being_taught: Bool { type == .human && subType == .teach }
  var strategy: AIStrategy {
    .default
  }
  
  init(_ pla: String = "B") {
    self.pla = pla
  }
}
