//
//  Game.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/10/14.
//

import Foundation
import Combine
import CoreML
import Logging

class Game: ObservableObject {
    var boardSize: Int
    var model: Katago
    var pla: Int = Board.BLACK // player
    
    @Published var board: Board?
    
    var logger = Logger(label: #file)
    
    init(_ size: Int = 19) {
        self.boardSize = size
        self.board = Board(boardSize)
        
        self.model = Katago()
    }
}
