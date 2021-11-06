//
//  LandingView.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/11/6.
//

import SwiftUI

struct LandingView: View {
    var body: some View {
      ZStack {
        Rectangle().fill(.white)
        Text("Katatrain").bold().font(.largeTitle)
      }
    }
}

struct LandingView_Previews: PreviewProvider {
    static var previews: some View {
        LandingView()
    }
}
