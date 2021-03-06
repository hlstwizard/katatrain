//
//  GameView.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/11/6.
//

import SwiftUI

struct GameView: View {
  @EnvironmentObject var game: Game
  @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
  @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
  
  private let controlHeight: CGFloat = 60.0
  
  var body: some View {
    Group {
      GeometryReader { reader in
        let minWidth = min(reader.size.width, reader.size.height)
        let maxHeight = min(reader.size.width, reader.size.height)
        
        if reader.size.width > reader.size.height {
          HStack {
            VStack {
              BoardView().frame(minWidth: minWidth)
                .padding(.leading, 10)
              ControlView()
            }
            NewGameView()
          }
        } else {
          VStack {
            BoardView().frame(maxHeight: maxHeight)
              .padding(10)
            ControlView()
            StatusView()
          }
        }
      }
    }
  }
}

struct GameView_Previews: PreviewProvider {
  static var previews: some View {
    GameView()
  }
}
