//
//  MLMultiArray+subscript.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/10/12.
//

import CoreML

extension MLMultiArray {
    subscript(index: NSNumber) -> NSNumber {
        return self[index.intValue]
    }
}
