//
//  ControlView.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/11/7.
//

import SwiftUI

struct ControlView: View {
  @EnvironmentObject var game: Game
  
  var body: some View {
    HStack {
      Button(action: undo) {
        Image(systemName: "play")
          .font(.title)
          .rotation3DEffect(.degrees(180.0), axis: (0, 1.0, 0))
      }
//      .disabled(!katago.canUndo)
      
      Button(action: redo) {
        Image(systemName: "play")
          .font(.title)
      }
//      .disabled(!katago.canReplay)
      
//      if katago.inTrial {
//        Button("Exit Try") {
//          katago.exitTrial()
//        }
//      } else {
//        Button("GO Try") {
//          katago.enterTrial()
//        }
//      }
      
      Circle().fill(game.engine.isIdle ? .green : .red)
        .frame(width: 20.0, height: 20.0)
    }
  }
  
  func undo() {
    game.undo()
  }
  
  func redo() {
    game.redo()
  }
}

struct ControlView_Previews: PreviewProvider {
  static var previews: some View {
    ControlView()
  }
}
