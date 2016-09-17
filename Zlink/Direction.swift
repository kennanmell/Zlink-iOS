//
//  Direction.swift
//  Zlink
//
//  Created by Kennan Mell on 2/14/16.
//  Copyright © 2016 MegaWatt Gaming. All rights reserved.
//

import Foundation

/**
 `Direction` represents the different directions on a `Board`.
 
 - seealso: `Board`
 */
enum Direction {
    
    case down, up, left, right
    
    
    // MARK: Properties
    
    /** Contains all possible types of `Direction`s. */
    static let values = [down, up, left, right]
    
    
    // MARK: Functions
    
    /**
    Returns the direction opposite of `self`.
    - returns:
        + `Down` if `self` is `Up`
        + `Up` if `self` is `Down`
        + `Left` if `self` is `Right`
        + `Right` if `self` is `Left`
    */
    func invert() -> Direction {
        switch (self) {
        case .up:
            return Direction.down;
        case .down:
            return Direction.up;
        case .right:
            return Direction.left;
        case .left:
            return Direction.right;
        }
    }
    
}
