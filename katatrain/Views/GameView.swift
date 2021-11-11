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
  
  private let controlHeight: CGFloat = 60.0
  
  var body: some View {
    Group {
      GeometryReader { reader in
        if reader.size.width > reader.size.height {
          HStack {
            VStack {
              BoardView(size: CGSize(width: reader.size.height - controlHeight, height: reader.size.height - controlHeight))
                .padding(.leading, 10)
              ControlView()
            }
            StatusView()
          }
        } else {
          VStack {
            BoardView(size: CGSize(width: reader.size.width, height: reader.size.width))
              .border(.black, width: 3)
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
