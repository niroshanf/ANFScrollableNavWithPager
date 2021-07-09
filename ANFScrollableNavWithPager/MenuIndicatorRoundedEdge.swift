//
//  MenuIndicatorRoundedEdge.swift
//  ANFScrollableNav
//
//  Created by anthony-fernandez on 07/08/2021.
//  Copyright © 2021 Anthony Niroshan Fernandez. All rights reserved.
//

import UIKit

class MenuIndicatorRoundedEdge: UIView {

    var path: UIBezierPath!
    private let curvePoint: CGFloat = 4.0
    
    @IBInspectable public var indicatorColor: UIColor = UIColor.white
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func createBezierPath() {
        // create a new path
        path = UIBezierPath()

        if self.frame.width > self.frame.height {
            self.horizontaleBar(path: path)
        }
        else {
            self.verticleBar(path: path)
        }

        // segment 5: line
        path.close() // draws the final line to close the path
        
    }
    
    override func draw(_ rect: CGRect) {
        self.createBezierPath()
        

        self.indicatorColor.setFill()
        path.fill()
    }
    
    func verticleBar(path: UIBezierPath) {
        
        // starting point for the path (bottom left)
        path.move(to: CGPoint(x: bounds.maxX, y: bounds.minY))
        
        // segment 2: curve
        path.addCurve(to: CGPoint(x: bounds.minX, y: bounds.minY + curvePoint), // ending point
            controlPoint1: CGPoint(x: bounds.maxX, y: bounds.minY),
            controlPoint2: CGPoint(x: bounds.minX, y: bounds.minY))
        
        // segment 3: line
        path.addLine(to: CGPoint(x: bounds.minX, y: bounds.maxY))
        
        // segment 4: curve
        path.addCurve(to: CGPoint(x: bounds.maxX, y: bounds.maxY - curvePoint), // ending point
            controlPoint1: CGPoint(x: bounds.minX, y: bounds.maxY),
            controlPoint2: CGPoint(x: bounds.maxX, y: bounds.maxY))
    }
    
    func horizontaleBar(path: UIBezierPath) {
        
        // starting point for the path (bottom left)
        path.move(to: CGPoint(x: bounds.minX, y: bounds.maxY))

        // segment 2: curve
        path.addCurve(to: CGPoint(x: bounds.minX + curvePoint, y: bounds.minY), // ending point
            controlPoint1: CGPoint(x: bounds.minX, y: bounds.maxY),
            controlPoint2: CGPoint(x: bounds.minX, y: bounds.minY))

        // segment 3: line
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
        
        // segment 4: curve
        path.addCurve(to: CGPoint(x: bounds.maxX - curvePoint, y: bounds.maxY), // ending point
            controlPoint1: CGPoint(x: bounds.maxX, y: bounds.minY),
            controlPoint2: CGPoint(x: bounds.maxX, y: bounds.maxY))
        
    }
    
    func setIndicatorColor(color: UIColor) {
        self.indicatorColor = color
        self.setNeedsDisplay()
    }
    
    
}
