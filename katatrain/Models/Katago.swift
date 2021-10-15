//
//  Katago.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/10/11.
//

import CoreML

typealias Move = (Int, Int?) // pla, loc

class Katago {
    var model: katagob40
    let version: Int
    let pos_len: Int
    
    static func get_num_global_input_features(_ version: Int) -> NSNumber {
        if version == 4 {
            return NSNumber(value: 14)
        } else if version == 5 {
            return NSNumber(value: 14)
        } else if version == 6 {
            return NSNumber(value: 12)
        } else if version == 7 {
            return NSNumber(value: 16)
        } else if version <= 10 {
            return NSNumber(value: 19)
        } else {
            fatalError("unsupported version")
        }
    }
    
    static func get_num_bin_input_features(_ version: Int) -> NSNumber {
        if version == 4 {
            return NSNumber(value: 22)
        } else if version == 5 {
            return NSNumber(value: 22)
        } else if version == 6 {
            return NSNumber(value: 13)
        } else if version <= 10 {
            return NSNumber(value: 22)
        } else {
            fatalError("unsupported version")
        }
    }
    
    func xy_to_tensor_pos(_ x: Int, _ y: Int) -> Int {
        y * pos_len + x
    }
    
    func loc_to_tensor_pos(_ loc: Int, _ board: Board) -> Int {
      assert(loc != Board.PASS_LOC)
      return board.loc_y(loc) * self.pos_len + board.loc_x(loc)
    }
    
    internal init(pos_len: Int = 19, version: Int = 10) {
        let config = MLModelConfiguration()
        
        self.pos_len = pos_len
        self.version = version
        
        do {
            self.model = try katagob40(configuration: config)
        } catch {
            fatalError("Error loading katago model")
        }
    }
    
    // TODO: - Unfinished
    func fetch_output(gs: Game) {
        let global_input_data_shape = [
            NSNumber(value: 1),
            Katago.get_num_global_input_features(version)
        ]
        
        let bin_input_data_shape = [
            NSNumber(value: 1),
            NSNumber(value: pos_len * pos_len),
            Katago.get_num_bin_input_features(version)
        ]
        var global_input_data = try! MLMultiArray(shape: global_input_data_shape, dataType: .float32)
        var bin_input_data = try! MLMultiArray(shape: bin_input_data_shape, dataType: .float32)
        
    }
    
    // TODO: - Unfinished
    func iterLadders(_ board: Board, f: (Int, Int, inout [Int]) -> Void) {
        
        let copy = Board(copyFrom: board)
        
        let bsize = board.size
        assert(pos_len >= bsize)
        
        for y in 0..<bsize {
            for x in 0..<bsize {
                let pos = xy_to_tensor_pos(x, y)
                let loc = board.loc(x, y)
                let stone = board.board[loc]
                
                if stone == Board.BLACK || stone == Board.WHITE {
                    let libs = board.num_liberties(loc)
                    if libs == 1 || libs == 2 {
                        let head = board.group_head[loc]
                        
                    }
                }
            }
        }
    }
    
