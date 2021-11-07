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
    Circle().fill(katago.isThinking ? .red : .green)
      .frame(width: 20.0, height: 20.0)
  }
}

struct ControlView_Previews: PreviewProvider {
  static var previews: some View {
    ControlView()
  }
}
