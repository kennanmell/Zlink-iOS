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
    case zlink1, zlink2, zlink3, zlink4, zlink5, zlink6, zlink7, zlink8, zlink9
    /** A number `Tile`. */
    case number1, number2, number3
    /** An empty (white) `Tile`. */
    case empty
    /** A broken (black/black hole) `Tile`. */
    case broken
    /** A full (gold) `Tile`. */
    case full0, full1, full2, full3, full4, full5, full6, full7, full8
    
    
    // MARK: Properties
    
    /** Contains all possible types of `Tile`s. */
    static let values = [zlink1, zlink2, zlink3, zlink4, zlink5, zlink6, zlink7, zlink8, zlink9, number1, number2, number3, empty, full0, full1, full2, full3, full4, full5, full6, full7, full8, broken]
    
    /**`1` for `.Number1`, `2` for `.Number2`, `3` for `.Number3`, and `nil` for all other types of `Tile`. */
    var intValue: Int? {
        switch (self) {
        case .number1: return 1
        case .number2: return 2
        case .number3: return 3
        default: return nil
        }
    }
    
    /** `true` if and only if `self` is `.Number1`, `.Number2`, or `.Number3`. */
    var isNumber: Bool {
        switch (self) {
        case .number1: return true
        case .number2: return true
        case .number3: return true
        default: return false
        }
    }
    
    /** `true` if and only if `self` is one of `Zlink1` - `Zlink9`. */
    var isZlink: Bool {
        switch (self) {
        case .zlink1: return true
        case .zlink2: return true
        case .zlink3: return true
        case .zlink4: return true
        case .zlink5: return true
        case .zlink6: return true
        case .zlink7: return true
        case .zlink8: return true
        case .zlink9: return true
        default: return false
        }
    }
        
    /** `true` if and only if `self` is one of `Full0` - `Full10`. */
    var isFull: Bool {
        switch self {
        case .full0: return true
        case .full1: return true
        case .full2: return true
        case .full3: return true
        case .full4: return true
        case .full5: return true
        case .full6: return true
        case .full7: return true
        case .full8: return true
        default: return false
        }
    }
    
    /** `true` if and only if `self.isFull`, `self.isZlink`, or `self.isNumber`. */
    var isConnectable: Bool {
        return self.isFull || self.isZlink || self.isNumber
    }
    
}
