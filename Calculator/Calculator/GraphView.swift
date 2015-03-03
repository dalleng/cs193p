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
        willSet {
            if origin != nil && newValue != nil {
                originDelta += (newValue! - origin!)
            }
        }
        
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    private var path: UIBezierPath?
    private var originDelta = CGPointZero
    
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
        var maxWidthPixels = Int(self.bounds.width * self.contentScaleFactor)
        
        if let savedPath = path {
            println("originDelta \(originDelta)")
            let (dx, dy) = (originDelta.x, originDelta.y)
            
            savedPath.applyTransform(CGAffineTransformMakeTranslation(dx, dy))
            
            if dx > 0 {
                savedPath.appendPath(buildPath(fromPixelInX: 0, toPixel: Int(dx * self.contentScaleFactor)))
            } else {
                let start = Int((self.bounds.width + dx) * self.contentScaleFactor)
                let end = Int(self.bounds.width * self.contentScaleFactor)
                savedPath.appendPath(buildPath(fromPixelInX: start, toPixel: end))
            }
            
            savedPath.stroke()
            
        } else {
            path = buildPath(fromPixelInX: 0, toPixel: maxWidthPixels)
            path?.stroke()
        }
        
        originDelta = CGPointZero
    }
    
    private func buildPath(#fromPixelInX: Int, toPixel: Int) -> UIBezierPath {
        let path = UIBezierPath()
        var initialPoint = true

        for var i = fromPixelInX; i <= toPixel; i++ {
            let x = (CGFloat(i) / self.contentScaleFactor - origin!.x) / scale
            if let y = self.dataSource?.yCoordinateForX(x) {
                var point = CGPointZero
                point.x = CGFloat(i) / self.contentScaleFactor
                point.y = origin!.y - (y * scale)
                if initialPoint {
                    path.moveToPoint(point)
                    initialPoint = false
                } else {
                    path.addLineToPoint(point)
                    path.moveToPoint(point)
                }
            }
        }
        
        return path
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
            path = nil
        }
    }

}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func += (inout left: CGPoint, right: CGPoint) {
    left = left + right
}

func -= (inout left: CGPoint, right: CGPoint) {
    left = left - right
}

