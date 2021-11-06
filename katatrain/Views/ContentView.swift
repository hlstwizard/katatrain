//
//  ContentView.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/10/11.
//

import SwiftUI

@available(iOS 15.0, *)
struct ContentView: View {
  @EnvironmentObject var katago: Katago
  
  var body: some View {
    ZStack {
      GameView()
      if !katago.initFinished {
        LandingView()
          .transition(.asymmetric(insertion: .move(edge: .top), removal: .opacity))
          .animation(.easeInOut(duration: 3), value: katago.initFinished)
      }
    }
  }
}

@available(iOS 15.0, *)
struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
