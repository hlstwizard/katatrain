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


func var_to_grid<T>(array: [T], size: (Int, Int)) -> [[T]] {
  var ix = 0
  var grid = Array<[T]>(repeating: [], count: size.1)
  for y in stride(from: size.1-1, to: -1, by: -1) {
    grid[y] = Array(array[ix..<ix + size.0])
    ix += size.0
  }
  return grid
}
