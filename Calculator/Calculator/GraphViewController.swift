//
//  GraphViewController.swift
//  Calculator
//
//  Created by Diego Allen on 2/27/15.
//  Copyright (c) 2015 Diego Allen. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {
    @IBOutlet weak var graphView: GraphView! {
        didSet {
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
}
