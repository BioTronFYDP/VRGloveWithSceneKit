//
//  Random.swift
//  Symmetra
//
//  Created by Si Te Feng on 11/20/16.
//  Copyright © 2016 Technochimera. All rights reserved.
//

import Cocoa

class Random: NSObject {
    
    class func randInt(from: Int, to: Int) -> Int {
        
        guard from <= to else {
            assert(from <= to, "1st parameter must be less or equal to 2nd")
            return 0
        }
        
        let diff = to-from
        let randomInt = from + Int(arc4random() % UInt32(diff+1))
        return randomInt
    }
    
    class func randDouble(from: Double, to: Double) -> Double {
        
        guard from <= to else {
            assert(from <= to, "1st parameter must be less or equal to 2nd")
            return 0
        }
        
        let resolution = 1000000.0
        let diff = to-from
        let rand = from + Double(arc4random() % UInt32(diff * resolution + 1)) / resolution
        return rand
    }
    
    class func randCGFloat(from: CGFloat, to: CGFloat) -> CGFloat {
        return CGFloat(Random.randDouble(from: Double(from), to: Double(to)))
    }
    
}
