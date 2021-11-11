//
//  ControlView.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/11/7.
//

import SwiftUI

struct ControlView: View {
  @EnvironmentObject var katago: Katago
  var body: some View {
    HStack {
      Button(action: undo) {
        Image(systemName: "play")
          .font(.title)
          .rotation3DEffect(.degrees(180.0), axis: (0, 1.0, 0))
      }
      
      Button(action: replay) {
        Image(systemName: "play")
          .font(.title)
      }
      Circle().fill(katago.isThinking ? .red : .green)
        .frame(width: 20.0, height: 20.0)
    }
  }
  
  func undo() {
    katago.undo()
  }
  
  func replay() {
    katago.replay()
  }
}

struct ControlView_Previews: PreviewProvider {
  static var previews: some View {
    ControlView()
  }
}
