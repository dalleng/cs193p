//
//  GraphViewController.swift
//  Calculator
//
//  Created by Diego Allen on 2/27/15.
//  Copyright (c) 2015 Diego Allen. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {
    
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
            
            // double-tap to change the origin
            let tgr = UITapGestureRecognizer(target: graphView, action: "changeOrigin:")
            tgr.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(tgr)
            
            // pan the view to move the graph
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: "moveGraph:"))
            
            // pinch to zoom
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: "zoomGraph:"))
        }
    }
    
    func yCoordinateForX(x: CGFloat) -> CGFloat? {
        brain.variableValues["M"] = Double(x)
        let (result, _) = brain.evaluate()
        return result != nil ? CGFloat(result!) : nil
    }
    
}
