//
//  Board.swift
//  Zlink
//
//  Created by Kennan Mell on 1/15/16.
//  Copyright © 2016 MegaWatt Gaming. All rights reserved.
//

import Foundation

/**
 `Board` is an abstract data type that represents a board the Zlink game is played on. `Board` instances have a subscript for accessing the `Tile` types at their locations.
 
 Note that while a board is a square, its locations are accessed and modified with only one `Int` in order to simplify iteration. The `Int` representing a location of 0-based coordinates (x,y) (where (0,0) would be the top left location) is y * `length` + x.

 `Board` offers listeners for all changes to its internal state. A `BoardListener` can be notified of any change to the `Tile` types of a `Board`, while a `ScoreListener` can be notified of any change to the `score` of a `Board`.

 `Board` conforms to `NSCoding`.
 
 - seealso: `BoardListener`, `ScoreListener`, `BoardFiller`, `Direction`, `Tile`
*/
class Board: NSObject, NSCoding {
    
    // MARK: Subscript
    
    /**
     Subscript notation to get/set the type of `Tile` at locations of `self`.
     
     The `BoardListener` (if any) is notified of the change through `tileSet`.
     
     - parameters:
        - location: The location of the `Tile` to get/set.
        - type: The type of `Tile` to set `index` to (set only).
     
     - returns: The type of `Tile` at `location` (get only).
     
     - requires: `location` is at least `0` and less than `self.totalTiles`.
     */
    subscript(location: Int) -> Tile {
        get {
            if (location < 0 || location >= totalTiles) {
                fatalError("Board index out of range.")
            }
            return tileArray[location]
        }
        set(type) {
            boardListener?.tileSet(location: location, before: tileArray[location], after: type)
            tileArray[location] = type
        }
    }
    
    
    // MARK: Properties
    
    /** The number of tiles in one row or column of the board represented by `self`. */
    let rowLength: Int
    
    /** Equal to `self.length * self.length`. */
    let totalTiles: Int
    
    /** Stores the `Tile` type at each location of `self`. */
    fileprivate var tileArray: Array<Tile>
    
    /** The number of Zlinks that have been removed from `self` via `removeConnections` since `self` was last cleared or initialized. */
    fileprivate(set) var score: Int
    
    /**
     `true` if and only if `!self.canMoveTile(i, inDirection: d)` for all `0 <= i < totalTiles` and all `d`.
     */
    var isGameOver: Bool {
        for i in 0..<totalTiles {
            for direction in Direction.values {
                if canMoveTile(location: i, inDirection: direction) {
                    return false
                }
            }
        }
        
        return true
    }
    
    /** `true` if and only if `self` has a link. */
    var hasLink: Bool {
        return checkLinks() != nil
    }
    
    /** `true` if and only if `self[i] == .Broken` for some `i` such that `0 <= i < totalTiles`. */
    var isBroken: Bool {
        for tile in tileArray {
            if tile == .broken {
                return true
            }
        }
        return false
    }
    
    /** If this property is not `nil`, its protocol functions will be called when the `Tile` types of `self` are mutated in any way (except via the subscript). */
    var boardListener: BoardListener?

    /** The `ScoreListener` of `self`. This listener, if any, will be notified of all changes to the `score` property of `self`. */
    var scoreListener: ScoreListener?
    
    
    // MARK: Initialization
    
    /**
    Returns a new `Board` instance.
     
    - parameters:
        - rowLength: The row and column length of the instance to return.
     
     - postcondition:
        + `self.score == 0`
        + `self[i] == .Empty` for all `0 <= i < self.totalTiles`
     
     - requires: `rowLength` is a positive `Int`.
    */
    init(rowLength: Int) {
        if rowLength <= 0 {
            fatalError("Board length must be positive.")
        }
        
        self.rowLength = rowLength
        self.totalTiles = rowLength * rowLength
        
        self.score = 0
        self.tileArray = Array<Tile>(repeating: .empty, count: totalTiles)
    }
    
    /**
     Returns a new `Board` instance with the same abstract value as another `Board`.
     
     - parameters:
        - otherBoard: The `Board` instance to copy.
     
     - postcondition: `self.score == otherBoard.score && self.rowLength == otherBoard.rowLength &&  self[i] == otherBoard[i]` for all 0 <= i < totalTiles.
     */
    init(otherBoard: Board) {
        self.rowLength = otherBoard.rowLength
        self.totalTiles = otherBoard.totalTiles
        self.score = otherBoard.score
        self.tileArray = otherBoard.tileArray
    }
    
    
    // MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        // Store properties.
        aCoder.encode(score, forKey: BoardEncodingKeys.scoreKey)
        aCoder.encode(rowLength, forKey: BoardEncodingKeys.rowLengthKey)
        
