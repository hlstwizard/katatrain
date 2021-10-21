//
//  CGPoint+divide.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/10/22.
//

import Foundation
import SwiftUI

extension CGPoint {
    public static func / (lhs: CGPoint, rhs: Double) -> CGPoint {
        return CGPoint(x: lhs.x / CGFloat(rhs), y: lhs.y / CGFloat(rhs))
    }
}
