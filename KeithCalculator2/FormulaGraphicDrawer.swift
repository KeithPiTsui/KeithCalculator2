//
//  FormulaGraphicDrawer.swift
//  KeithCalculator2
//
//  Created by Pi on 4/7/16.
//  Copyright © 2016 Keith. All rights reserved.
//

import UIKit

// MARK: - A Utility class for draw a graphic of formula according to set of parameters
final class FormulaGraphicDrawer {
    
    
    // MARK: - Setting values for drawing
    private let dotRadius: CGFloat = 1
    private var scale: CGFloat = 1
    private var axisUnitDistance: CGFloat = 25
    private let dotColor = UIColor.blueColor()
    private let axisColor = UIColor.blackColor()
    private let originColor = UIColor.blueColor()
    private let assistantLineColor = UIColor(red: 193/255, green: 220/255, blue: 232/255, alpha: 1)
    private let axisArrowColor = UIColor.blackColor()
    private let axisArrowAngle: CGFloat = 30
    private let axisArrowProjectRate: CGFloat = 5
    private var axisArrowDeltaShort: CGFloat { return tan( axisArrowAngle / 180 * CGFloat(M_PI) ) * axisArrowDeltaLong  }
    private var axisArrowDeltaLong: CGFloat { return axisUnitDistance / axisArrowProjectRate }
    var formulaSyntaxCorrect: Bool = true
    
    // MARK: - Variables for y-axis value calculating
    /// Expression scanner for lexical analysis
    private let scanner = Scanner()
    /// Expression parser for semantic analysis
    private let parser = Parser()
    /// Expression string
    private var formulaString = "" {
        didSet{
            formulaTokens = scanner.getTokensWithLexicalString(formulaString)
        }
    }
    /// An array of tokens after expression string is passed lexical analysis
    private var formulaTokens = [Token]()
    
    // MARK: - public interface for get formula graphic image
    /**
     A external access function for getting a formula graphic image by inputting an expression string, image size and image scale
     - parameter formulaString: a string representing an expression
     - parameter size: size of returning image
     - parameter scale: x-y axises unit metric, default is one, scaled by 5
     - returns: return an image drawed according to inputted parameters
     */
    func getFormulaGraphicImageWithFormulaString(formulaStr:String, withSize size: CGSize, andScale scale: CGFloat = 1) -> UIImage {
        self.scale = scale
        self.formulaString = formulaStr
        return drawCoordinatePlateWithSize(size)
        
    }
    
    // MARK: - Drawing functions
    /**
     Draw a coordinate plate
     
     - parameters size: how large the plate is
     
     - returns: return an image demostrating a coordinate plate
     */
    
