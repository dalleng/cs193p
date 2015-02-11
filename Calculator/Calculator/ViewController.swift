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

    var displayValue: Double {
        get {
            return (display.text! as NSString).doubleValue
        }
        
        set {
            display.text = "\(newValue)"
        }
    }

    @IBAction func operate(sender: UIButton) {
        
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        
        if let operation = sender.currentTitle {
            appendToHistory(operation)
            
            switch operation {
                case "π":
                    addConstantAsOperand(M_PI)
                    return
                case "C":
                    display.text = "0"
                    history.text = nil
                    userIsInTheMiddleOfTypingANumber = false
                    return
            default: break
            }
            
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = 0
            }
        }
    }
    
    func addConstantAsOperand(constant: Double) {
        displayValue = constant
        enter()
    }
    
    func appendToHistory(item: String) {
        if history.text == nil {
            history.text = item
        } else {
            history.text = history.text! + " \(item)"
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

    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        
        if let result = brain.pushOperand(displayValue) {
            displayValue = result
        } else {
            displayValue = 0
        }
        
        appendToHistory(display.text!)
    }
}

