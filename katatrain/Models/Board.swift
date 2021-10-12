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
    
    static var ZOBRIST_STONE: [Int: [Int]] = [
        Board.EMPTY: [],
        Board.BLACK: [],
        Board.WHITE: [],
        Board.WALL: []
    ]
    static var ZOBRIST_PLA: [Int] = []
    static var PASS_LOC = 0
    
    var ZOBRIST_RAND = SystemRandomNumberGenerator()
    
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
    
    var board: MLMultiArray! = nil
    var group_head: MLMultiArray! = nil
    var group_stone_count: MLMultiArray! = nil
    var group_liberty_count: MLMultiArray! = nil
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
            board[self.loc(i, -1)] = NSNumber(value: Board.WALL)
            board[self.loc(i, size)] = NSNumber(value: Board.WALL)
            board[self.loc(-1, i)] = NSNumber(value: Board.WALL)
            board[self.loc(size, i)] = NSNumber(value: Board.WALL)
        }
        
        self.group_head[0] = NSNumber(value: -1)
        self.group_next[0] = NSNumber(value: -1)
        self.group_prev[0] = NSNumber(value: -1)
    }
    
    static func get_opp(_ pla: Int) -> Int { return 3 - pla }
    static func loc_static(x: Int, y: Int, size: Int) -> Int { return (x+1) + (size+1)*(y+1) }
    
    func loc(_ x: Int, _ y: Int) -> Int {
        (x + 1) + dy*(y+1)
    }
    
    func loc_x(_ loc: Int) -> Int {
        (loc % dy) - 1
    }
    
    func loc_y(_ loc: Int) -> Int {
        (loc / dy) - 1
    }
    
    func is_adjacent(loc1: Int, loc2: Int) -> Bool {
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
    
    func num_liberties(_ loc: Int) -> Int {
        if self.board[loc] == NSNumber(value: Board.EMPTY) ||
            self.board[loc] == NSNumber(value: Board.WALL) {
            return 0
        }
        
        return self.group_liberty_count[self.group_head[loc].intValue].intValue
    }
    
    func is_simple_eye(pla: Int, loc: Int) -> Bool {
        let adj0 = loc + self.adj[0]
        let adj1 = loc + self.adj[1]
        let adj2 = loc + self.adj[2]
        let adj3 = loc + self.adj[3]
        
        if (self.board[adj0] != pla && self.board[adj0] != Board.WALL) ||
            (self.board[adj1] != pla && self.board[adj1] != Board.WALL) ||
            (self.board[adj2] != pla && self.board[adj2] != Board.WALL) ||
            (self.board[adj3] != pla && self.board[adj3] != Board.WALL) {
            return false
        }
        
        let opp = Board.get_opp(pla)
        var opp_corners = 0
        let diag0 = loc + self.diag[0]
        let diag1 = loc + self.diag[1]
        let diag2 = loc + self.diag[2]
        let diag3 = loc + self.diag[3]
        if self.board[diag0] == opp {
            opp_corners += 1
        }
        if self.board[diag1] == opp {
            opp_corners += 1
        }
        if self.board[diag2] == opp {
            opp_corners += 1
        }
        if self.board[diag3] == opp {
            opp_corners += 1
        }
        
        if opp_corners >= 2 {
            return false
        }
        if opp_corners <= 0 {
            return true
        }
        
        let against_wall = self.board[adj0] == Board.WALL ||
        self.board[adj1] == Board.WALL ||
        self.board[adj2] == Board.WALL ||
        self.board[adj3] == Board.WALL
        
        if against_wall {
            return false
        }
        return true
    }
    
    func would_be_legal(pla: Int, loc: Int) -> Bool {
        if pla != Board.BLACK && pla != Board.WHITE {
            return false
        }
        if loc == Board.PASS_LOC {
            return true
        }
        if !self.is_on_board(loc: loc) {
            return false
        }
        if self.board[loc] != Board.EMPTY {
            return false
        }
        if self.would_be_single_stone_suicide(pla, loc) {
            return false
        }
        // TODO: - simple ko point
        //        if (loc == self.simple_ko_point) {
        //          return false
        //        }
        return true
    }
    
    func would_be_suicide(pla: Int, loc: Int) -> Bool {
        let adj0 = loc + self.adj[0]
        let adj1 = loc + self.adj[1]
        let adj2 = loc + self.adj[2]
        let adj3 = loc + self.adj[3]
        
        let opp = Board.get_opp(pla)
        
        // If empty or capture, then not suicide
        if self.board[adj0] == Board.EMPTY || (self.board[adj0] == opp && self.group_liberty_count[self.group_head[adj0]] == 1) ||
            self.board[adj1] == Board.EMPTY || (self.board[adj1] == opp && self.group_liberty_count[self.group_head[adj1]] == 1) ||
            self.board[adj2] == Board.EMPTY || (self.board[adj2] == opp && self.group_liberty_count[self.group_head[adj2]] == 1) ||
            self.board[adj3] == Board.EMPTY || (self.board[adj3] == opp && self.group_liberty_count[self.group_head[adj3]] == 1) {
            return false
        }
        // If connects to own stone with enough liberties, then not suicide
        if self.board[adj0] == pla && self.group_liberty_count[self.group_head[adj0]] > 1 ||
            self.board[adj1] == pla && self.group_liberty_count[self.group_head[adj1]] > 1 ||
            self.board[adj2] == pla && self.group_liberty_count[self.group_head[adj2]] > 1 ||
            self.board[adj3] == pla && self.group_liberty_count[self.group_head[adj3]] > 1 {
            return false
        }
        
        return true
    }
    
    func would_be_single_stone_suicide(_ pla: Int, _ loc: Int) -> Bool {
        let adj0 = loc + self.adj[0]
        let adj1 = loc + self.adj[1]
        let adj2 = loc + self.adj[2]
        let adj3 = loc + self.adj[3]
        
        let opp = Board.get_opp(pla)
        
        // If empty or capture, then not suicide
        if self.board[adj0] == Board.EMPTY || (self.board[adj0] == opp && self.group_liberty_count[self.group_head[adj0]] == 1) ||
            self.board[adj1] == Board.EMPTY || (self.board[adj1] == opp && self.group_liberty_count[self.group_head[adj1]] == 1) ||
            self.board[adj2] == Board.EMPTY || (self.board[adj2] == opp && self.group_liberty_count[self.group_head[adj2]] == 1) ||
            self.board[adj3] == Board.EMPTY || (self.board[adj3] == opp && self.group_liberty_count[self.group_head[adj3]] == 1) {
            return false
        }
        // If connects to own stone, then not single stone suicide
        if self.board[adj0] == pla ||
            self.board[adj1] == pla ||
            self.board[adj2] == pla ||
            self.board[adj3] == pla {
            return false
        }
        return true
    }
    
    // Returns the number of liberties a new stone placed here would have, or maxLibs if it would be >= maxLibs.
    func get_liberties_after_play(pla: Int, loc: Int, maxLibs: Int) -> Int {
        let opp = Board.get_opp(pla)
        var libs: [Int] = []
        var capturedGroupHeads: [NSNumber] = []
        
        // First, count immediate liberties and groups that would be captured
        for i in 0..<4 {
            let adj = loc + self.adj[i]
            if self.board[adj] == Board.EMPTY {
                libs.append(adj)
                if libs.count >= maxLibs {
                    return maxLibs
                }
            } else if self.board[adj] == opp && self.num_liberties(adj) == 1 {
                libs.append(adj)
                if libs.count >= maxLibs {
                    return maxLibs
                }
                let head = self.group_head[adj]
                if !capturedGroupHeads.contains(head) {
                    capturedGroupHeads.append(head)
                }
            }
        }
        
        func wouldBeEmpty(_ possibleLib: Int) -> Bool {
            if self.board[possibleLib] == Board.EMPTY {
                return true
            } else if self.board[possibleLib] == opp {
                return capturedGroupHeads.contains(self.group_head[possibleLib])
            }
            return false
        }
        
        // Next, walk through all stones of all surrounding groups we would connect with and count liberties, avoiding overlap.
        var connectingGroupHeads: [NSNumber] = []
        for i in 0..<4 {
            let adj = loc + self.adj[i]
            if self.board[adj] == pla {
                let head = self.group_head[adj]
                
                if !connectingGroupHeads.contains(head) {
                    connectingGroupHeads.append(head)
                    
                    let cur = adj
                    while true {
                        for k in 0..<4 {
                            let possibleLib = cur + self.adj[k]
                            if possibleLib != loc && wouldBeEmpty(possibleLib) && !libs.contains(possibleLib) {
                                libs.append(possibleLib)
                                
                                if libs.count >= maxLibs {
                                    return maxLibs
                                }
                            }
                        }
                        
                        if self.group_next[cur] == adj { break }
                    }
                }
            }
        }
        
        return libs.count
    }
    
    func to_string() -> String {
        func get_piece(_ x: Int, _ y: Int) -> String {
            let loc = self.loc(x, y)
            if self.board[loc] == Board.BLACK {
                return "X "
            } else if self.board[loc] == Board.WHITE {
                return "O "
            } else if (x == 3 || x == self.size/2 || x == self.size-1-3) && (y == 3 || y == self.size/2 || y == self.size-1-3) {
                return "* "
            } else {
                return ". "
            }
        }
        
        var lines: [String] = []
        for i in (0..<self.size) {
            var line: [String] = []
            for j in (0..<self.size) {
                line.append(get_piece(j, i))
            }
            
            lines.append(line.joined(separator: ""))
        }
        
        return lines.joined(separator: "\n")
    }
    
    func to_liberty_string() -> String {
        func get_piece(_ x: Int, _ y: Int) -> String {
            let loc = self.loc(x, y)
            if self.board[loc] == Board.BLACK || self.board[loc] == Board.WHITE {
                let libs = self.group_liberty_count[self.group_head[loc]]
                if libs <= 9 {
                    return "\(libs.intValue) "
                } else {
                    return "@ "
                }
            } else if (x == 3 || x == self.size/2 || x == self.size-1-3) && (y == 3 || y == self.size/2 || y == self.size-1-3) {
                return "* "
            } else {
                return ". "
            }
        }
        
        var lines: [String] = []
        for i in (0..<self.size) {
            var line: [String] = []
            for j in (0..<self.size) {
                line.append(get_piece(j, i))
            }
            
            lines.append(line.joined(separator: ""))
        }
        
        return lines.joined(separator: "\n")
    }
    
    func set_pla(pla: Int) {
        self.pla = pla
    }
    
    func is_on_board(loc: Int) -> Bool {
        return loc >= 0 && loc < self.arrsize && self.board[loc] != Board.WALL
    }
    
}
