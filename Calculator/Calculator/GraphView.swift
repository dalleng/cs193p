//
//  GraphView.swift
//  Calculator
//
//  Created by Diego Allen on 2/27/15.
//  Copyright (c) 2015 Diego Allen. All rights reserved.
//

import UIKit

protocol GraphViewDataSource: class {
    func yCoordinateForX(x: CGFloat) -> CGFloat?
}

@IBDesignable
class GraphView: UIView {
    
    var axesDrawer = AxesDrawer()
    weak var dataSource: GraphViewDataSource?
    
    private var origin: CGPoint? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    private var scale: CGFloat = 50.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func drawRect(rect: CGRect) {
        origin = origin ?? self.convertPoint(self.center, fromView: self.superview)
        axesDrawer.contentScaleFactor = self.contentScaleFactor
        axesDrawer.drawAxesInRect(self.bounds, origin: origin!, pointsPerUnit: scale)
        plotFunction()
    }
    
    private func plotFunction() {
        let path = UIBezierPath()        
        let maxWidthPixels = Int(self.bounds.width * self.contentScaleFactor)
        
        for var i = 0; i <= maxWidthPixels; i++ {
            let x = (CGFloat(i) / self.contentScaleFactor - origin!.x) / scale
            if let y = self.dataSource?.yCoordinateForX(x) {
                println("x:\(x) y:\(y)")
                var point = CGPointZero
                point.x = CGFloat(i) / self.contentScaleFactor
                point.y = origin!.y - (y * scale)
                path.addLineToPoint(point)
                path.moveToPoint(point)
            }
            path.stroke()
        }
    }
    
    func changeOrigin(gesture: UITapGestureRecognizer) {
        if gesture.state == .Ended {
            origin = gesture.locationInView(self)
        }
    }
    
    func moveGraph(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Changed, .Ended:
            origin! += gesture.translationInView(self)
            gesture.setTranslation(CGPointZero, inView: self)
        default: break
        }
    }
    
    func zoomGraph(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            scale *= gesture.scale
            gesture.scale = 1.0
        }
    }

}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func += (inout left: CGPoint, right: CGPoint) {
    left = left + right
}