    // TODO: - Unfinished
    func fill_row_features(version: Int,
                           board: Board,
                           pla: Int,
                           opp: Int,
                           moves: [Move],
                           move_idx: Int,
                           bin_input_data: inout MLMultiArray,
                           global_input_data: inout MLMultiArray,
                           idx: Int = 0
    ) {
        func addLadderFeature(_ loc: Int, _ pos: Int, _ workingMoves: inout [Int]) {
            assert(board.board[loc] == Board.BLACK || board.board[loc] == Board.WHITE)
            bin_input_data[[idx, pos, 14].toNSNumberArray()] = 1.0
            if board.board[loc] == opp && board.num_liberties(loc) > 1 {
                workingMoves.forEach { workingMove in
                    let workingPos = self.loc_to_tensor_pos(workingMove, board)
                    bin_input_data[[idx, workingPos, 17].toNSNumberArray()] = 1.0
                }
            }
        }
        
        let bsize = board.size
        
        for y in 0..<bsize {
            for x in 0..<bsize {
                let pos = self.xy_to_tensor_pos(x, y)
                var key = [idx, pos, 0]
                bin_input_data[key.toNSNumberArray()] = 1.0
                let loc = board.loc(x, y)
                let stone = board.board[loc]
                if stone == pla {
                    key[2] = 1
                    bin_input_data[key.toNSNumberArray()] = 1.0
                } else if stone == opp {
                    key[2] = 2
                    bin_input_data[key.toNSNumberArray()] = 1.0
                }
                
                if stone == pla || stone == opp {
                    let libs = board.num_liberties(loc)
                    if libs == 1 {
                        key[2] = 3
                        bin_input_data[key.toNSNumberArray()] = 1.0
                    } else if libs == 2 {
                        key[2] = 4
                        bin_input_data[key.toNSNumberArray()] = 1.0
                    } else if libs == 3 {
                        key[2] = 5
                        bin_input_data[key.toNSNumberArray()] = 1.0
                    }
                }
            }
        }

        // Python code does NOT handle superko
        if board.simple_ko_point != nil {
            let pos = self.loc_to_tensor_pos(board.simple_ko_point!, board)
            let key = [idx, pos, 6]
            bin_input_data[key.toNSNumberArray()] = 1.0
        }
        // Python code does NOT handle ko-prohibited encore spots or anything relating to the encore
        // so features 7 and 8 leave that blank
        
        if move_idx >= 1 && moves[move_idx-1].0 == opp {
            let prev1_loc = moves[move_idx-1].1
            if prev1_loc != nil && prev1_loc != Board.PASS_LOC {
                let pos = self.loc_to_tensor_pos(prev1_loc!, board)
                let key = [idx, pos, 9].toNSNumberArray()
                bin_input_data[key] = 1.0
            } else if prev1_loc == Board.PASS_LOC {
                let key = [idx, 0].toNSNumberArray()
                global_input_data[key] = 1.0
            }
            
            if move_idx >= 2 && moves[move_idx-2].0 == pla {
                let prev2_loc = moves[move_idx-2].1
                if prev2_loc != nil && prev2_loc != Board.PASS_LOC {
                    let pos = self.loc_to_tensor_pos(prev2_loc!, board)
                    let key = [idx, pos, 10].toNSNumberArray()
                    bin_input_data[key] = 1.0
                } else if prev2_loc == Board.PASS_LOC {
                    let key = [idx, 1].toNSNumberArray()
                    global_input_data[key] = 1.0
                }
                
                if move_idx >= 3 && moves[move_idx-3].0 == opp {
                    let prev3_loc = moves[move_idx-3].1
                    
                    if prev3_loc != nil && prev3_loc != Board.PASS_LOC {
                        let pos = self.loc_to_tensor_pos(prev3_loc!, board)
                        let key = [idx, pos, 11].toNSNumberArray()
                        bin_input_data[key] = 1.0
                    } else if prev3_loc == Board.PASS_LOC {
                        let key = [idx, 2].toNSNumberArray()
                        global_input_data[key] = 1.0
                    }
                    
                    if move_idx >= 4 && moves[move_idx-4].0 == pla {
                        let prev4_loc = moves[move_idx-4].1
                        if prev4_loc != nil && prev4_loc != Board.PASS_LOC {
                            let pos = self.loc_to_tensor_pos(prev4_loc!, board)
                            let key = [idx, pos, 12].toNSNumberArray()
                            bin_input_data[key] = 1.0
                        } else if prev4_loc == Board.PASS_LOC {
                            global_input_data[[idx, 3].toNSNumberArray()] = 1.0
                        }
                        
                        if move_idx >= 5 && moves[move_idx-5].0 == opp {
                            let prev5_loc = moves[move_idx-5].1
                            if prev5_loc != nil && prev5_loc != Board.PASS_LOC {
                                let pos = self.loc_to_tensor_pos(prev5_loc!, board)
                                bin_input_data[[idx, pos, 13].toNSNumberArray()] = 1.0
                            } else if prev5_loc == Board.PASS_LOC {
                                global_input_data[[idx, 4].toNSNumberArray()] = 1.0
                            }
                        }
                    }
                }
            }
        }
    }
    
}
