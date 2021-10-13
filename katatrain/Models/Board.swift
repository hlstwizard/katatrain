//
//  Board.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/10/11.
//

import Foundation
import CoreML
import Combine

class Board: ObservableObject {
    static let EMPTY = 0
    static let BLACK = 1
    static let WHITE = 2
    static let WALL = 3
    
    struct Record {
        let pla: Int
        let loc: Int
        let old_simple_ko_point: Int?
        let capDirs: [Int]
        let selfCap: Bool
    }
    
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
    var simple_ko_point: Int?
    
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
    static func get_opp(_ pla: NSNumber) -> Int { return 3 - pla.intValue }
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
        if !self.is_on_board(loc) {
            return false
        }
        if self.board[loc] != Board.EMPTY {
            return false
        }
        if self.would_be_single_stone_suicide(pla, loc) {
            return false
        }
        if loc == self.simple_ko_point {
            return false
        }
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
    
    func is_on_board(_ loc: Int) -> Bool {
        return loc >= 0 && loc < self.arrsize && self.board[loc] != Board.WALL
    }
    
    // Set a given location with error checking. Suicide setting allowed.
    func set_stone(pla: Int, loc: Int) throws {
        if pla != Board.EMPTY && pla != Board.BLACK && pla != Board.WHITE {
            throw BoardError.IllegalMoveError("Invalid pla for board.set")
        }
        if !self.is_on_board(loc) {
            throw BoardError.IllegalMoveError("Invalid loc for board.set")
        }
        
        if self.board[loc] == pla {
            
        } else if self.board[loc] == Board.EMPTY {
            self.add_unsafe(pla, loc)
        } else if pla == Board.EMPTY {
            self.remove_single_stone_unsafe(loc)
        } else {
            self.remove_single_stone_unsafe(loc)
            self.add_unsafe(pla, loc)
        }
        
        // Clear any ko restrictions
        self.simple_ko_point = nil
    }
    
    // Play a stone at the given location, with non-superko legality checking and updating the pla and simple ko point
    // Single stone suicide is disallowed but suicide is allowed, to support rule sets and sgfs that have suicide
    func play(_ pla: Int, _ loc: Int) throws {
        if pla != Board.BLACK && pla != Board.WHITE {
            throw BoardError.IllegalMoveError("Invalid pla for board.play")
        }
        
        if loc != Board.PASS_LOC {
            if !self.is_on_board(loc) {
                throw BoardError.IllegalMoveError("Invalid loc for board.set")
            }
            if self.board[loc] != Board.EMPTY {
                throw BoardError.IllegalMoveError("Location is nonempty")
            }
            if self.would_be_single_stone_suicide(pla, loc) {
                throw BoardError.IllegalMoveError("Move would be illegal single stone suicide")
            }
            if loc == self.simple_ko_point {
                throw BoardError.IllegalMoveError("Move would be illegal simple ko recapture")
            }
        }
        
        self.playUnsafe(pla, loc)
    }
    
    func playUnsafe(_ pla: Int, _ loc: Int) {
        if loc == Board.PASS_LOC {
            self.simple_ko_point = nil
            self.pla = Board.get_opp(pla)
        } else {
            self.add_unsafe(pla, loc)
            self.pla = Board.get_opp(pla)
        }
    }
    
    func playRecordedUnsafe(_ pla: Int, _ loc: Int) -> Record {
        var capDirs: [Int] = []
        let opp = Board.get_opp(pla)
        let old_simple_ko_point = self.simple_ko_point
        for i in 0..<4 {
            let adj = loc + self.adj[i]
            if self.board[adj] == opp && self.group_liberty_count[self.group_head[adj]] == 1 {
                capDirs.append(i)
            }
        }
        
        self.playUnsafe(pla, loc)
        
        // Suicide
        var selfCap = false
        if self.board[loc] == Board.EMPTY {
            selfCap = true
        }
        return Record(pla: pla, loc: loc, old_simple_ko_point: old_simple_ko_point, capDirs: capDirs, selfCap: selfCap)
    }
    
