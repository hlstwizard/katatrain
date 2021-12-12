//
//  RightView.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/11/10.
//

import SwiftUI

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
