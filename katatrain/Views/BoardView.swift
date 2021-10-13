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
    
    var body: some View {
        ZStack {
            Canvas { context, size in
                drawBoard(context: context, size: size)
            }.padding()
        }
    }
    
    func drawBoard(context: GraphicsContext, size: CGSize) {
        let boardContext = context
        let origin = CGPoint(x: 0, y: 0)
        let topleft = CGPoint(x: margin, y: margin)
        
        let area = CGSize(width: size.height, height: size.height)
        let boardArea = CGSize(width: size.height - 2 * margin - 2 * boardLineWidth,
                               height: size.height - 2 * margin - 2 * boardLineWidth)
        
        let boardOrigin = CGPoint(x: margin + boardLineWidth, y: margin + boardLineWidth)
        
        // let topright = CGPoint(x: size.height, y: 0)
        // let bottomleft = CGPoint(x: 0, y: size.height)
        // let bottomright = CGPoint(x: size.height, y: size.height)
        
        let image = Image("board")
        
        boardContext.draw(image, in: CGRect(origin: origin, size: area))
        
        let gridWidth: Double = (boardArea.height - Double((boardSize - 2)) * lineWidth) / CGFloat(boardSize - 1)
        
        boardContext.stroke(
            Rectangle().path(
                in: CGRect(origin: CGPoint(x: topleft.x + boardLineWidth, y: topleft.y + boardLineWidth),
                           size: boardArea)),
            with: .color(white: 0),
            lineWidth: boardLineWidth)
        
        let lines = Path { path in
            for i in 1..<boardSize - 1 {
                let rightY = gridWidth * Double(i) + lineWidth * Double(i - 1) + boardOrigin.y
                path.move(to: CGPoint(x: boardOrigin.x, y: rightY))
                path.addLine(to: CGPoint(x: boardArea.width + margin + boardLineWidth, y: rightY))
            }

            for i in 1..<boardSize - 1 {
                let upX = gridWidth * Double(i) + lineWidth * Double(i - 1) + boardOrigin.x
                path.move(to: CGPoint(x: upX, y: boardOrigin.y))
                path.addLine(to: CGPoint(x: upX, y: boardArea.height + margin + boardLineWidth))
            }
        }
        
        boardContext.stroke(lines, with: .foreground, lineWidth: lineWidth)
    }
    
    func drawStars(context: GraphicsContext, size: CGSize) {
        var starContext = context
        
    }
}

@available(iOS 15.0, *)
struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
