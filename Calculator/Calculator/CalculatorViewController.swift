//
//  ViewController.swift
//  Calculator
//
//  Created by Diego Allen on 2/1/15.
//  Copyright (c) 2015 Diego Allen. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!

    var userIsInTheMiddleOfTypingANumber: Bool = false
    var brain = CalculatorBrain()

    var displayValue: (result: Double?, error: String?) {
        get {
            let doubleValue = NSNumberFormatter().numberFromString(display.text!)?.doubleValue
            if doubleValue != nil {
                return (doubleValue, nil)
            } else {
                return (nil, display.text!)
            }
        }
        
        set {
            let (result, errorStr) = newValue
            
            if (errorStr != nil) {
                display.text = errorStr
            } else {
                if result != nil {
                    display.text = "\(result!)"
                } else {
                    display.text = " "
                }
            }
        }
    }

    @IBAction func operate(sender: UIButton) {
        
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        
        if let operation = sender.currentTitle {
            if operation == "C" {
                    display.text = "0"
                    history.text = " "
                    userIsInTheMiddleOfTypingANumber = false
                    brain = CalculatorBrain()
            } else {
                displayValue = brain.performOperation(operation)
                history.text = "\(brain) ="
                println("\(brain)")
            }
        }
    }
    
    @IBAction func invertSign() {
        if userIsInTheMiddleOfTypingANumber {
            if display.text!.hasPrefix("-") {
                let start = Swift.advance(display.text!.startIndex, 1)
                display.text = display.text![start..<display.text!.endIndex]
            } else {
                display.text = "-" + display.text!
            }
        }
    }
    
    @IBAction func deleteUndo() {
        if userIsInTheMiddleOfTypingANumber {
            if countElements(display.text!) > 1 {
                display.text! = dropLast(display.text!)
            } else {
                display.text! = "0"
                userIsInTheMiddleOfTypingANumber = false;
            }
        } else {
            brain.removeLastOp()
            displayValue = brain.evaluate()
            history.text = "\(brain)"
        }
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

    @IBAction func pushVariable(sender: UIButton) {
            displayValue = brain.pushOperand(sender.currentTitle!)
            history.text = "\(brain)"
            userIsInTheMiddleOfTypingANumber = false
    }
    
    @IBAction func setVariableValue(sender: UIButton) {
        let (value, _) = displayValue
        
        if (value != nil) {
            brain.variableValues["M"] = value
            displayValue = brain.evaluate()
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        let (operand, _) = displayValue
        if operand != nil {
            displayValue = brain.pushOperand(operand!)
            history.text = "\(brain) ="
            println("\(brain)")
        }
    }
}

