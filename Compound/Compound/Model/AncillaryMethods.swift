//
//  AncillaryMethods.swift
//  Compound
//
//  Created by robert on 13/12/2018.
//  Copyright © 2018 Robert Zakiev. All rights reserved.
//

import Foundation

//Just a convenient method for converting garbage like "5221.234234234" into "5.2k"
func simplify (number: Double) -> String {
    var finalString: String
    switch number {
    case 1000..<1000000: finalString = "\(String(format: "%.1f",number/1000))K"
    case 1000000...: finalString = "\(String(format: "%.3f",number/1000000))M"
    default:
        finalString = String(format: "%.1f",number)
    }
    
    if finalString.contains(".0") { finalString.removeSubrange(finalString.range(of: ".0")!) }
    return finalString
}


