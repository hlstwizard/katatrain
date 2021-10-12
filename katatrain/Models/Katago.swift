//
//  Katago.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/10/11.
//

import CoreML

class Katago {
    internal init() {
        do {
            self.model = try katagob40(configuration: .init())
        } catch {
            self.model = katagob40()
        }
    }

    func play() {

    }

    var model: katagob40
}
