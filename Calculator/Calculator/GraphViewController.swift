//
//  GraphViewController.swift
//  Calculator
//
//  Created by Diego Allen on 2/27/15.
//  Copyright (c) 2015 Diego Allen. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {
    
    private enum StandardUserDefaultsKeys: String {
        case scale = "GraphViewController.scale"
        case originX = "GraphViewController.origin.x"
        case originY = "GraphViewController.origin.y"
    }
    
    private var brain = CalculatorBrain()
    typealias PropertyList = AnyObject

    var program: PropertyList {
        get { return brain.program }
        set { brain.program = newValue }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = split(brain.description, { $0 == "," }).last
    }
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
            loadDefaults()
            addGestureRecognizers()
        }
    }
    
    private func loadDefaults() {
        var origin = CGPointZero
        let standardUserDefaults = NSUserDefaults.standardUserDefaults().dictionaryRepresentation()
        
        if let scale = standardUserDefaults[StandardUserDefaultsKeys.scale.rawValue] as? Double {
            graphView.scale = CGFloat(scale)
        }
        
        if let x = standardUserDefaults[StandardUserDefaultsKeys.originX.rawValue] as? Double {
            if let y = standardUserDefaults[StandardUserDefaultsKeys.originY.rawValue] as? Double {
                origin.x = CGFloat(x)
                origin.y = CGFloat(y)
                graphView.origin = origin
            }
        }
    }
    
    private func addGestureRecognizers() {
        // double-tap to change the origin
        let tgr = UITapGestureRecognizer(target: graphView, action: "changeOrigin:")
        tgr.numberOfTapsRequired = 2
        graphView.addGestureRecognizer(tgr)
        
        // pan the view to move the graph
        graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: "moveGraph:"))
        
        // pinch to zoom
        graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: "zoomGraph:"))
    }
    
    func yCoordinateForX(x: CGFloat) -> CGFloat? {
        brain.variableValues["M"] = Double(x)
        let (result, _) = brain.evaluate()
        return result != nil ? CGFloat(result!) : nil
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSUserDefaults.standardUserDefaults().setDouble(Double(self.graphView.scale), forKey: StandardUserDefaultsKeys.scale.rawValue)
        
        if let origin = self.graphView.origin {
            NSUserDefaults.standardUserDefaults().setDouble(
                Double(origin.x),
                forKey: StandardUserDefaultsKeys.originX.rawValue)
            NSUserDefaults.standardUserDefaults().setDouble(
                Double(origin.y),
                forKey: StandardUserDefaultsKeys.originY.rawValue)
        }
        
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
}
