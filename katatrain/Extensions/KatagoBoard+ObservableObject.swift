//
//  KatagoBoard+ObservableObject.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/10/21.
//

import Foundation
import Combine

extension KatagoBoard: ObservableObject {
    func setStoneAndRefresh(loc: Loc, color: CSignedChar) {
        setStone(loc, color)
        objectWillChange.send()
    }
}
