//
//  RNG.swift
//  Zlink
//
//  Created by Kennan Mell on 2/8/16.
//  Copyright © 2016 MegaWatt Gaming. All rights reserved.
//

import Foundation

/** `RNG` is a collection of static functions that produce pseudo-random numbers. */
struct RNG {
    
    /**
     Generates a random `Bool` value.
     - returns: `true` approximately 50% of the time.
     */
    static func generateBool() -> Bool {
        return arc4random_uniform(2) == 0
    }
    
    /**
     Generates a random `Int` value between 0 (inclusive) and a specified ceiling (exclusive). Distribution is approximately uniform.
     - parameters:
       - ceiling: The upper bound on the number that can be generated (not inclusive).
     - requires: `ceiling > 0`
     - returns: A pseudo-random integer between 0 (inclusive) and `ceiling` (exclusive)
     */
    static func generateInt(ceiling: Int) -> Int {
        if ceiling < 1 {
            fatalError("Ceiling must be positive.")
        }
        return Int(arc4random_uniform(UInt32(ceiling)))
    }
    
    /**
     Generates a random `Int` value between 0 (inclusive) and a specified ceiling (exclusive). Distribution is skewed to return values closer to (or equal to) a specified peak more frequently.
     - parameters:
        - ceiling: The upper bound on the number that can be generated (not inclusive).
        - peak: The value to return most frequently.
     - requires: `ceiling > 0 && peak >= 0 && peak < ceiling`
     - returns: A pseudo-random integer between 0 (inclusive) and `ceiling` (exclusive)
     */
    static func generateIntTriangle(ceiling: Int, peak: Int) -> Int {
        if ceiling < 1 {
            fatalError("ceiling < 1")
        }
        if peak < 0 {
            fatalError("peak < 0")
        }
        if peak >= ceiling {
            fatalError("peak >= ceiling")
        }
        
        var distribution = Array<Int>()
        distribution.append(1)
        
        for i in 1..<max(1, peak) {
            distribution.append(distribution[i - 1] + 1)
        }
        
        for i in max(1, peak)..<ceiling {
            distribution.append(distribution[i - 1] - 1)
        }
        
        if distribution[distribution.count - 1] < 1 {
            let difference = 1 - distribution[distribution.count - 1]
            
            for i in 0..<distribution.count {
                distribution[i] += difference
            }
        }
        
        for i in 1..<distribution.count {
            distribution[i] = distribution[i] + distribution[i - 1]
        }
        
        let uniformResult = generateInt(distribution[distribution.count - 1])
        
        for i in 0..<distribution.count {
            if uniformResult < distribution[i] {
                return i
            }
        }
        
        return ceiling - 1
    }
    
}