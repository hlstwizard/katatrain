//
//  Utils.swift
//  katatrain
//
//  Created by Yiming Huang on 2021/12/4.
//

import Foundation


func unzip<K, V>(_ array: [(K, V)]) -> ([K], [V]) {
    var first = [K]()
    var second = [V]()

    first.reserveCapacity(array.count)
    second.reserveCapacity(array.count)

    array.forEach {
      first.append($0.0)
      second.append($0.1)
    }

    return (first, second)
}