    // Add a stone, assumes that the location is empty without checking
    func add_unsafe(_ pla: Int, _ loc: Int) {
        let opp = Board.get_opp(pla)
        
        // Put the stone down
        self.board[loc] = NSNumber(value: pla)
        self.zobrist ^= Board.ZOBRIST_STONE[pla]![loc]
        
        // Initialize the group for that stone
        self.group_head[loc] = NSNumber(value: loc)
        self.group_stone_count[loc] = 1
        var liberties = 0
        self.adj.forEach { dloc in
            if self.board[loc+dloc] == Board.EMPTY {
                liberties += 1
            }
        }
        
        self.group_liberty_count[loc] = NSNumber(value: liberties)
        self.group_next[loc] = NSNumber(value: loc)
        self.group_prev[loc] = NSNumber(value: loc)
        
        // Fill surrounding liberties of all adjacent groups
        // Carefully avoid doublecounting
        let adj0 = loc + self.adj[0]
        let adj1 = loc + self.adj[1]
        let adj2 = loc + self.adj[2]
        let adj3 = loc + self.adj[3]
        
        if self.board[adj0] == Board.BLACK || self.board[adj0] == Board.WHITE {
            self.group_liberty_count[self.group_head[adj0]] -= 1
        }
        if self.board[adj1] == Board.BLACK || self.board[adj1] == Board.WHITE {
            if self.group_head[adj1] != self.group_head[adj0] {
                self.group_liberty_count[self.group_head[adj1]] -= 1
            }
        }
        if self.board[adj2] == Board.BLACK || self.board[adj2] == Board.WHITE {
            if self.group_head[adj2] != self.group_head[adj0] &&
                self.group_head[adj2] != self.group_head[adj1] {
                self.group_liberty_count[self.group_head[adj2]] -= 1
            }
        }
        if self.board[adj3] == Board.BLACK || self.board[adj3] == Board.WHITE {
            if self.group_head[adj3] != self.group_head[adj0] &&
                self.group_head[adj3] != self.group_head[adj1] &&
                self.group_head[adj3] != self.group_head[adj2] {
                self.group_liberty_count[self.group_head[adj3]] -= 1
            }
        }
        
        // Merge groups
        if self.board[adj0] == pla {
            self.merge_unsafe(loc, adj0)
        }
        if self.board[adj1] == pla {
            self.merge_unsafe(loc, adj1)
        }
        if self.board[adj2] == pla {
            self.merge_unsafe(loc, adj2)
        }
        if self.board[adj3] == pla {
            self.merge_unsafe(loc, adj3)
        }
        
        // Resolve captures
        var opp_stones_captured = 0
        var caploc = 0
        if self.board[adj0] == opp && self.group_liberty_count[self.group_head[adj0]] == 0 {
            opp_stones_captured += self.group_stone_count[self.group_head[adj0]]
            caploc = adj0
            self.remove_unsafe(adj0)
        }
        if self.board[adj1] == opp && self.group_liberty_count[self.group_head[adj1]] == 0 {
            opp_stones_captured += self.group_stone_count[self.group_head[adj1]]
            caploc = adj1
            self.remove_unsafe(adj1)
        }
        if self.board[adj2] == opp && self.group_liberty_count[self.group_head[adj2]] == 0 {
            opp_stones_captured += self.group_stone_count[self.group_head[adj2]]
            caploc = adj2
            self.remove_unsafe(adj2)
        }
        if self.board[adj3] == opp && self.group_liberty_count[self.group_head[adj3]] == 0 {
            opp_stones_captured += self.group_stone_count[self.group_head[adj3]]
            caploc = adj3
            self.remove_unsafe(adj3)
        }
        
        // Suicide
        if self.group_liberty_count[self.group_head[loc]] == 0 {
            self.remove_unsafe(loc)
        }
        
        // Update ko point for legality checking
        if opp_stones_captured == 1 &&
            self.group_stone_count[self.group_head[loc]] == 1 &&
            self.group_liberty_count[self.group_head[loc]] == 1 {
            self.simple_ko_point = caploc
        } else {
            self.simple_ko_point = nil
        }
    }
    
