//
//  Canvas.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/10/12.
//

import SwiftUI
import Logging

@available(iOS 15.0, *)
struct BoardView: View {
  @EnvironmentObject var game: Game
  @State var showTouchPoint = false
  
  var size: CGSize
  let boardSize = 19
  let margin = 15.0
  let boardLineWidth = 5.0
  let lineWidth = 1.0
  let starWidth = 8.0
  let canvasPadding = 5.0
  let cursorSize = 10.0
  let logger = Logger(label: #file)
  
  let imageSize = 200.0
  let scale = 0.18
  
  init(size: CGSize) {
    self.size = size
  }
  
  var body: some View {
    Canvas { context, _ in
      // (CGSize) $R0 = (width = 1148, height = 744)
      drawBoard(context: context, geoSize: self.size)
      drawStars(context: context, geoSize: self.size)
      drawChains(context: context, geoSize: self.size)
      
//      if katago.lastMove != -1 {
//        drawCursor(context: context, geoSize: self.size, loc: katago.lastMove, pla: .P_WHITE)
//      }

      if showTouchPoint {
        drawTouchPoint(context: context, geoSize: self.size)
      }
    }.gesture(
      DragGesture(minimumDistance: 0)
        .onEnded {
          // (CGSize) $R0 = (width = 1180, height = 776)
          logger.debug("\($0.location), \(toPoint(pos: $0.location, size: self.size))")
          play(point: toPoint(pos: $0.location, size: self.size))
        }
    ).frame(width: self.size.width, height: self.size.height)
      .padding(canvasPadding)
  }
  
  var boardOrigin: CGPoint {
    CGPoint(x: margin + boardLineWidth, y: margin + boardLineWidth)
  }
  
  func getBoardArea(size: CGSize) -> CGSize {
    return CGSize(width: size.height - 2 * margin - 2 * boardLineWidth,
                  height: size.height - 2 * margin - 2 * boardLineWidth)
  }
  
  func getGridWidth(boardArea: CGSize) -> Double {
    (boardArea.height - Double(boardSize - 2) * lineWidth) / CGFloat(boardSize - 1)
  }
  
  /// 围棋坐标 -> 屏幕坐标
  ///
  ///  return CGPoint
  func getPoint(x: Int, y: Int, boardArea: CGSize) -> CGPoint {
    let gridWidth = getGridWidth(boardArea: boardArea)
    
    return CGPoint(x: boardOrigin.x + Double(x) * gridWidth + Double(abs(x - 1)) * lineWidth,
                   y: boardOrigin.y + Double(y) * gridWidth + Double(abs(y - 1)) * lineWidth)
  }
  
  // size: GeometryReader size
  func clipBoardSize(size: CGSize) -> CGSize {
    return CGSize(width: size.width - canvasPadding,
                  height: size.height - canvasPadding)
  }
  
  /// size: the GeometryReader size
  /// 屏幕坐标 -> 围棋坐标
  func toPoint(pos: CGPoint, size: CGSize) -> (x: Int, y: Int) {
    let boardArea = getBoardArea(size: clipBoardSize(size: size))
    let gridWidth = getGridWidth(boardArea: boardArea)
    
    let x = (pos.x + lineWidth - boardOrigin.x) / (gridWidth + lineWidth)
    let y = (pos.y + lineWidth - boardOrigin.y) / (gridWidth + lineWidth)
    
    let threshold = 0.3
    var _x: Int = -1
    var _y: Int = -1
    if ceil(x) - x < threshold {
      _x = Int(ceil(x))
    } else if x - floor(x) < threshold {
      _x = Int(floor(x))
    }
    
    if ceil(y) - y < threshold {
      _y = Int(ceil(y))
    } else if y - floor(y) < threshold {
      _y = Int(floor(y))
    }
    
    if _x == -1 || _y == -1 {
      return (-1, -1)
    }
    
    return (_x, _y)
  }
  
  // size: GeometryReader size
  func drawBoard(context: GraphicsContext, geoSize: CGSize) {
    let size = clipBoardSize(size: geoSize)
    let boardContext = context
    let origin = CGPoint(x: 0, y: 0)
    let topleft = CGPoint(x: margin, y: margin)
    
    let area = CGSize(width: size.height, height: size.height)
    let boardArea = getBoardArea(size: size)
    
    let image = Image("board")
    
    boardContext.draw(image, in: CGRect(origin: origin, size: area))
    
    boardContext.stroke(
      Rectangle().path(
        in: CGRect(origin: CGPoint(x: topleft.x + boardLineWidth, y: topleft.y + boardLineWidth),
                   size: boardArea)),
      with: .color(white: 0),
      lineWidth: boardLineWidth)
    
    let lines = Path { path in
      for i in 1..<boardSize - 1 {
        // 竖线
        path.move(to: getPoint(x: i, y: 0, boardArea: boardArea))
        path.addLine(to: getPoint(x: i, y: boardSize - 1, boardArea: boardArea))
        
        // 横线
        path.move(to: getPoint(x: 0, y: i, boardArea: boardArea))
        path.addLine(to: getPoint(x: boardSize - 1, y: i, boardArea: boardArea))
      }
    }
    
    boardContext.stroke(lines, with: .foreground, lineWidth: lineWidth)
  }
  
  // size: GeometryReader size
  func drawStars(context: GraphicsContext, geoSize: CGSize) {
    let size = clipBoardSize(size: geoSize)
    let _context = context
    let stars = [
      (3, 3), (3, 9), (3, 15),
      (9, 3), (9, 9), (9, 15),
      (15, 3), (15, 9), (15, 15)
    ]
    let boardArea = getBoardArea(size: size)
    
    let starPoints = stars.map { x, y in
      getPoint(x: x, y: y, boardArea: boardArea)
    }
    
    for point in starPoints {
      let _point = CGPoint(x: point.x - starWidth / 2, y: point.y - starWidth / 2)
      let _size = CGSize(width: starWidth, height: starWidth)
      _context.fill(Circle().path(in: CGRect(origin: _point, size: _size)), with: .color(.black))
    }
  }
  
  // size: GeometryReader size
  func drawChains(context: GraphicsContext, geoSize: CGSize) {
    var _context = context
    let chains = game.chains
    
    let black = _context.resolve(Image("B_stone"))
    let white = _context.resolve(Image("W_stone"))
    let size = clipBoardSize(size: geoSize)
    let boardArea = getBoardArea(size: size)
    _context.scaleBy(x: scale, y: scale)
    
    for chain in chains {
      for move in chain {
        if let coord = move.coord {
          if move.player == "B" {
            _context.draw(black, at: getPoint(x: coord.x, y: boardSize - coord.y - 1, boardArea: boardArea) / scale)
          } else if move.player == "W" {
            _context.draw(white, at: getPoint(x: coord.x, y: boardSize - coord.y - 1, boardArea: boardArea) / scale)
          }
        }
      }
    }
  }
  
  func drawCursor(context: GraphicsContext, geoSize: CGSize, loc: Loc, pla: PlayerColor) {
    let _context = context
    
    let x = Int(loc) % (self.boardSize+1) - 1
    let y = Int(loc) / (self.boardSize+1) - 1
    let size = clipBoardSize(size: geoSize)
    let boardArea = getBoardArea(size: size)
    let origin = getPoint(x: x, y: y, boardArea: boardArea) -
        CGPoint(x: imageSize * scale / 2, y: imageSize * scale / 2)
    print("x: \(x), y: \(y), origin: \(origin)")
    
    _context.fill(Triangle().path(in: CGRect(origin: origin, size: CGSize(width: cursorSize, height: cursorSize))), with: .color(.green))
  }
  
  // size: GeometryReader size
  // For debugging
  func drawTouchPoint(context: GraphicsContext, geoSize: CGSize) {
    let size = clipBoardSize(size: geoSize)
    let boardArea = getBoardArea(size: size)
    let _context = context
    let step = getGridWidth(boardArea: boardArea) + lineWidth
    
    for i in stride(from: boardOrigin.x, to: boardArea.width, by: step) {
      for j in stride(from: boardOrigin.y, to: boardArea.height, by: step) {
        let (x, y) = toPoint(pos: CGPoint(x: i, y: j), size: geoSize)
        if x == -1 || y == -1 {
          logger.info("Not valid touch point")
          continue
        }
        let _point = getPoint(x: x, y: y, boardArea: boardArea)
        let _size = CGSize(width: starWidth, height: starWidth)
        _context.fill(Circle().path(in: CGRect(origin: _point, size: _size)), with: .color(.red))
      }
    }
  }
}

@available(iOS 15.0, *)
struct BoardView_Previews: PreviewProvider {
  static var previews: some View {
    BoardView(size: CGSize(width: 810, height: 1136))
      .previewInterfaceOrientation(.landscapeLeft)
  }
}
