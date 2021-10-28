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
    init() {
        Setup.setup()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
