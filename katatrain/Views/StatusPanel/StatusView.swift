//
//  RightView.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/11/10.
//

import SwiftUI

struct StatusView: View {
  @EnvironmentObject var game: Game
  
  let playerViewMaxHeight: CGFloat = 80.0
  
  var body: some View {
    VStack {
      HStack {
        PlayerView(player: game.players["B"]!)
        PlayerView(player: game.players["W"]!)
      }.frame(maxHeight: playerViewMaxHeight)
        .background(.gray)
    }
  }
}

struct StatusView_Previews: PreviewProvider {
  static var previews: some View {
    StatusView()
  }
}