        // Store each location's current `Tile` type.
        for i in 0..<totalTiles {
            aCoder.encode(String(describing: tileArray[i]))
        }
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // Initialize with stored row length.
        self.init(rowLength: aDecoder.decodeInteger(forKey: BoardEncodingKeys.rowLengthKey))
        
        // Set `score` to stored score.
        self.score = aDecoder.decodeInteger(forKey: BoardEncodingKeys.scoreKey)
        
        // Set each location's `Tile` type.
        for i in 0..<totalTiles {
            switch aDecoder.decodeObject() as! String {
            case String(describing: Tile.empty): tileArray[i] = .empty
            case String(describing: Tile.full0): tileArray[i] = .full0
            case String(describing: Tile.full1): tileArray[i] = .full1
            case String(describing: Tile.full2): tileArray[i] = .full2
            case String(describing: Tile.full3): tileArray[i] = .full3
            case String(describing: Tile.full4): tileArray[i] = .full4
            case String(describing: Tile.full5): tileArray[i] = .full5
            case String(describing: Tile.full6): tileArray[i] = .full6
            case String(describing: Tile.full7): tileArray[i] = .full7
            case String(describing: Tile.full8): tileArray[i] = .full8
            case String(describing: Tile.broken): tileArray[i] = .broken
            case String(describing: Tile.number1): tileArray[i] = .number1
            case String(describing: Tile.number2): tileArray[i] = .number2
            case String(describing: Tile.number3): tileArray[i] = .number3
            case String(describing: Tile.zlink1): tileArray[i] = .zlink1
            case String(describing: Tile.zlink2): tileArray[i] = .zlink2
            case String(describing: Tile.zlink3): tileArray[i] = .zlink3
            case String(describing: Tile.zlink4): tileArray[i] = .zlink4
            case String(describing: Tile.zlink5): tileArray[i] = .zlink5
            case String(describing: Tile.zlink6): tileArray[i] = .zlink6
            case String(describing: Tile.zlink7): tileArray[i] = .zlink7
            case String(describing: Tile.zlink8): tileArray[i] = .zlink8
            case String(describing: Tile.zlink9): tileArray[i] = .zlink9
            default: fatalError("Unable to initialize with NSCoding.")
            }
        }
    }
    
    
    // MARK: Functions
    
    /**
     Moves the `Tile` at a location of `self` in a specified `Direction` (if doing so is possible).
     
     The `BoardListener` (if any) is notified of the change through `tileMoved`.
     
     - parameters:
        - location: The location of the `Tile` on `self` to move.
        - toType: The `Direction` to move in.
     
     - requires: `location` is at least `0` and less than `self.totalTiles`.
     
     - returns: `true` if and only if the state of `self` was changed by this function.
    */
    func moveTile(location: Int, inDirection direction: Direction) -> Bool {
        if (location < 0 || location >= totalTiles) {
            fatalError("Board index out of range.")
        }
        
        if (!canMoveTile(location: location, inDirection: direction)) {
            return false;
        }
        let steps = tileArray[location].intValue!
        var locationX = location;
        for _ in 1...steps {
            locationX = shift(location: locationX, inDirection: direction)!;
            boardListener?.tileMoved(location: locationX, before: tileArray[locationX], after: .full8)
            tileArray[locationX] = .full8
        }
        
        boardListener?.tileMoved(location: location, before: tileArray[location], after: .empty)
        tileArray[location] = Tile.empty;
        
        return true;
    }
    
    /**
     Turns all `Empty` tiles on `self` into `Full9` tiles.
     
     The `BoardListener` (if any) is notified of the change through `tileMagicWanded`.
     
     - postcondition: self[i] != .Empty` for all `0 <= i < self.totalTiles`
     */
    func magicWand() {
        for i in 0..<totalTiles {
            if tileArray[i] == .empty {
                boardListener?.tileMagicWanded(location: i, before: tileArray[i], after: .full7)
                tileArray[i] = .full7
            }
        }
    }
    
    /**
     Turns all `Broken` tiles on `self` into `Empty` tiles.
     
     The `BoardListener` (if any) is notified of the change through `tileRepaired`.
     
     - postcondition: `!self.isBroken`
     */
    func repairBoard() {
        for i in 0..<totalTiles {
            if tileArray[i] == .broken {
                boardListener?.tileRepaired(location: i, before: .broken, after: .empty)
                tileArray[i] = .empty
            }
        }
    }
        
    /**
    Clears `self`.
     
     The `BoardListener` (if any) is notified of the change through `tileCleared`. The `ScoreListener` (if any) is notified of the change through `scoreCleared`.
     
    - postcondition:
        + `self.score == 0`
        + `self[i] == .Empty` for all `0 <= i < self.totalTiles`
    */
    func clear() {
        scoreListener?.onScoreCleared()
        score = 0
        for i in 0..<totalTiles {
            boardListener?.tileCleared(location: i, before: tileArray[i], after: .empty)
            tileArray[i] = .empty
        }
    }
    
    /**
     Decreases the number of each full tile on `self` by one. (Ex. `Full6` becomes `Full5`, `Full0` becomes `Broken`.)
     
     The `BoardListener` (if any) is notified of the change through `tileTimeStepped`.
     */
    func stepTime() {
        for i in 0..<totalTiles {
            let newType: Tile?
            switch tileArray[i] {
            case .full0: newType = .broken
            case .full1: newType = .full0
            case .full2: newType = .full1
            case .full3: newType = .full2
            case .full4: newType = .full3
            case .full5: newType = .full4
            case .full6: newType = .full5
            case .full7: newType = .full6
            case .full8: newType = .full7
            default: newType = nil
            }
            
            if newType != nil {
                boardListener?.tileTimeStepped(location: i, before: tileArray[i], after: newType!)
                tileArray[i] = newType!
            }
        }
    }
    
    /**
     Removes all links from `self`. Updates the score of `self` to reflect the number of Zlinks removed by the link, if any.
     
     The `BoardListener` (if any) is notified of the change through `tileLinked`.
     
     - postcondition: `!self.hasLink`
     
     - returns: `true` if and only if the state of `self` was changed by this function.
     */
    func removeLinks() -> Bool {
        let location = checkLinks()
        if location == nil {
            return false;
        }
        
        removeLinksHelper(location: location!)
        return true
    }
    
    /**
     Recursive helper function for `removeConnections()`.
     
     - requires: location is at least 0 and less than `self.totalTiles`.
     */
    fileprivate func removeLinksHelper(location: Int!) {
        if location != nil && tileArray[location].isConnectable {
            if tileArray[location].isZlink {
                score += 1
                scoreListener?.onScoreIncremented(newScore: score)
            }

            boardListener?.tileLinked(location: location, before: tileArray[location], after: .empty)
            tileArray[location] = .empty;
            
            for direction in Direction.values {
                removeLinksHelper(location: shift(location: location, inDirection: direction));
            }
        }
    }
    
    /**
     Helper function to determine the location of links on `self`, if any.
     
     - returns: If there are links on `self`, returns a location on `self` that is part of a link on `self`. Returns `nil` if there are no links.
     */
    fileprivate func checkLinks() -> Int? {
        for i in 0..<totalTiles {
            if (tileArray[i].isZlink && checkLinksHelper(location: i, previous: Set())) {
                return i;
            }
        }
        return nil
    }
    
    /** Recursive helper function for `checkConnections()`. */
    fileprivate func checkLinksHelper(location: Int, previous: Set<Int>) -> Bool {
        var current = previous
        current.insert(location)
        for direction in Direction.values {
            let newLocation: Int! = shift(location: location, inDirection: direction)
            if newLocation != nil && !previous.contains(newLocation) && (tileArray[newLocation].isZlink || (tileArray[newLocation].isConnectable && checkLinksHelper(location: newLocation, previous: current))) {
                return true;
            }
        }
        return false;
    }

    /**
     Non-mutating function that checks whether or not a `Tile` at a specified location on `self` can be moved in a specified `Direction`.
     
     - parameters:
        - atLocation: The location on `self` to attempt to use a magic tile on.
        - inDirection: The `Direction` to attempt to move the `Tile`.
     
     - returns: `true` if and only if the `Tile` at the specified location can be moved in the specified `Direction`.
     
     - requires: `location` is at least `0` and less than `self.totalTiles`.
     */
    func canMoveTile(location: Int, inDirection direction: Direction) -> Bool {
        if (location < 0 || location >= totalTiles) {
            fatalError("Board index out of range.")
        }

        let steps: Int! = tileArray[location].intValue;
        if (steps == nil) {
            return false;
        }
        
        let l1 = shift(location: location, inDirection: direction);
        if l1 == nil || tileArray[l1!] != .empty {
            return false
        } else if steps == 1 {
            return true
        }
        
        let l2 = shift(location: l1!, inDirection: direction);
        if l2 == nil || tileArray[l2!] != .empty {
            return false
        } else if steps == 2 {
            return true
        }
        
        let l3 = shift(location: l2!, inDirection: direction);
        if l3 == nil || tileArray[l3!] != .empty {
            return false
        } else {
            // steps == 3
            return true
        }
    }
    
    /**
     Non-mutating function for conveniently navigating a `Board`. Returns a location adjacent to a specified location.
     
     - parameters:
        - location: The location to start from.
        - inDirection: The `Direction` to shift in.
     
     - returns: Returns the adjacent location to the specified location in the specified `Direction`. Returns `nil` if there is no adjacent location to `location` in the specified `Direction`.
     
     - requires: `location` is at least `0` and less than `self.totalTiles`.
     */
    func shift(location: Int, inDirection direction: Direction) -> Int? {
        if location < 0 || location >= totalTiles {
            fatalError("Location out of bounds.")
        }
        
        switch direction {
        case .up:
            if (location < rowLength) {
                return nil
            }
            return location - rowLength;
        case .down:
            if (location + rowLength >= totalTiles) {
                return nil
            }
            return location + rowLength;
        case .left:
            if (location % rowLength == 0) {
                return nil
            }
            return location - 1;
        case .right:
            if (location % rowLength == rowLength - 1) {
                return nil
            }
            return location + 1;
        }
    }
    
}

