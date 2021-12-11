//
//  NewGameView.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/11/12.
//

import SwiftUI

struct PlayerPickerView: View {
  var player: Player
  
  var body: some View {
    let playerType = Binding(get: {
      player.type
    }, set: {
      player.type = $0
    })
    HStack {
      if player.pla == "B" {
        Text("Black:")
      } else {
        Text("White:")
      }
      
      Picker(selection: playerType, content: {
        Text("Human").tag(PlayerType.human)
        Text("AI").tag(PlayerType.ai)
      }, label: {
        Text("\(player.pla)")
      })
    }
  }
}

struct NewGameView: View {
  @EnvironmentObject var game: Game
  @State var handicap: Int = 0
  @State var show = false
  
  var body: some View {
    Group {
      VStack {
        Text(game.title)
        
        Stepper("Handicap: \(handicap)", value: $handicap, in: 0...9)
        Button("Start") {
          game.newGame(handicap: handicap)
        }
        
        Button("Open") {
          show.toggle()
        }.sheet(isPresented: $show) {
          DocumentPicker(game: game)
        }
      }
    }
  }
}


struct NewGameView_Previews: PreviewProvider {
  static var previews: some View {
    NewGameView()
  }
}
