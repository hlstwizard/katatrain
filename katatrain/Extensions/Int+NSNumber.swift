//
//  Int+NSNumber.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/10/11.
//

import Foundation

extension Int {
    static func == (lhs: Int, rhs: NSNumber) -> Bool {
        return lhs == rhs.intValue
    }
}
