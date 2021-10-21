//
//  BoardView+Action.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/10/21.
//

import Foundation

@available(iOS 15.0, *)
extension BoardView {
    func playerMove(point:(x:Int, y: Int), pla: Int=1) {
        let loc = (point.x + 1) + (point.y + 1) * (boardSize + 1)
        board.setStoneAndRefresh(loc: Loc(loc), color: CSignedChar(pla))
//        board.playMove(Loc(loc), Player(pla), true)
    }
}
