//
//  BorderViewModifier.swift
//  katatrain
//
//  Created by Yiming Huang on 2021/12/12.
//

import Foundation
import SwiftUI

struct BorderViewModifier: ViewModifier {
  func body(content: Content) -> some View {
    content.padding()
      .overlay {
        RoundedRectangle(cornerRadius: 16)
          .stroke(Color.gray, lineWidth: 4)
      }
  }
}

extension View {
  func kataBorder() -> some View {
    self.modifier(BorderViewModifier())
  }
}
