//
//  RightView.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/11/10.
//

import SwiftUI

struct PlayerView: View {
  @ObservedObject var player: Player
  
  var body: some View {
    HStack {
      if player.pla == "B" {
        Text("Black:")
      } else {
        Text("White:")
      }
      
      if player.type == .ai {
        Text("AI")
      } else {
        Text("Human")
      }
    }
  }
}

struct StatusView: View {
  @EnvironmentObject var game: Game
  
  var body: some View {
    HStack {
      PlayerView(player: game.players["B"]!)
      PlayerView(player: game.players["W"]!)
    }
  }
}

struct StatusView_Previews: PreviewProvider {
  static var previews: some View {
    StatusView()
  }
}
