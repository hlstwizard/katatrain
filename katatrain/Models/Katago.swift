//
//  Katago.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/10/29.
//

import Foundation
import Combine

class Katago: ObservableObject {
    var engine: Engine
    
    init() {
        engine = Engine.init("Katagob40")
    }
    
    func getColors() -> [NSNumber] {
        return engine.getColors() as! [NSNumber]
    }
    
    func setStoneAndRefresh(loc: Loc, color: CSignedChar) {
        
        objectWillChange.send()
    }
    
}
