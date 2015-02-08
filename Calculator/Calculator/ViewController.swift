//
//  ViewController.swift
//  Calculator
//
//  Created by Diego Allen on 2/1/15.
//  Copyright (c) 2015 Diego Allen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!

    var operands = [Double]()
    var userIsInTheMiddleOfTypingANumber: Bool = false

    var displayValue: Double {
        get {
            return (display.text! as NSString).doubleValue
        }
        
        set {
            display.text = "\(newValue)"
        }
    }

    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        
        switch operation {
            case "×":
                performOperation { $0 * $1 }
            case "÷":
                performOperation { $1 / $0 }
            case "+":
                performOperation { $0 + $1 }
            case "−":
                performOperation { $1 - $0 }
            case "√":
                performOperation { sqrt($0) }
            case "sin":
                performOperation { sin($0) }
            case "sin":
                performOperation { cos($0) }
            case "π":
                addConstantAsOperand(M_PI)
        default: break
        }
    }
    
    func performOperation(operation: (Double, Double) -> Double) {
        if operands.count >= 2 {
            displayValue = operation(operands.removeLast(), operands.removeLast())
            enter()
        }
    }
    
    func performOperation(operation: Double -> Double) {
        if operands.count >= 1 {
            displayValue = operation(operands.removeLast())
            enter()
        }
    }
    
    func addConstantAsOperand(constant: Double) {
        displayValue = constant
        enter()
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTypingANumber {
            let hasFloatingPoint = display.text!.rangeOfString(".") != nil
            
            if !hasFloatingPoint || digit != "." {
                display.text = display.text! + digit
            }
            
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }

    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        operands.append(displayValue)
        println("\(operands)")
    }
}

