//
//  GraphView.swift
//  Calculator
//
//  Created by Diego Allen on 2/27/15.
//  Copyright (c) 2015 Diego Allen. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {
    
    var axesDrawer = AxesDrawer()
    
    private var origin: CGPoint? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    private var scale: CGFloat = 50.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func drawRect(rect: CGRect) {
        origin = origin ?? self.convertPoint(self.center, fromView: self.superview)
        axesDrawer.contentScaleFactor = self.contentScaleFactor
        axesDrawer.drawAxesInRect(self.bounds, origin: origin!, pointsPerUnit: scale)
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
