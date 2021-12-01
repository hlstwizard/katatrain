//
//  NewGameView.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/11/12.
//

import SwiftUI

struct NewGameView: View {
  @EnvironmentObject var game: Game
  @State var handicap: UInt8 = 0
  
  var body: some View {
    Group {
      VStack {
        Stepper("Handicap: \(handicap)", value: $handicap, in: 0...9)
        Button("Start") {
//          katago.newGame(handicap: handicap)
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
