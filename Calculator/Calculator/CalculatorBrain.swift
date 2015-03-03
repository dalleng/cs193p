//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Diego Allen on 2/10/15.
//  Copyright (c) 2015 Diego Allen. All rights reserved.
//

import Foundation

class CalculatorBrain: Printable {

    private enum Op: Printable {
        case Operand(Double)
        case VariableOperand(String)
        case ConstantOperand(String, Double)
        case UnaryOperation(String, Double -> Double, (Double -> String?)?)
        case BinaryOperation(String, (Double, Double) -> Double, ((Double, Double) -> String?)?)
        
        var description: String {
            switch self {
            case .Operand(let operand):
                return "\(operand)"
            
            case .VariableOperand(let variable):
                return variable
            
            case .ConstantOperand(let constant, _):
                return constant
            
            case .UnaryOperation(let symbol, _, _):
                return symbol
            
            case .BinaryOperation(let symbol, _, _):
                return symbol
            }
        }
    }
    
    private enum Error: String {
        case DivisionByZero = "Error: division by zero"
        case SquareRootOfNegative = "Error: sqrt of negative"
        case NotEnoughOperands = "not enough operands"
        case VariableNotSet = "variable not set"
    }
    
    private var opStack = [Op]()
    private var knownOps = [String: Op]()
    
    var variableValues = [String: Double]()
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return opStack.map { $0.description }
        }
        
        set {
            if let opSymbols = newValue as? [String] {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let operation = knownOps[opSymbol] {
                        newOpStack.append(operation)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    } else {
                        newOpStack.append(.VariableOperand(opSymbol))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    var description: String {
        var stackCopy = opStack
        var expressions = [String]()
        
        while !stackCopy.isEmpty {
            let (description, remainingOps) = buildDescription(parentOp: nil, ops: stackCopy)
            stackCopy = remainingOps
            expressions.append(description)
        }
        
        return ",".join(expressions.reverse())
    }
    
    init() {
        
        func learnOp(op: Op) {
            knownOps[op.description] = op;
        }
        
        func divisionByZeroCheck(divisor: Double, dividend: Double) -> String? {
            if divisor == 0.0 {
                return Error.DivisionByZero.rawValue
            }
            
            return nil
        }
        
        func squareRootOfNegativeCheck(operand: Double) -> String? {
            if operand < 0.0 {
                return Error.SquareRootOfNegative.rawValue
            }
            
            return nil
        }
        
        learnOp(Op.BinaryOperation("+", +, nil))
        learnOp(Op.BinaryOperation("×", *, nil))
        learnOp(Op.BinaryOperation("÷", { $1 / $0 }, divisionByZeroCheck))
        learnOp(Op.BinaryOperation("−", { $1 - $0 }, nil))
        learnOp(Op.UnaryOperation("√", sqrt, squareRootOfNegativeCheck))
        learnOp(Op.UnaryOperation("sin", sin, nil))
        learnOp(Op.UnaryOperation("cos", cos, nil))
        learnOp(Op.ConstantOperand("π", M_PI))
    }
    
    private func buildDescription(#parentOp: Op?, ops: [Op]) -> (description: String, remainingOps: [Op]) {
        var remainingOps = ops
        
        if !ops.isEmpty {
            let op = remainingOps.removeLast()
            
            switch op {
                
            case .Operand:
                return ("\(op)", remainingOps)
                
            case .VariableOperand, .ConstantOperand:
                return ("\(op)", remainingOps)
                
            case .UnaryOperation:
                let (operandDescription, remainder) = buildDescription(parentOp: op, ops: remainingOps)
                return ("\(op)(\(operandDescription))", remainder)
            
            case .BinaryOperation(let symbol, _, _):
                var (op1Description, remainder1) = buildDescription(parentOp: op, ops: remainingOps)
                var (op2Description, remainder2) = buildDescription(parentOp: op, ops: remainder1)
                
                if op2Description == "" {
                    op2Description = "?"
                }
                
                if op1Description == "" {
                    op1Description = "?"
                }
                
                var operationDescription = "\(op2Description) \(op) \(op1Description)"
                
                if let parent = parentOp {
                    switch parent {
                    case .BinaryOperation(let parentSymbol, _, _):
                        if symbol != parentSymbol {
                            operationDescription = "(\(operationDescription))"
                        }
                    default:
                        break
                    }
                }
                
                return (operationDescription, remainder2)
            }
        }
        
        return ("", remainingOps)
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op], error: String?) {
        var remainingOps = ops
        
        if !ops.isEmpty {
            let op = remainingOps.removeLast()
            
            switch op {
            
            case .Operand(let operand):
                return (operand, remainingOps, nil)
            
            case .VariableOperand(let variable):
                if let value = variableValues[variable] {
                    return (value, remainingOps, nil)
                } else {
                    return (nil, remainingOps, Error.VariableNotSet.rawValue)
                }
                
            case .ConstantOperand(_, let constant):
                let operandEvaluation = evaluate(remainingOps)
                return (constant, remainingOps, nil)
            
            case .UnaryOperation(_, let operation, let errorCheck):
                let operandEvaluation = evaluate(remainingOps)
                
                // Check for an error in the evaluation of the operand
                if let errorStr = operandEvaluation.error {
                    return (nil, remainingOps, errorStr)
                }
                
                if let operand = operandEvaluation.result {
                    // Check for error in the unary operation
                    if let errorStr = errorCheck?(operand) {
                        return (nil, operandEvaluation.remainingOps, errorStr)
                    }
                    return (operation(operand), operandEvaluation.remainingOps, nil)
                }
            
            case .BinaryOperation(_, let operation, let errorCheck):
                let op1Evaluation = evaluate(remainingOps)
                
                // Check for an error in the evaluation of the first operand
                if let errorStr = op1Evaluation.error {
                    return (nil, op1Evaluation.remainingOps, errorStr)
                }
               
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    
                    // Check for error in the evaluation of the second operand
                    if let errorStr = op2Evaluation.error {
                        return (nil, op2Evaluation.remainingOps, errorStr)
                    }
                    
                    if let operand2 = op2Evaluation.result {
                        // Check for error in the binary operation
                        if let errorStr = errorCheck?(operand1, operand2) {
                            return (nil, op2Evaluation.remainingOps, errorStr)
                        }
                        
                        return (operation(operand1, operand2), op2Evaluation.remainingOps, nil)
                    } else {
                        return (nil, op1Evaluation.remainingOps, Error.NotEnoughOperands.rawValue)
                    }
                } else {
                    return (nil, remainingOps, Error.NotEnoughOperands.rawValue)
                }
            }
        }
        
        return (nil, remainingOps, nil)
    }
    
    func evaluate() -> (result: Double?, error: String?) {
        // println("opStack: \(opStack)")
        let (result, _, errorStr) = evaluate(opStack)
        return (result, errorStr)
    }
    
    func pushOperand(operand: Double) -> (result: Double?, error: String?) {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> (result: Double?, error: String?) {
        opStack.append(Op.VariableOperand(symbol))
        return evaluate()
    }
    
    func removeLastOp() {
        if !opStack.isEmpty {
            opStack.removeLast()
        }
    }
    
    func performOperation(symbol: String) -> (result: Double?, error: String?) {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        let (result, _, errorStr) = evaluate(opStack)
        return (result, errorStr)
    }
}