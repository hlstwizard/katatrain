//
//  katatrainApp.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/10/11.
//

import SwiftUI
import Logging

@available(iOS 15.0, *)
@main
struct KatatrainApp: App {
  @StateObject var game: Game
  
  init() {
    let engine = Katago()
    #if DEBUG
    _game = StateObject(wrappedValue: Game(engine: engine, sgfFile: "example"))
    
    #else
    _game = StateObject(wrappedValue: Game(engine: engine))
    #endif
    
    Setup.setup()
  }
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(game)
    }
  }
}
