//
//  RightView.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/11/10.
//

import SwiftUI
import SwiftUICharts

struct StatusView: View {
  @EnvironmentObject var katago: Katago
  
  var body: some View {

    Picker(selection: $katago.mode, label: Text("")) {
      Text("Play").tag(0)
      Text("Analysis").tag(1)
    }.pickerStyle(SegmentedPickerStyle())

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