/**
 Listener protocol to allow for notification when a `Tile` on a `Board` is changed.
 
 - seealso: `Board`
 */
protocol BoardListener {
    
    /** Called when the `Tile` on a `Board` at location `location` is changed from type `Before` to type `After` by the `setTileForNotify` function. */
    func tileSet(location: Int, before: Tile, after: Tile)
    
    /** Called when the `Tile` on a `Board` at location `location` is changed from type `Before` to type `After` by the `moveTile` function. The default implementation of this function calls the `tileSet` function of this protocol. */
    func tileMoved(location: Int, before: Tile, after: Tile)
    
    /** Called when the `Tile` on a `Board` at location `location` is changed from type `Before` to type `After` by the `removeLinks` function. The default implementation of this function calls the `tileSet` function of this protocol. */
    func tileLinked(location: Int, before: Tile, after: Tile)
    
    /** Called when the `Tile` on a `Board` at location `location` is changed from type `Before` to type `After` by the `stepTime` function. The default implementation of this function calls the `tileSet` function of this protocol. */
    func tileTimeStepped(location: Int, before: Tile, after: Tile)
    
    /** Called when the `Tile` on a `Board` at location `location` is changed from type `Before` to type `After` by the `clear` function. The default implementation of this function calls the `tileSet` function of this protocol. */
    func tileCleared(location: Int, before: Tile, after: Tile)
    
