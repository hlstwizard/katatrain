//
//  PlayerView.swift
//  katatrain
//
//  Created by Yiming Huang on 2021/12/12.
//

import SwiftUI

struct PlayerView: View {
  @ObservedObject var player: Player
  
  var icon: some View {
    ZStack {
      let iconColor = player.pla == "B" ? Color.black : Color.white
      let numColor = player.pla == "B" ? Color.white : Color.black
      Circle().fill(iconColor)
      Text("\(player.captured)").foregroundColor(numColor)
    }
  }
  
  var body: some View {
    HStack {
      icon
      
      if player.type == .ai {
        Text("AI")
      } else {
        Text("Human")
      }
    }
  }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
      PlayerView(player: Player()).frame(maxHeight: 50)
    }
}