    private func drawCoordinatePlateWithSize(size: CGSize) -> UIImage {
        let origin = CGPoint(x: size.width/2, y: size.height/2)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        let con = UIGraphicsGetCurrentContext()!
        
        // draw x axis
        drawAxisLineOnDot(origin, withDirection: .Horizontal, inContext: con, andCoordinatePlateSize: size)
        
        // draw y axis
        drawAxisLineOnDot(origin, withDirection: .Vertical, inContext: con, andCoordinatePlateSize: size)
        
        // draw a dot on origin
        drawOrigin(origin, inContext: con)
        drawString("0",withDot: origin, withContext: con)
        
        // draw grid on axises with distance of axisUnitDistance
        // negative x axis
        var dotX = origin.x - axisUnitDistance
        var counter:CGFloat = -1
        while dotX > dotRadius {
            let dotPoint = CGPoint(x: dotX, y: origin.y)
            
            // draw line
            drawAssistantLineOnDot(dotPoint, withDirection: .Vertical, inContext: con, andCoordinatePlateSize: size)
            // draw dot
            drawDotOnPoint(dotPoint, inContext: con)
            // draw a tab with dot
            
            drawString("\(Int(counter * scale))",withDot: dotPoint, withContext: con)
            
            dotX = dotX - axisUnitDistance
            counter -= 1
        }
        
        // positive x axis
        dotX = origin.x + axisUnitDistance
        counter = 1
        while size.width - dotX > dotRadius {
            let dotPoint = CGPoint(x: dotX, y: origin.y)
            
            // draw line
            drawAssistantLineOnDot(dotPoint, withDirection: .Vertical, inContext: con, andCoordinatePlateSize: size)
            // draw dots
            drawDotOnPoint(dotPoint, inContext: con)
            // draw a tab with dot
            drawString("\(Int(counter * scale))",withDot: dotPoint, withContext: con)
            
            dotX = dotX + axisUnitDistance
            counter +=  1
        }
        
        // Negative y axis
        var dotY = origin.y + axisUnitDistance
        counter = -1
        while size.height - dotY > dotRadius {
            let dotPoint = CGPoint(x: origin.x, y: dotY)
            // draw line
            drawAssistantLineOnDot(dotPoint, withDirection: .Horizontal, inContext: con, andCoordinatePlateSize: size)
            // draw dots
            drawDotOnPoint(dotPoint, inContext: con)
            // draw a tab with dot
            drawString("\(Int(counter * scale))",withDot: dotPoint, withContext: con)
            
            
            dotY = dotY + axisUnitDistance
            counter -= 1
        }
        
        // Positive y axis
        dotY = origin.y - axisUnitDistance
        counter = 1
        while dotY > dotRadius {
            let dotPoint = CGPoint(x: origin.x, y: dotY)
            // draw line
            drawAssistantLineOnDot(dotPoint, withDirection: .Horizontal, inContext: con, andCoordinatePlateSize: size)
            // draw dots
            drawDotOnPoint(dotPoint, inContext: con)
            // draw a tab with dot
            drawString("\(Int(counter * scale))",withDot: dotPoint, withContext: con)
            
            dotY = dotY - axisUnitDistance
            counter += 1
        }
        
        // draw arrow of x-y axis
        // x-axis arrow
        let xPoint2 = CGPoint(x: origin.x, y: 0)
        let xPoint1 = CGPoint(x: xPoint2.x - axisArrowDeltaShort, y: xPoint2.y + axisArrowDeltaLong)
        let xPoint3 = CGPoint(x: xPoint2.x + axisArrowDeltaShort, y: xPoint2.y + axisArrowDeltaLong)
        drawLineInContext(con, WithPoints: [xPoint1, xPoint2, xPoint3], withColor: axisArrowColor)
        
        
        // x-axis arrow
        let yPoint2 = CGPoint(x: size.width, y: origin.y)
        let yPoint1 = CGPoint(x: yPoint2.x - axisArrowDeltaLong, y: yPoint2.y - axisArrowDeltaShort)
        let yPoint3 = CGPoint(x: yPoint2.x - axisArrowDeltaLong, y: yPoint2.y + axisArrowDeltaShort)
        drawLineInContext(con, WithPoints: [yPoint1, yPoint2, yPoint3], withColor: axisArrowColor)
        
        // Experiment
        // draw a y = x line
        formulaSyntaxCorrect = testFormularSyntax()
        if formulaSyntaxCorrect {
            var points = [CGPoint]()
            for var x: CGFloat = -size.width / 2 ; x < size.width / 2; x += 1 / (axisUnitDistance * 2) {
                if let y = getYByXTest(x) {
                    let aPoint = convertPoint(CGPoint(x: x, y: y), withOrigin: origin)
                    if aPoint.x > size.width
                        || aPoint.y > size.height
                        || aPoint.x < 0
                        || aPoint.y < 0
                    {
                        drawLineInContext(con, WithPoints: points, withColor: UIColor.redColor(), completion: {points.removeAll()})
                    } else {
                        points.append(aPoint)
                    }
                } else {
                    drawLineInContext(con, WithPoints: points, withColor: UIColor.redColor(), completion: {points.removeAll()})
                }
            }
            drawLineInContext(con, WithPoints: points, withColor: UIColor.redColor(), completion: {points.removeAll()})
        } else {
            ("Syntax Error" as NSString).drawAtPoint(CGPointZero,
                                                     withAttributes: [NSFontAttributeName: UIFont(name: "Chalkduster", size: 20)!,
                                                                        NSForegroundColorAttributeName : UIColor.redColor()])
        }
        
        
        let im = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return im
    }
    
    /**
     draw a string on a graphics context
     - parameter str:   a string need to be drawn
     - parameter context: a context which a string is drawn on
     */
    
    private func drawString(str:String, withDot dotPoint: CGPoint, withContext context: CGContext) {
        UIGraphicsPushContext(context)
        let str2 = str as NSString
        let rect = CGRect(x: dotPoint.x + 5, y: dotPoint.y + 5, width: 30, height: 30)
        str2.drawInRect(rect, withAttributes: nil)
        
        UIGraphicsPopContext()
    }
    
    /**
     translate point of calculator x-y axis coordinate plate to point of screen coordinate
     
     - parameter point: a point of calculator coordinate
     
     - returns:  a point of screen coordinate that need to be drawed on screen
     
     */
    
    private func convertPoint(point: CGPoint, withOrigin origin: CGPoint) -> CGPoint {
        return CGPoint(x: origin.x + point.x * axisUnitDistance / scale, y: origin.y - point.y * axisUnitDistance / scale)
    }
    
    /**
     a function for get result value by supplying a x
     */
    private func getYByX(x: CGFloat) -> CGFloat {
        return sin(x)
    }
    
    /**
     a function for get result value by supplying a x
     */
    private func getYByXTest(x: CGFloat) -> CGFloat? {
        if formulaString != "" && !formulaString.isEmpty {
            let newToken = formulaTokens.map{ $0 == Token.VARIABLEA ? Token.NUMBER(Double(x)) : $0 }
            if let result = parser.getResultValueWithTokens(newToken) {
                if result.isFinite {
                    return CGFloat(result)
                } else { return nil }
            } else { return nil }
        }
        return nil
    }
    
