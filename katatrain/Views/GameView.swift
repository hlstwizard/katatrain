//
//  GameView.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/11/6.
//

import SwiftUI

struct GameView: View {
  @EnvironmentObject var katago: Katago
  
  var body: some View {
    HStack {
      BoardView()
        .border(.black, width: 3)
      Circle().fill(katago.isThinking ? .red : .green)
        .frame(width: 20.0, height: 20.0)
    }
  }
}

struct GameView_Previews: PreviewProvider {
  static var previews: some View {
    GameView()
  }
}
