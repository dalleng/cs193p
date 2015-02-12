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
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            switch self {
            
            case .Operand(let operand):
                return "\(operand)"
            
            case .VariableOperand(let variable):
                return variable
            
            case .ConstantOperand(let constant, _):
                return constant
            
            case .UnaryOperation(let symbol, _):
                return symbol
            
            case .BinaryOperation(let symbol, _):
                return symbol
            }
        }
    }
    
    private var opStack = [Op]()
    private var knownOps = [String: Op]()
    
    var variableValues = [String: Double]()
    
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
        
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("÷") { $1 / $0 })
        learnOp(Op.BinaryOperation("−") { $1 - $0 })
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
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
            
            case .BinaryOperation(let symbol, _):
                let (op1Description, remainder1) = buildDescription(parentOp: op, ops: remainingOps)
                var (op2Description, remainder2) = buildDescription(parentOp: op, ops: remainder1)
                
                if op2Description == "" {
                    op2Description = "?"
                }
                
                var operationDescription = "\(op2Description) \(op) \(op1Description)"
                
                if let parent = parentOp {
                    switch parent {
                    case .BinaryOperation(let parentSymbol, _):
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
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        var remainingOps = ops
        
        if !ops.isEmpty {
            let op = remainingOps.removeLast()
            
            switch op {
            
            case .Operand(let operand):
                return (operand, remainingOps)
            
            case .VariableOperand(let variable):
                if let value = variableValues[variable] {
                    return (value, remainingOps)
                }
                
            case .ConstantOperand(_, let constant):
                let operandEvaluation = evaluate(remainingOps)
                return (constant, remainingOps)
                
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
               
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        
        return (nil, remainingOps)
    }
    
    func evaluate() -> Double? {
        println("opStack: \(opStack)")
        let (result, _) = evaluate(opStack)
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.VariableOperand(symbol))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
}