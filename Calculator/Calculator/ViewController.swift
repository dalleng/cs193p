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
    @IBOutlet weak var history: UILabel!

    var userIsInTheMiddleOfTypingANumber: Bool = false
    var brain = CalculatorBrain()

    var displayValue: Double? {
        get {
            return (display.text! as NSString).doubleValue
        }
        
        set {
            if newValue != nil {
                display.text = "\(newValue!)"
            } else {
                display.text = " "
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
                if let result = brain.performOperation(operation) {
                    displayValue = result
                } else {
                    displayValue = 0
                    history.text = " "
                }
                
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
    
    @IBAction func deleteLastDigit() {
        if userIsInTheMiddleOfTypingANumber {
            if countElements(display.text!) > 1 {
                display.text! = dropLast(display.text!)
            } else {
                display.text! = "0"
                userIsInTheMiddleOfTypingANumber = false;
            }
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
        if let result = brain.pushOperand(sender.currentTitle!) {
            displayValue = result
            history.text = "\(brain)"
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    
    @IBAction func setVariableValue(sender: UIButton) {
        if let value = displayValue {
            brain.variableValues["M"] = value
            if let result = brain.evaluate() {
                displayValue = result
            }
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        
        if let operand = displayValue {
            if let result = brain.pushOperand(operand) {
                displayValue = result
                history.text = "\(brain) ="
                println("\(brain)")
            } else {
                displayValue = 0
                history.text = " "
            }
        }
    }
}

