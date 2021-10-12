//
//  MLMultiArray+subscript.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/10/12.
//

import CoreML

extension MLMultiArray {
    subscript(index: NSNumber) -> NSNumber {
        get {
            return self[index.intValue]
        }
        set(newValue) {
            self[index.intValue] = newValue
        }
    }
}