    /** Called when the `Tile` on a `Board` at location `location` is changed from type `Before` to type `After` by the `fillBoard` function. The default implementation of this function calls the `tileSet` function of this protocol. */
    func tileMagicWanded(location: Int, before: Tile, after: Tile)
    
    /** Called when the `Tile` on a `Board` at location `location` is changed from type `Before` to type `After` by the `repairBoard` function. The default implementation of this function calls the `tileSet` function of this protocol. */
    func tileRepaired(location: Int, before: Tile, after: Tile)
    
}

extension BoardListener {
    
    func tileMoved(location: Int, before: Tile, after: Tile) {
        tileSet(location: location, before: before, after: after)
    }
    
    func tileLinked(location: Int, before: Tile, after: Tile) {
        tileSet(location: location, before: before, after: after)
    }
    
    func tileTimeStepped(location: Int, before: Tile, after: Tile) {
        tileSet(location: location, before: before, after: after)
    }
    
    func tileCleared(location: Int, before: Tile, after: Tile) {
        tileSet(location: location, before: before, after: after)
    }
    
    func tileMagicWanded(location: Int, before: Tile, after: Tile) {
        tileSet(location: location, before: before, after: after)
    }
    
    func tileRepaired(location: Int, before: Tile, after: Tile) {
        tileSet(location: location, before: before, after: after)
    }
    
}


/**
 Listener protocol to allow for notification when the `score` property of a `Board` is changed.
 
 - seealso: `Board`
 */
protocol ScoreListener {
    
    /** Called when the `score` property of a `Board` is incremented (increased by `1`). */
    func onScoreIncremented(newScore: Int)
    
    /** Called when the `score` property of a `Board` is cleared (set to `0`). */
    func onScoreCleared()
    
}


/** Keys to code and decode a `Board` instance with `NSCoding`. */
private struct BoardEncodingKeys {
    
    static let rowLengthKey = "com.megawattgaming.zlink.Board.rowLengthKey"
    static let scoreKey = "com.megawattgaming.zlink.Board.scoreKey"
    
}
