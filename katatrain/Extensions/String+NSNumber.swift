//
//  String+NSNumber.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/10/12.
//

import Foundation

extension String {
    init(value: NSNumber) {
        self.init(value.intValue)
    }
}
