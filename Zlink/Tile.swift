//
//  Tile.swift
//  Zlink
//
//  Created by Kennan Mell on 2/14/16.
//  Copyright © 2016 MegaWatt Gaming. All rights reserved.
//

import Foundation

/**
 `Tile` represents the different types of tiles on a `Board`.
 
 - seealso: `Board`
 */
enum Tile {
    
    /** A Zlink `Tile`. */
    case Zlink1, Zlink2, Zlink3, Zlink4, Zlink5, Zlink6, Zlink7, Zlink8, Zlink9
    /** A number `Tile`. */
    case Number1, Number2, Number3
    /** An empty (white) `Tile`. */
    case Empty
    /** A broken (black/black hole) `Tile`. */
    case Broken
    /** A full (gold) `Tile`. */
    case Full0, Full1, Full2, Full3, Full4, Full5, Full6, Full7, Full8
    
    
    // MARK: Properties
    
    /** Contains all possible types of `Tile`s. */
    static let values = [Zlink1, Zlink2, Zlink3, Zlink4, Zlink5, Zlink6, Zlink7, Zlink8, Zlink9, Number1, Number2, Number3, Empty, Full0, Full1, Full2, Full3, Full4, Full5, Full6, Full7, Full8, Broken]
    
    /**`1` for `.Number1`, `2` for `.Number2`, `3` for `.Number3`, and `nil` for all other types of `Tile`. */
    var intValue: Int? {
        switch (self) {
        case .Number1: return 1
        case .Number2: return 2
        case .Number3: return 3
        default: return nil
        }
    }
    
    /** `true` if and only if `self` is `.Number1`, `.Number2`, or `.Number3`. */
    var isNumber: Bool {
        switch (self) {
        case .Number1: return true
        case .Number2: return true
        case .Number3: return true
        default: return false
        }
    }
    
    /** `true` if and only if `self` is one of `Zlink1` - `Zlink9`. */
    var isZlink: Bool {
        switch (self) {
        case .Zlink1: return true
        case .Zlink2: return true
        case .Zlink3: return true
        case .Zlink4: return true
        case .Zlink5: return true
        case .Zlink6: return true
        case .Zlink7: return true
        case .Zlink8: return true
        case .Zlink9: return true
        default: return false
        }
    }
        
    /** `true` if and only if `self` is one of `Full0` - `Full10`. */
    var isFull: Bool {
        switch self {
        case .Full0: return true
        case .Full1: return true
        case .Full2: return true
        case .Full3: return true
        case .Full4: return true
        case .Full5: return true
        case .Full6: return true
        case .Full7: return true
        case .Full8: return true
        default: return false
        }
    }
    
    /** `true` if and only if `self.isFull`, `self.isZlink`, or `self.isNumber`. */
    var isConnectable: Bool {
        return self.isFull || self.isZlink || self.isNumber
    }
    
}