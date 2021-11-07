//
//  GameView.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/11/6.
//

import SwiftUI

struct GameView: View {
  @EnvironmentObject var katago: Katago
  @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
  @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
  
  var body: some View {
    Group {
      GeometryReader { reader in
        if reader.size.width > reader.size.height {
          HStack {
            BoardView(size: CGSize(width: reader.size.height, height: reader.size.height))
              .border(.black, width: 3)
            ControlView()
          }
        } else {
          VStack {
            BoardView(size: CGSize(width: reader.size.width, height: reader.size.width))
              .border(.black, width: 3)
            ControlView()
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
