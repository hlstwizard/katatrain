//
//  Engine.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/10/22.
//

import Foundation

@available (iOS 15.0, *)
actor Engine {
    init() {
        initialBoard = KatagoBoard()
    }
    
    var initialBoard: KatagoBoard
    
    func setOrResetBoardSize() {
        
    }
    
    func play(loc: Loc, pla: Player) -> Bool {
        return false
    }
    
}