    // Apply the specified delta to the liberties of all adjacent groups of the specified color
    func changeSurroundingLiberties(_ loc: Int, _ pla: Int, _ delta: Int) {
        // Carefully avoid doublecounting
        let adj0 = loc + self.adj[0]
        let adj1 = loc + self.adj[1]
        let adj2 = loc + self.adj[2]
        let adj3 = loc + self.adj[3]
        if self.board[adj0] == pla {
            self.group_liberty_count[self.group_head[adj0]] += delta
        }
        if self.board[adj1] == pla {
            if self.group_head[adj1] != self.group_head[adj0] {
                self.group_liberty_count[self.group_head[adj1]] += delta
            }
        }
        if self.board[adj2] == pla {
            if self.group_head[adj2] != self.group_head[adj0] &&
                self.group_head[adj2] != self.group_head[adj1] {
                self.group_liberty_count[self.group_head[adj2]] += delta
            }
        }
        if self.board[adj3] == pla {
            if self.group_head[adj3] != self.group_head[adj0] &&
                self.group_head[adj3] != self.group_head[adj1] &&
                self.group_head[adj3] != self.group_head[adj2] {
                self.group_liberty_count[self.group_head[adj3]] += delta
            }
        }
    }
    
    func countImmediateLiberties(_ loc: Int) -> Int {
        let adj0 = loc + self.adj[0]
        let adj1 = loc + self.adj[1]
        let adj2 = loc + self.adj[2]
        let adj3 = loc + self.adj[3]
        var count = 0
        if self.board[adj0] == Board.EMPTY {
            count += 1
        }
        if self.board[adj1] == Board.EMPTY {
            count += 1
        }
        if self.board[adj2] == Board.EMPTY {
            count += 1
        }
        if self.board[adj3] == Board.EMPTY {
            count += 1
        }
        return count
    }
    
    func is_group_adjacent(_ head: NSNumber, _ loc: Int) -> Bool {
        return (
            self.group_head[loc+self.adj[0]] == head ||
            self.group_head[loc+self.adj[1]] == head ||
            self.group_head[loc+self.adj[2]] == head ||
            self.group_head[loc+self.adj[3]] == head
        )
    }
    
    // Helper, merge two groups assuming they're owned by the same player and adjacent
    func merge_unsafe(_ loc0: Int, _ loc1: Int) {
        var parent: Int?
        var child: Int?
        if self.group_stone_count[self.group_head[loc0]] >= self.group_stone_count[self.group_head[loc1]] {
            parent = loc0
            child = loc1
        } else {
            child = loc0
            parent = loc1
        }
        
        let phead = self.group_head[parent!]
        let chead = self.group_head[child!]
        if phead == chead {
            return
        }
        
        // Walk the child group assigning the new head and simultaneously counting liberties
        let new_stone_count = self.group_stone_count[phead].intValue + self.group_stone_count[chead].intValue
        var new_liberties = self.group_liberty_count[phead]
        var loc = child!
        while true {
            let adj0 = loc + self.adj[0]
            let adj1 = loc + self.adj[1]
            let adj2 = loc + self.adj[2]
            let adj3 = loc + self.adj[3]
            
            // Any adjacent empty space is a new liberty as long as it isn't adjacent to the parent
            if self.board[adj0] == Board.EMPTY && !self.is_group_adjacent(phead, adj0) {
                new_liberties += 1
            }
            if self.board[adj1] == Board.EMPTY && !self.is_group_adjacent(phead, adj1) {
                new_liberties += 1
            }
            
            if self.board[adj2] == Board.EMPTY && !self.is_group_adjacent(phead, adj2) {
                new_liberties += 1
            }
            if self.board[adj3] == Board.EMPTY && !self.is_group_adjacent(phead, adj3) {
                new_liberties += 1
            }
            
            // Now assign the new parent head to take over the child (this also
            // prevents double-counting liberties)
            self.group_head[loc] = phead
            
            // Advance around the linked list
            loc = self.group_next[loc].intValue
            if loc == child {
                break
            }
        }
        
        // Zero out the old head
        self.group_stone_count[chead] = 0
        self.group_liberty_count[chead] = 0
        
        // Update the new head
        self.group_stone_count[phead] = NSNumber(value: new_stone_count)
        self.group_liberty_count[phead] = new_liberties
        
        // Combine the linked lists
        let plast = self.group_prev[phead]
        let clast = self.group_prev[chead]
        self.group_next[clast] = phead
        self.group_next[plast] = chead
        self.group_prev[chead] = plast
        self.group_prev[phead] = clast
    }
    