    /**
     test if syntax of formula is correct or not
     */
    private func testFormularSyntax() -> Bool {
        if formulaString != "" && !formulaString.isEmpty {
            let newToken = formulaTokens.map{ $0 == Token.VARIABLEA ? Token.NUMBER(1) : $0 }
            if parser.getResultStringWithTokens(newToken) != nil {
                return true
            } else { return false }
        }
        return true
    }
    
    /**
     Draw axis line on dot
     - parameter dotPoint:
     - parameter withDirection:
     - parameter inContext:
     - parameter andCoordinatePlateSize:
     */
    private func drawAxisLineOnDot(dotPoint: CGPoint, withDirection direction: LineDirection, inContext context: CGContext, andCoordinatePlateSize size: CGSize) {
        drawLineOnDot(dotPoint, withDirection: direction, inContext: context, andCoordinatePlateSize: size, withColor: axisColor)
    }
    
    /**
     Draw assistant line on dot
     - parameter dotPoint:
     - parameter withDirection:
     - parameter inContext:
     - parameter andCoordinatePlateSize:
     */
    private func drawAssistantLineOnDot(dotPoint: CGPoint, withDirection direction: LineDirection, inContext context: CGContext, andCoordinatePlateSize size: CGSize) {
        drawLineOnDot(dotPoint, withDirection: direction, inContext: context, andCoordinatePlateSize: size, withColor: assistantLineColor)
    }
    
    /**
     Draw dot on point in context
     - parameter point:
     - parameter context:
     */
    private func drawDotOnPoint(dotPoint: CGPoint, inContext context: CGContext) {
        drawDotOnPoint(dotPoint, inContext: context, withColor: dotColor)
    }
    
    
    /**
     Draw origin Point in context
     - parameter origin:
     - parameter context:
     */
    
    private func drawOrigin(origin: CGPoint, inContext context: CGContext) {
        drawDotOnPoint(origin, inContext: context, withColor: originColor)
    }
    
    
    /**
     Private type for line orientation
     */
    private enum LineDirection {
        case Horizontal
        case Vertical
    }
    
    /**
     Draw a line on a dot with specific direction
     
     - parameter dot: a point which a line stays on
     - parameter direction: how the line lies in a coordinate plate
     - parameter context: the context where the drawing stays a
     
     */
    private func drawLineOnDot(dot: CGPoint, withDirection direction: LineDirection, inContext context: CGContext, andCoordinatePlateSize size: CGSize, withColor color: UIColor ) {
        let beginPointX = direction == .Horizontal ? 0 : dot.x
        let beginPointY = direction == .Horizontal ? dot.y : 0
        let endPointX = direction == .Horizontal ? size.width : dot.x
        let endPointY = direction == .Horizontal ? dot.y : size.height
        drawLineInContext(context, WithPoint1: CGPoint(x: beginPointX, y: beginPointY), andPoint2: CGPoint(x: endPointX, y: endPointY), withColor: color)
        
    }
    
    /**
     Graphics context draw line helper function, draw line into current graphics context
     
     - parameter context: the context where the drawing stays at
     - parameter point1:
     - parameter point2:
     - parameter color:
     
     */
    
    private func drawLineInContext(context: CGContext, WithPoint1 point1: CGPoint, andPoint2 point2: CGPoint, withColor color: UIColor) {
        drawLineInContext(context, WithPoints: [point1, point2], withColor: color)
    }
    
    /**
     Graphics context draw line helper function, draw line into current graphics context
     
     - parameter context: the context where the drawing stays at
     - parameter points:
     - parameter color:
     
     */
    
    private func drawLineInContext(context: CGContext, WithPoints points: [CGPoint], withColor color: UIColor) {
        drawLineInContext(context, WithPoints: points, withColor: color, completion: nil)
        
    }
    
    /**
     Graphics context draw line helper function, draw line into current graphics context
     
     - parameter context: the context where the drawing stays at
     - parameter points:
     - parameter color:
     - parameter completion:
     
     */
    
    private func drawLineInContext(context: CGContext, WithPoints points: [CGPoint], withColor color: UIColor, completion: (()->Void)?) {
        if points.count < 2 { return }
        CGContextMoveToPoint(context, points[0].x, points[0].y)
        for point in points {
            CGContextAddLineToPoint(context, point.x, point.y)
        }
        CGContextSetLineWidth(context, 1)
        CGContextSetStrokeColorWithColor(context, color.CGColor)
        CGContextStrokePath(context)
        
        if let finalOperation = completion {
            finalOperation()
        }
        
    }
    
    /**
     Graphics context draw dot helper function, draw a dot on a specific point
     - parameter context: the context where the drawing stays at
     - parameter point: the point where a dot draw on
     */
    private func drawDotOnPoint(point:CGPoint, inContext context: CGContext, withColor color: UIColor) {
        CGContextAddEllipseInRect(context, CGRect(x: point.x - dotRadius, y: point.y - dotRadius, width: dotRadius * 2, height: dotRadius * 2))
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillPath(context)
    }
}