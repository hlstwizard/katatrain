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
  @State var frame: CGSize = .zero
  @State var showTouchPoint = false
  
  // MARK: - Properties
  let margin = 15.0
  let boardLineWidth = 5.0
  let lineWidth = 1.0
  let starWidth = 8.0
  let canvasPadding = 5.0
  let cursorSize = 10.0
  let logger = Logger(label: #file)
  
  let imageSize = 200.0
  let scale = 0.18
  
  // MARK: - Computed Properties
  var goboardSize: Int { game.boardSize.0 }
  var boardOrigin: CGPoint {
    CGPoint(x: margin + boardLineWidth, y: margin + boardLineWidth)
  }
  var boardFrame: CGSize {
    CGSize(width: self.frame.width - canvasPadding,
                  height: self.frame.height - canvasPadding)
  }
  
  var boardLineFrame: CGSize {
    CGSize(width: self.frame.height - 2 * margin - 2 * boardLineWidth,
                  height: self.frame.height - 2 * margin - 2 * boardLineWidth)
  }
  
  var gridWidth: Double {
    (self.boardLineFrame.height - Double(goboardSize - 2) * lineWidth) / CGFloat(goboardSize - 1)
  }
  
  var body: some View {
    Group {
      GeometryReader { (geometry) in
        self.makeView(geometry)
      }
    }
  }
  
  // MARK: - Functions
  func makeView(_ geometry: GeometryProxy) -> some View {
    DispatchQueue.main.async { self.frame = geometry.size }
    
    return Canvas { context, _ in
      drawBoard(context: context)
      drawStars(context: context)
      drawChains(context: context)
      
      if let move = game.currentNode.move {
        if let coord = move.coord {
          drawCursor(context: context, geoSize: self.frame, coord: coord)
        }
      }
      
      drawTerritory(cn: game.currentNode, context: context, geoSize: self.frame)

      if showTouchPoint {
        drawTouchPoint(context: context)
      }
    }.gesture(
      DragGesture(minimumDistance: 0)
        .onEnded {
          // (CGSize) $R0 = (width = 1180, height = 776)
          logger.debug("\($0.location), \(toGoboardPoint(pos: $0.location))")
          play(point: toGoboardPoint(pos: $0.location))
        }
    ).frame(width: self.frame.width, height: self.frame.height)
      .padding(canvasPadding)
  }
  
  func toScreenPoint(x: Int, y: Int) -> CGPoint {
    return CGPoint(x: boardOrigin.x + Double(x) * gridWidth + Double(abs(x - 1)) * lineWidth,
                   y: boardOrigin.y + Double(y) * gridWidth + Double(abs(y - 1)) * lineWidth)
  }
  
  func toGoboardPoint(pos: CGPoint) -> (x: Int, y: Int) {
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
  func drawBoard(context: GraphicsContext) {
    let boardContext = context
    let origin = CGPoint(x: 0, y: 0)
    let topleft = CGPoint(x: margin, y: margin)
    
    let image = Image("board")
    
    boardContext.draw(image, in: CGRect(origin: origin, size: boardFrame))
    
    boardContext.stroke(
      Rectangle().path(
        in: CGRect(origin: CGPoint(x: topleft.x + boardLineWidth, y: topleft.y + boardLineWidth),
                   size: boardLineFrame)),
      with: .color(white: 0),
      lineWidth: boardLineWidth)
    
    let lines = Path { path in
      for i in 1..<goboardSize - 1 {
        // 竖线
        path.move(to: toScreenPoint(x: i, y: 0))
        path.addLine(to: toScreenPoint(x: i, y: goboardSize - 1))
        
        // 横线
        path.move(to: toScreenPoint(x: 0, y: i))
        path.addLine(to: toScreenPoint(x: goboardSize - 1, y: i))
      }
    }
    
    boardContext.stroke(lines, with: .foreground, lineWidth: lineWidth)
  }
  
  // size: GeometryReader size
  func drawStars(context: GraphicsContext) {
    let _context = context
    let stars = [
      (3, 3), (3, 9), (3, 15),
      (9, 3), (9, 9), (9, 15),
      (15, 3), (15, 9), (15, 15)
    ]
    
    let starPoints = stars.map { x, y in
      toScreenPoint(x: x, y: y)
    }
    
    for point in starPoints {
      let _point = CGPoint(x: point.x - starWidth / 2, y: point.y - starWidth / 2)
      let _size = CGSize(width: starWidth, height: starWidth)
      _context.fill(Circle().path(in: CGRect(origin: _point, size: _size)), with: .color(.black))
    }
  }
  
  private func draw(move: Move, context: GraphicsContext) {
    let _context = context
    let black = _context.resolve(Image("B_stone"))
    let white = _context.resolve(Image("W_stone"))
    if let coord = move.coord {
      let screenPoint = toScreenPoint(x: coord.x, y: goboardSize - coord.y - 1) / scale
      
      if move.player == "B" {
        _context.draw(black, at: screenPoint)
      } else if move.player == "W" {
        _context.draw(white, at: screenPoint)
      }
    }
  }
  
  // size: GeometryReader size
  func drawChains(context: GraphicsContext) {
    var _context = context
    let chains = game.chains

    _context.scaleBy(x: scale, y: scale)
    
    for chain in chains {
      for move in chain {
        draw(move: move, context: _context)
      }
    }
  }
  
  func drawCursor(context: GraphicsContext, geoSize: CGSize, coord: Coord) {
    let _context = context
    let drawCoord = coord.toDrawCoord(boardSize: goboardSize)
    let origin = toScreenPoint(x: drawCoord.0, y: drawCoord.1) -
        CGPoint(x: imageSize * scale / 2, y: imageSize * scale / 2)
    
    _context.fill(Triangle().path(in: CGRect(origin: origin, size: CGSize(width: cursorSize, height: cursorSize))), with: .color(.green))
  }
  
  // size: GeometryReader size
  // For debugging
  func drawTouchPoint(context: GraphicsContext) {
    let _context = context
    let step = gridWidth + lineWidth
    
    for i in stride(from: boardOrigin.x, to: boardLineFrame.width, by: step) {
      for j in stride(from: boardOrigin.y, to: boardLineFrame.height, by: step) {
        let (x, y) = toGoboardPoint(pos: CGPoint(x: i, y: j))
        if x == -1 || y == -1 {
          logger.info("Not valid touch point")
          continue
        }
        let _point = toScreenPoint(x: x, y: y)
        let _size = CGSize(width: starWidth, height: starWidth)
        _context.fill(Circle().path(in: CGRect(origin: _point, size: _size)), with: .color(.red))
      }
    }
  }
  
  func drawPlacement(context: GraphicsContext, geoSize: CGSize) {
    let placements = game.root.placements
    for move in placements {
      draw(move: move, context: context)
    }
  }
  
  func drawTerritory(cn: GameNode, context: GraphicsContext, geoSize: CGSize) {
    if let ownership = cn.analysis?.ownership {
      let _context = context
      
      for i in 0..<ownership.count {
        let (x, y) = (i / self.goboardSize, i % self.goboardSize)
        
        let _point = toScreenPoint(x: x, y: y)
        let _size = CGSize(width: starWidth, height: starWidth)
        _context.fill(Rectangle().path(in: CGRect(origin: _point, size: _size)), with: .color(.black))
      }
    }
  }
}

@available(iOS 15.0, *)
struct BoardView_Previews: PreviewProvider {
  static var previews: some View {
    BoardView()
      .previewInterfaceOrientation(.landscapeLeft)
  }
}
