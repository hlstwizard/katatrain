//
//  NSNumber+Int.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/10/11.
//

import Foundation

extension NSNumber {
    static func ==(lhs: NSNumber, rhs: Int) -> Bool {
        return lhs.intValue == rhs
    }
    
    static func !=(lhs: NSNumber, rhs: Int) -> Bool {
        return lhs.intValue != rhs
    }
}
