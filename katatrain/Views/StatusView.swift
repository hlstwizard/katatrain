//
//  RightView.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/11/10.
//

import SwiftUI

struct StatusView: View {
  @EnvironmentObject var katago: Katago
  
  var body: some View {
    Button("New Game") {
      katago.reset()
    }
  }
}

struct StatusView_Previews: PreviewProvider {
  static var previews: some View {
    StatusView()
  }
}