    // Remove all stones in a group
    func remove_unsafe(_ group: Int) {
        let head = self.group_head[group]
        let pla = self.board[group]
        let opp = Board.get_opp(pla.intValue)
        
        // Walk all the stones in the group and delete them
        var loc = group
        while true {
            // Add a liberty to all surrounding opposing groups, taking care to avoid double counting
            let adj0 = loc + self.adj[0]
            let adj1 = loc + self.adj[1]
            let adj2 = loc + self.adj[2]
            let adj3 = loc + self.adj[3]
            if self.board[adj0] == opp {
                self.group_liberty_count[self.group_head[adj0]] += 1
            }
            if self.board[adj1] == opp {
                if self.group_head[adj1] != self.group_head[adj0] {
                    self.group_liberty_count[self.group_head[adj1]] += 1
                }
            }
            if self.board[adj2] == opp {
                if self.group_head[adj2] != self.group_head[adj0] &&
                    self.group_head[adj2] != self.group_head[adj1] {
                    self.group_liberty_count[self.group_head[adj2]] += 1
                }
            }
            if self.board[adj3] == opp {
                if self.group_head[adj3] != self.group_head[adj0] &&
                    self.group_head[adj3] != self.group_head[adj1] &&
                    self.group_head[adj3] != self.group_head[adj2] {
                    self.group_liberty_count[self.group_head[adj3]] += 1
                }
            }
            
            let next_loc = self.group_next[loc]
            
            // Zero out all the stuff
            self.board[loc] = NSNumber(value: Board.EMPTY)
            self.zobrist ^= Board.ZOBRIST_STONE[opp]![loc]
            self.group_head[loc] = 0
            self.group_next[loc] = 0
            self.group_prev[loc] = 0
            
            // Advance around the linked list
            loc = next_loc.intValue
            if loc == group {
                break
            }
        }
        
        // Zero out the head
        self.group_stone_count[head] = 0
        self.group_liberty_count[head] = 0
    }
    
    // Remove a single stone
    func remove_single_stone_unsafe(_ rloc: Int) {
        let pla = self.board[rloc]
        
        // Record all the stones in the group
        var stones: [Int] = []
        var loc = rloc
        while true {
            stones.append(loc)
            loc = self.group_next[loc].intValue
            if loc == rloc {
                break
            }
        }
        
        // Remove them all
        self.remove_unsafe(rloc)
        
        // Then add them back one by one
        stones.forEach { loc in
            if loc != rloc {
                self.add_unsafe(pla.intValue, loc)
            }
        }
    }
    
    // Helper, find liberties of group at loc. Fills in buf.
    func findLiberties(_ loc: Int, _ buf: inout [Int]) {
        var cur = loc
        while true {
            for i in 0..<4 {
                let lib = cur + self.adj[i]
                if self.board[lib] == Board.EMPTY {
                    if !buf.contains(lib) {
                        buf.append(lib)
                    }
                }
            }
            
            cur = self.group_next[cur].intValue
            if cur == loc {
                break
            }
        }
    }
    
    // Helper, find captures that gain liberties for the group at loc. Fills in buf
    func findLibertyGainingCaptures(_ loc: Int, buf: inout [Int]) {
        let pla = self.board[loc]
        let opp = Board.get_opp(pla)
        
        // For performance, avoid checking for captures on any chain twice
        var chainHeadsChecked: [NSNumber] = []
        
        var cur = loc
        while true {
            for i in 0..<4 {
                let adj = cur + self.adj[i]
                if self.board[adj] == opp {
                    let head = self.group_head[adj]
                    
                    if self.group_liberty_count[head] == 1 {
                        if !chainHeadsChecked.contains(head) {
                            // Capturing moves are precisely the liberties of the groups around us with 1 liberty.
                            self.findLiberties(adj, &buf)
                            chainHeadsChecked.append(head)
                        }
                    }
                }
            }
            
            cur = self.group_next[cur].intValue
            if cur == loc {
                break
            }
        }
    }
    
    // Helper, does the group at loc have at least one opponent group adjacent to it in atari?
    func hasLibertyGainingCaptures(_ loc: Int) -> Bool {
        let pla = self.board[loc]
        let opp = Board.get_opp(pla)
        
        var cur = loc
        while true {
            for i in 0..<4 {
                let adj = cur + self.adj[i]
                if self.board[adj] == opp {
                    let head = self.group_head[adj]
                    if self.group_liberty_count[head] == 1 {
                        return true
                    }
                }
            }
            
            cur = self.group_next[cur].intValue
            if cur == loc {
                break
            }
        }
        
        return false
    }
}
