//
//  IntArray+NSNumber.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/10/14.
//

import Foundation

extension Array where Element == Int {
    func toNSNumberArray() -> [NSNumber] {
        self.map { NSNumber(value: $0) }
    }
}
