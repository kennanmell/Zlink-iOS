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
    
    case Down, Up, Left, Right
    
    
    // MARK: Properties
    
    /** Contains all possible types of `Direction`s. */
    static let values = [Down, Up, Left, Right]
    
    
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
        case .Up:
            return Direction.Down;
        case .Down:
            return Direction.Up;
        case .Right:
            return Direction.Left;
        case .Left:
            return Direction.Right;
        }
    }
    
}