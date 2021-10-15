//
//  NSNumber+Int.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/10/11.
//

import Foundation

extension NSNumber: Comparable {
    public static func < (lhs: NSNumber, rhs: NSNumber) -> Bool {
        return lhs.intValue < rhs.intValue
    }
    
    static func == (lhs: NSNumber, rhs: Int) -> Bool {
        return lhs.intValue == rhs
    }

    static func != (lhs: NSNumber, rhs: Int) -> Bool {
        return lhs.intValue != rhs
    }
    
    static func -= (lhs: inout NSNumber, rhs: Int) {
        lhs = NSNumber(value: lhs.intValue - rhs)
    }
    
    static func += (lhs: inout NSNumber, rhs: Int) {
        lhs = NSNumber(value: lhs.intValue + rhs)
    }
}
