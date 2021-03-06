//
//  NewGameView.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/11/12.
//

import SwiftUI

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
