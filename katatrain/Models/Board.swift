//
//  Board.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/10/11.
//

import Foundation
import CoreML

class Board {
    static let EMPTY = 0
    static let BLACK = 1
    static let WHITE = 2
    static let WALL = 3
    
    static var ZOBRIST_STONE : [Int: [Int]] = [
        Board.EMPTY : [],
        Board.BLACK : [],
        Board.WHITE : [],
        Board.WALL: []
    ]
    static var ZOBRIST_PLA:[Int] = []
    
    var ZOBRIST_RAND = SystemRandomNumberGenerator()
    var PASS_LOC = 0
    
    var size = 19
    var arrsize: Int {
        return (size+1)*(size+2)+1
    }
    var dy: Int {
        return size + 1
    }
    var adj: [Int] {
        return [-dy, -1, 1, dy]
    }
    var diag: [Int] {
        return [-dy-1, -dy+1, dy-1, dy+1]
    }
    var pla = Board.BLACK
    
    var board : MLMultiArray! = nil
    var group_head: MLMultiArray! = nil
    var group_stone_count: MLMultiArray! = nil
    var group_liberty_count : MLMultiArray! = nil
    var group_next: MLMultiArray! = nil
    var group_prev: MLMultiArray! = nil
    var zobrist = 0
    
    init() {
        for _ in 0..<(19+1)*(19+2)+1 {
            Board.ZOBRIST_STONE[Board.BLACK]!.append(Int.random(in: Int.min..<Int.max))
            Board.ZOBRIST_STONE[Board.WHITE]!.append(Int.random(in: Int.min..<Int.max))
        }
        for _ in 0..<4 {
            Board.ZOBRIST_PLA.append(Int.random(in: Int.min..<Int.max))
        }
        
        // TODO: - data type might be float as defined in the input and output
        board = try! MLMultiArray(shape: [NSNumber(value: arrsize)], dataType: .int32)
        group_head = try! MLMultiArray(shape: [NSNumber(value: arrsize)], dataType: .int32)
        group_stone_count = try! MLMultiArray(shape: [NSNumber(value: arrsize)], dataType: .int32)
        group_liberty_count = try! MLMultiArray(shape: [NSNumber(value: arrsize)], dataType: .int32)
        group_next = try! MLMultiArray(shape: [NSNumber(value: arrsize)], dataType: .int32)
        group_prev = try! MLMultiArray(shape: [NSNumber(value: arrsize)], dataType: .int32)
        
        for i in -1..<size+1 {
            board[self.loc(x: i, y: -1)] = NSNumber(value: Board.WALL)
            board[self.loc(x: i, y: size)] = NSNumber(value: Board.WALL)
            board[self.loc(x: -1, y: i)] = NSNumber(value: Board.WALL)
            board[self.loc(x: size, y: i)] = NSNumber(value: Board.WALL)
        }
        
        self.group_head[0] = NSNumber(value: -1)
        self.group_next[0] = NSNumber(value: -1)
        self.group_prev[0] = NSNumber(value: -1)
    }
    
    static func get_opp(pla: Int) -> Int { return 3 - pla }
    static func loc_static(x: Int, y: Int, size: Int) -> Int { return (x+1) + (size+1)*(y+1) }
    
    
    func loc(x: Int, y: Int) -> Int {
        (x + 1) + dy*(y+1)
    }
    
    func loc_x(loc: Int) -> Int {
        (loc % dy) - 1
    }
    
    func loc_y(loc: Int) -> Int {
        (loc / dy) - 1
    }
    
    func is_adjacent(loc1: Int,loc2: Int) -> Bool {
      return loc1 == loc2 + adj[0] ||
        loc1 == loc2 + adj[1] ||
        loc1 == loc2 + adj[2] ||
        loc1 == loc2 + adj[3]
    }
    
    func pos_zobrist() -> Int {
        return zobrist
    }
    
    func sit_zobrist() -> Int {
        return zobrist ^ Board.ZOBRIST_PLA[pla]
    }

    func num_liberties(loc: Int) -> Int {
        if (self.board[loc] == NSNumber(value: Board.EMPTY) ||
            self.board[loc] == NSNumber(value: Board.WALL)) {
            return 0
        }
        
        return self.group_liberty_count[self.group_head[loc].intValue].intValue
    }
    
    func is_simple_eye(pla: Int, loc: Int) -> Bool {
        let adj0 = loc + self.adj[0]
        let adj1 = loc + self.adj[1]
        let adj2 = loc + self.adj[2]
        let adj3 = loc + self.adj[3]

        if ((self.board[adj0] != pla && self.board[adj0] != Board.WALL) ||
           (self.board[adj1] != pla && self.board[adj1] != Board.WALL) ||
           (self.board[adj2] != pla && self.board[adj2] != Board.WALL) ||
            (self.board[adj3] != pla && self.board[adj3] != Board.WALL)) {
            return false
        }
          
        let opp = Board.get_opp(pla: pla)
        var opp_corners = 0
        let diag0 = loc + self.diag[0]
        let diag1 = loc + self.diag[1]
        let diag2 = loc + self.diag[2]
        let diag3 = loc + self.diag[3]
        if (self.board[diag0] == opp) {
          opp_corners += 1
        }
        if (self.board[diag1] == opp) {
          opp_corners += 1
        }
        if (self.board[diag2] == opp) {
          opp_corners += 1
        }
        if (self.board[diag3] == opp) {
          opp_corners += 1
        }
        
        if (opp_corners >= 2) {
          return false
        }
        if (opp_corners <= 0) {
          return true
        }

        let against_wall = self.board[adj0] == Board.WALL ||
          self.board[adj1] == Board.WALL ||
          self.board[adj2] == Board.WALL ||
          self.board[adj3] == Board.WALL

        if (against_wall) {
          return false
        }
        return true
    }
}
