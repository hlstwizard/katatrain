//
//  Canvas.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/10/12.
//

import SwiftUI

@available(iOS 15.0, *)
struct BoardView: View {
    @StateObject var board = Board()
    
    let boardSize = 19
    let margin = 10.0
    let boardLineWidth = 5.0
    let lineWidth = 1.0
    let starWidth = 8.0
    
    var body: some View {
        ZStack {
            Canvas { context, size in
                drawBoard(context: context, size: size)
                drawStars(context: context, size: size)
            }.padding()
        }
    }
    
    func drawBoard(context: GraphicsContext, size: CGSize) {
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
                path.move(to: getPoint(x: i, y: 0, boardOrigin: boardOrigin, boardArea: boardArea))
                path.addLine(to: getPoint(x: i, y: boardSize - 1, boardOrigin: boardOrigin, boardArea: boardArea))
                
                // 横线
                path.move(to: getPoint(x: 0, y: i, boardOrigin: boardOrigin, boardArea: boardArea))
                path.addLine(to: getPoint(x: boardSize - 1, y: i, boardOrigin: boardOrigin, boardArea: boardArea))
            }
        }
        
        boardContext.stroke(lines, with: .foreground, lineWidth: lineWidth)
    }
    
    var boardOrigin: CGPoint {
        CGPoint(x: margin + boardLineWidth, y: margin + boardLineWidth)
    }
    
    func getBoardArea(size: CGSize) -> CGSize {
        return CGSize(width: size.height - 2 * margin - 2 * boardLineWidth,
                      height: size.height - 2 * margin - 2 * boardLineWidth)
    }
    
    func getPoint(x: Int, y: Int, boardOrigin: CGPoint, boardArea: CGSize) -> CGPoint {
        let gridWidth: Double = (boardArea.height - Double(boardSize - 2) * lineWidth) / CGFloat(boardSize - 1)
        
        return CGPoint(x: boardOrigin.x + Double(x) * gridWidth + Double(abs(x - 1)) * lineWidth,
                       y: boardOrigin.y + Double(y) * gridWidth + Double(abs(y - 1)) * lineWidth)
    }
    
    func drawStars(context: GraphicsContext, size: CGSize) {
        let _context = context
        let stars = [
            (3, 3), (3, 9), (3, 15),
            (9, 3), (9, 9), (9, 15),
            (15, 3), (15, 9), (15, 15),
        ]
        let boardArea = getBoardArea(size: size)
        
        let starPoints = stars.map { x, y in
            getPoint(x: x, y: y, boardOrigin: boardOrigin, boardArea: boardArea)
        }
        
        for point in starPoints {
            let _point = CGPoint(x: point.x - starWidth / 2, y: point.y - starWidth / 2)
            let _size = CGSize(width: starWidth, height: starWidth)
            _context.fill(Circle().path(in: CGRect(origin: _point, size: _size)), with: .color(.black))
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
