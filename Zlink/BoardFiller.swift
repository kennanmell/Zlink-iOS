//
//  BoardFiller.swift
//  Zlink
//
//  Created by Kennan Mell on 1/15/16.
//  Copyright © 2016 MegaWatt Gaming. All rights reserved.
//

import UIKit

/**
 `BoardFiller` is an abstract data type intended to enhance the functionality of a `Board` instance. In particular, it provides an algorithm ("The BoardFiller Algorithm") to add items to the `Board` instance in a way that is intended to be calculated and fair. This algorithm can also be used to shuffle/rearrange the `Board`'s tiles.
 
 The BoardFiller algorithm is intended to make gameplay more difficult as the board's score increases. The algorithm also creates some variance in the overall difficulty of each game, sometimes making games difficult and occasionally making them very easy.
 
 `BoardFiller` also provides deliberate use for the various Zlink colors, with the colors growing more diverse as the score increases. In addition, `BoardFiller` treats `Tile.Zlink9` as a "secret Zlink" that appears very, very rarely (independent of score).
 
 `BoardFiller` uses its own listeners (`RefillListener`s) as opposed to an attached `Board`'s `BoardListener` when modifying the `Tile`s on a Board. As such, a `Board`'s `BoardListener` will not be notified of changes to its state caused by a `BoardFiller`.
 
 `BoardFiller` conforms to `NSCoding`.
 
 - seealso: `RefillListener`, `SecretZlinkListener`, `RNG`, `Board`, `Tile`
 */
class BoardFiller: NSObject, NSCoding {
    
    // MARK: Properties
    
    /** A `board.score` milestone that changes the color of Zlinks placed on `board` by `self`. */
    static let zlinkIncrement1 = 25
    
    /** A `board.score` milestone that changes the color of Zlinks placed on `board` by `self`. */
    static let zlinkIncrement2 = 50
    
    /** A `board.score` milestone that changes the color of Zlinks placed on `board` by `self`. */
    static let zlinkIncrement3 = 100
    
    /** A `board.score` milestone that changes the color of Zlinks placed on `board` by `self`. */
    static let zlinkIncrement4 = 200
    
    /** A `board.score` milestone that changes the color of Zlinks placed on `board` by `self`. */
    static let zlinkIncrement5 = 500
    
    /** `1 / secretZlinkPercentage` is the approximate chance that a Zlink placed on `board` will be the secret Zlink (`Tile.Zlink9`). */
    private static let secretZlinkPercentage = 30000
    
    /** The minimum initial number that a decrease can be started from. */
    private static let minInitialDecrease = 15
    
    /** A constant used to indicate a setting in the algorithm that impacts full tile placement. */
    private static let fullTileIntensity_Max = 2
    
    /** A constant used to indicate a setting in the algorithm that impacts full tile placement. */
    private static let fullTileIntensity_Normal = 1
    
    /** A constant used to indicate a setting in the algorithm that impacts full tile placement. */
    private static let fullTileIntensity_Min = 0
    
    /** The maximum number of times the algorithm will postpone starting a decrease due to a lack of broken tiles on `board`. */
    private static let maxDecreaseDelays = 5
    
    /** The `Board` instance to be modified by `self`. */
    let board: Board
    
    /** Stores the `RefillListener` of `self`, if any. */
    var refillListener: RefillListener?
    
    /** Stores the `SecretZlinkListener` of `self`, if any. */
    var secretZlinkListener: SecretZlinkListener?
    
    /** The score to start decreasing the moves left on the board at. */
    private var decreaseThreshold = 0 // Overwritten before first use.
    
    /** Used to (sometimes) delay the end of the game when there's only one piece that can move, to make the end of the game more exciting. */
    private var lastTurnExtension = 0 // Overwritten before first use.
    
    /** The number times the end of the game has been postponed in order to attempt to break part of the board first. */
    private var decreaseDelays = 0 // Overwritten before first use.
    
    /** The intensity of full tile placement (determines where they're placed, how frequently, and in what form). */
    private var fullTileIntensity = 0 // Overwritten before first use.
    
    /** The last recorded `board.score`. Used to determine when to clear `self`. */
    private var lastRecordedScore = -1 // Set to -1 to ensure overwrite before 1st use.
    
    
    // MARK: Initialization
    
    /**
     Returns a new `BoardFiller` instance intended to modify a specific `Board`. The returned instance is cleared.
     - parameters:
        - board: The `Board` that `self` should modify.
     */
    init(board: Board) {
        self.board = board
        super.init()
    }
    
    
    // MARK: NSCoding
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(board, forKey: BoardFillerEncodingKeys.boardKey)
        aCoder.encodeInteger(decreaseThreshold, forKey: BoardFillerEncodingKeys.decreaseThresholdKey)
        aCoder.encodeInteger(lastTurnExtension, forKey: BoardFillerEncodingKeys.lastTurnExtensionKey)
        aCoder.encodeInteger(decreaseDelays, forKey: BoardFillerEncodingKeys.decreaseDelaysKey)
        aCoder.encodeInteger(fullTileIntensity, forKey: BoardFillerEncodingKeys.fullTileIntensityKey)
        aCoder.encodeInteger(lastRecordedScore, forKey: BoardFillerEncodingKeys.lastRecordedScoreKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let board = aDecoder.decodeObjectForKey(BoardFillerEncodingKeys.boardKey) as! Board
        self.init(board: board)
        self.decreaseThreshold = aDecoder.decodeIntegerForKey(BoardFillerEncodingKeys.decreaseThresholdKey)
        self.lastTurnExtension = aDecoder.decodeIntegerForKey(BoardFillerEncodingKeys.lastTurnExtensionKey)
        self.decreaseDelays = aDecoder.decodeIntegerForKey(BoardFillerEncodingKeys.decreaseDelaysKey)
        self.fullTileIntensity = aDecoder.decodeIntegerForKey(BoardFillerEncodingKeys.fullTileIntensityKey)
        self.lastRecordedScore = aDecoder.decodeIntegerForKey(BoardFillerEncodingKeys.lastRecordedScoreKey)
    }
    
    
    // MARK: Functions
    
    /**
     Rearranges the `Tile`s on `board`. Rearrangement is relatively random, except that `Broken` `Tile`s gravitate towards the edges of the board. This function is the only `BoardFiller` function that notifies the `Board`'s `BoardListener` of the change (calls `tileSet`).
     */
    func shuffleBoard() {
        resetIfNeeded()
        lastRecordedScore = board.score
        let boardListener = board.boardListener
        board.boardListener = nil
        
        var ones = 0
        var twos = 0
        var threes = 0
        var zlink1 = 0
        var zlink2 = 0
        var zlink3 = 0
        var zlink4 = 0
        var zlink5 = 0
        var zlink6 = 0
        var zlink7 = 0
        var zlink8 = 0
        var zlink9 = 0
        var full0 = 0
        var full1 = 0
        var full2 = 0
        var full3 = 0
        var full4 = 0
        var full5 = 0
        var full6 = 0
        var full7 = 0
        var broken = 0
        
        for i in 0..<board.totalTiles {
            switch board[i] {
            case .Number1: ones += 1
            case .Number2: twos += 1
            case .Number3: threes += 1
            case .Zlink1: zlink1 += 1
            case .Zlink2: zlink2 += 1
            case .Zlink3: zlink3 += 1
            case .Zlink4: zlink4 += 1
            case .Zlink5: zlink5 += 1
            case .Zlink6: zlink6 += 1
            case .Zlink7: zlink7 += 1
            case .Zlink8: zlink8 += 1
            case .Zlink9: zlink9 += 1
            case .Full0: full0 += 1
            case .Full1: full1 += 1
            case .Full2: full2 += 1
            case .Full3: full3 += 1
            case .Full4: full4 += 1
            case .Full5: full5 += 1
            case .Full6: full6 += 1
            case .Full7: full7 += 1
            case .Broken: broken += 1
            default: break
            }
        }
        
        let boardCopy = Board(otherBoard: board)
        
        for i in 0..<board.totalTiles {
            board[i] = .Empty
        }
        
        if board.rowLength != 6 {
            print("BoardFiller: Shuffle can only impose restraints on Boards with length 6.")
            for _ in 0..<broken {
                let location = generateEmptyLocation()
                board[location] = .Broken
            }
        } else {
            for _ in 0..<broken {
                if RNG.generateInt(6) == 0 {
                    let location = generateEmptyLocation()
                    board[location] = .Broken
                } else {
                    var validLocations = Array<Int>()
                    
                    if board[0] == .Empty {
                        validLocations.append(0)
                    }
                    if board[1] == .Empty {
                        validLocations.append(1)
                    }
                    if board[2] == .Empty {
                        validLocations.append(2)
                    }
                    if board[3] == .Empty {
                        validLocations.append(3)
                    }
                    if board[4] == .Empty {
                        validLocations.append(4)
                    }
                    if board[5] == .Empty {
                        validLocations.append(5)
                    }
                    if board[6] == .Empty {
                        validLocations.append(6)
                    }
                    if board[11] == .Empty {
                        validLocations.append(11)
                    }
                    if board[12] == .Empty {
                        validLocations.append(12)
                    }
                    if board[17] == .Empty {
                        validLocations.append(17)
                    }
                    if board[18] == .Empty {
                        validLocations.append(18)
                    }
                    if board[23] == .Empty {
                        validLocations.append(23)
                    }
                    if board[24] == .Empty {
                        validLocations.append(24)
                    }
                    if board[29] == .Empty {
                        validLocations.append(29)
                    }
                    if board[30] == .Empty {
                        validLocations.append(30)
                    }
                    if board[35] == .Empty {
                        validLocations.append(35)
                    }
                    
                    if validLocations.isEmpty {
                        let location = generateEmptyLocation()
                        board[location] = .Broken
                    } else {
                        let location = validLocations[RNG.generateInt(validLocations.count)]
                        board[location] = .Broken
                    }
                }
            }
        }
        
        for _ in 0..<ones {
            if RNG.generateInt(4) == 0 {
                let location = generateEmptyLocation()
                board[location] = .Number1
            } else {
                let location = generateMaxMovesLocation(.Number1)
                board[location] = .Number1
            }
        }
        
        for _ in 0..<twos {
            if RNG.generateInt(4) == 0 {
                let location = generateEmptyLocation()
                board[location] = .Number2
            } else {
                let location = generateMaxMovesLocation(.Number2)
                board[location] = .Number2
            }
        }
        
        for _ in 0..<threes {
            if RNG.generateInt(4) == 0 {
                let location = generateEmptyLocation()
                board[location] = .Number3
            } else {
                let location = generateMaxMovesLocation(.Number3)
                board[location] = .Number3
            }
        }
        
        while true {
            let location = generateIdealZlinkOrFullLocation()
            if zlink1 > 0 {
                board[location] = .Zlink1
                zlink1 -= 1
            } else if zlink2 > 0 {
                board[location] = .Zlink2
                zlink2 -= 1
            } else if zlink3 > 0 {
                board[location] = .Zlink3
                zlink3 -= 1
            } else if zlink4 > 0 {
                board[location] = .Zlink4
                zlink4 -= 1
            } else if zlink5 > 0 {
                board[location] = .Zlink5
                zlink5 -= 1
            } else if zlink6 > 0 {
                board[location] = .Zlink6
                zlink6 -= 1
            } else if zlink7 > 0 {
                board[location] = .Zlink7
                zlink7 -= 1
            } else if zlink8 > 0 {
                board[location] = .Zlink8
                zlink8 -= 1
            } else if zlink9 > 0 {
                board[location] = .Zlink9
                zlink9 -= 1
            } else if full0 > 0 {
                board[location] = .Full0
                full0 -= 1
            } else if full1 > 0 {
                board[location] = .Full1
                full1 -= 1
            } else if full2 > 0 {
                board[location] = .Full2
                full2 -= 1
            } else if full3 > 0 {
                board[location] = .Full3
                full3 -= 1
            } else if full4 > 0 {
                board[location] = .Full4
                full4 -= 1
            } else if full5 > 0 {
                board[location] = .Full5
                full5 -= 1
            } else if full6 > 0 {
                board[location] = .Full6
                full6 -= 1
            } else if full7 > 0 {
                board[location] = .Full7
                full7 -= 1
            } else {
                break
            }
        }
        
        board.boardListener = boardListener
        if board.boardListener is BoardController {
            // Use custom animation if available.
            (board.boardListener as! BoardController).animateShuffle(board, boardCopy: boardCopy)
        } else {
            for i in 0..<board.totalTiles {
                board[i] = board[i]
            }
        }
    }
    
    
    /**
     Refills `board` using the BoardFiller algorithm. May add some combination of numbers, Zlinks, and full tiles. The `RefillListener` (if any) is notified of changes through `tileRefilled`.
     - postcondition: `board` contains `5` to `7` numbers and `3` Zlinks (will contain more if it already contained more before the function call.)
     - seealso: `refillEmptyBoard`. That function should be used instead of this one if its preconditions are met because it will generally result in better-placed tiles.
     */
    func refillBoard() {
        resetIfNeeded()
        lastRecordedScore = board.score
        if board.score % 100 > 60 && board.score % 100 < 65 && fullTileIntensity == BoardFiller.fullTileIntensity_Normal {
            fullTileIntensity = BoardFiller.fullTileIntensity_Max
        } else if board.score % 100 > 90 && fullTileIntensity == BoardFiller.fullTileIntensity_Max {
            fullTileIntensity = BoardFiller.fullTileIntensity_Normal
        }
        
        var zlinks = 0
        var numbers = 0
        var fulls = 0
        var broken = 0
        var empty = 0
        
        for i in 0..<board.totalTiles {
            if board[i].isZlink {
                zlinks += 1
            } else if board[i].isNumber {
                numbers += 1
            } else if board[i].isFull {
                fulls += 1
            } else if board[i] == .Broken {
                broken += 1
            } else if board[i] == .Empty {
                empty += 1
            }
        }
        
        while zlinks < 3 && empty > 0 {
            let location = addZlink(false)
            refillListener?.tileRefilled(location, after: board[location])
            zlinks += 1
            empty -= 1
        }
        
        let targetNumbers = 5 + RNG.generateInt(3)
        while numbers < targetNumbers && empty > 0 {
            let location = addNumber(false)
            refillListener?.tileRefilled(location, after: board[location])
            numbers += 1
            empty -= 1
        }
        
        if empty > 0 {
            // Add full(s).
            if fullTileIntensity == BoardFiller.fullTileIntensity_Min {
                if board.score > 25 {
                    if RNG.generateInt(2) != 0 {
                        let location = addFull(false)
                        refillListener?.tileRefilled(location, after: board[location])
                    }
                    
                    if board.score > 75 && RNG.generateInt(7) == 0 {
                        let location = addFull(false)
                        refillListener?.tileRefilled(location, after: board[location])
                    }
                }
            } else if fullTileIntensity == BoardFiller.fullTileIntensity_Max {
                if board.score > 25 {
                    if RNG.generateInt(15) != 0 {
                        let location = addFull(false)
                        refillListener?.tileRefilled(location, after: board[location])
                    }
                    
                    if board.score > 75 && RNG.generateInt(5) == 0 {
                        let location = addFull(false)
                        refillListener?.tileRefilled(location, after: board[location])
                    }
                }
            } else { // fullTileIntensity == BoardFiller.fullTileIntensity_Normal
                if board.score > 25 {
                    if RNG.generateInt(4) != 0 {
                        let location = addFull(false)
                        refillListener?.tileRefilled(location, after: board[location])
                    }
                    
                    if board.score > 75 && RNG.generateInt(7) == 0 {
                        let location = addFull(false)
                        refillListener?.tileRefilled(location, after: board[location])
                    }
                }
            }
        }
    }
    
    /**
     Refills `board` using the BoardFiller algorithm. Adds some combination of Zlinks and numbers to `board`. The `RefillListener` (if any) is notified of changes through `tileRefilled`. Preferable to `refillBoard` if the precondition is met because it results in generally better-placed tiles.
     - precondition: All tiles on `self.board` are `.Empty` and `self.board.rowLength == 6`.
     - postcondition: `board` contains `4` to `7` numbers and `3` Zlinks.
     - seealso: `refillBoard`. That function should be used instead of this one if the preconditions for this function are not met.
    */
    func refillEmptyBoard() {
        resetIfNeeded()
        lastRecordedScore = board.score
        let boardListener = board.boardListener
        board.boardListener = nil
        
        if board.rowLength != 6 {
            print("BoardFiller: Couldn't refill from file; board length is incompatible.")
            refillBoard()
            return
        }
        
        for i in 0..<board.totalTiles {
            if board[i] != .Empty {
                print("BoardFiller: Couldn't refill from file; board must be empty.")
                refillBoard()
                return
            }
        }
        
        var data = String(data: NSDataAsset(name: "board_states")!.data, encoding: NSUTF8StringEncoding)!.characters.split{$0 == "\n"}.map(String.init)
        
        var i = 0;
        while i < data.count {
            if data[i].hasPrefix("#") {
                // Line is a comment; remove it.
                data.removeAtIndex(i)
            } else {
                i += 1
            }
        }
        
        var chosen = data[RNG.generateInt(data.count)].characters.split{$0 == "/"}.map(String.init)
        
        let zlinks = chosen[0].characters.split{$0 == " "}.map(String.init)
        for j in 0..<zlinks.count {
            let location = Int(zlinks[j])!
            board[location] = generateZlinkType()
            refillListener?.tileRefilled(location, after: board[location])
        }
        
        let ones = chosen[1].characters.split{$0 == " "}.map(String.init)
        
        for j in 0..<ones.count {
            let location = Int(ones[j])!
            board[location] = .Number1
            refillListener?.tileRefilled(location, after: board[location])
        }
        let twos = chosen[2].characters.split{$0 == " "}.map(String.init)
        
        for j in 0..<twos.count {
            let location = Int(twos[j])!
            board[location] = .Number2
            refillListener?.tileRefilled(location, after: board[location])
        }
        let threes = chosen[3].characters.split{$0 == " "}.map(String.init)
        
        for j in 0..<threes.count {
            let location = Int(threes[j])!
            board[location] = .Number3
            refillListener?.tileRefilled(location, after: board[location])
        }
        
        let location = addNumber(false)
        refillListener?.tileRefilled(location, after: board[location])
        
        board.boardListener = boardListener
    }
    
    /**
     Adds a Zlink to the board using the BoardFiller alorithm. The `RefillListener` (if any) is notified through `tileSet`.
     - returns: The location where the Zlink was added. */
    func addZlink(notify: Bool) -> Int {
        resetIfNeeded()
        lastRecordedScore = board.score
        let location = generateIdealZlinkOrFullLocation()
        
        // Generate Zlink type, set, and return.
        let zlinkType = generateZlinkType()
        if zlinkType == .Zlink9 {
            secretZlinkListener?.onSecretZlinkSeen()
        }
        
        let boardListener = board.boardListener
        board.boardListener = nil
        board[location] = zlinkType
        if notify {
            refillListener?.tileSet(location, after: zlinkType)
        }
        board.boardListener = boardListener

        return location
    }
    
    /**
     Adds a full tile to the board using the BoardFiller alorithm. The `RefillListener` (if any) is notified through `tileSet`.
     - returns: The location where the full tile was added. */
    func addFull(notify: Bool) -> Int {
        resetIfNeeded()
        lastRecordedScore = board.score
        var location: Int
        
        if fullTileIntensity == BoardFiller.fullTileIntensity_Max {
            if RNG.generateBool() {
                // Find a location that's not touching another full tile or Zlink.
                var locationData = Array<Int>()
                
                for i in 0..<board.totalTiles {
                    if board[i] == .Empty {
                        var success = true
                        for direction in Direction.values {
                            let locationX = board.shiftFromLocation(i, inDirection: direction)
                            if locationX != nil && board[locationX!].isConnectable {
                                success = false
                                break
                            }
                        }
                        if success {
                            locationData.append(i)
                        }
                    }
                }
                
                if locationData.count != 0 {
                    location = locationData[RNG.generateInt(locationData.count)]
                } else {
                    location = generateIdealZlinkOrFullLocation()
                }
            } else {
                location = generateIdealZlinkOrFullLocation()
            }
        } else { // fullTileIntensity == BoardFiller.fullTileIntensity_Normal
            location = generateIdealZlinkOrFullLocation()
        }
        
        // Generate full tile type, set, and return.
        let fullType = generateFullType()
        let boardListener = board.boardListener
        board.boardListener = nil
        board[location] = fullType
        if notify {
            refillListener?.tileSet(location, after: fullType)
        }
        board.boardListener = boardListener
        return location
    }
    
    /**
     Adds a number to the board using the BoardFiller alorithm. The `RefillListener` (if any) is notified through `tileSet`.
     - returns: The location where the number was added. */
    func addNumber(notify: Bool) -> Int {
        resetIfNeeded()
        lastRecordedScore = board.score
        let boardListener = board.boardListener
        board.boardListener = nil
        
        var location: Int!
        var numberType = generateNumberType()
        
        var broken = 0
        var numbers = 0
        for i in 0..<board.totalTiles {
            if board[i] == .Broken {
                broken += 1
            } else if board[i].isNumber {
                numbers += 1
            }
        }
        
        if board.score >= decreaseThreshold {
            if broken < 2 && decreaseDelays < BoardFiller.maxDecreaseDelays {
                // Player is doing well, so postpone decrease.
                decreaseThreshold = decreaseThreshold + 25
                decreaseDelays = decreaseDelays + 1
                fullTileIntensity = BoardFiller.fullTileIntensity_Max
                location = generateMaxMovesLocation(numberType)
            } else {
                if lastTurnExtension != 3 && (lastTurnExtension != 0 || (getTotalMoves() <= 1 && RNG.generateInt(3) == 0)) {
                    // In this case, there are no/1 moves left on the board so the game will end if we place the number in a location where it can't move. However, we randomly decided to override the decrease to extend the game for 3 turns for better drama.
                    lastTurnExtension = lastTurnExtension + 1
                    for _ in 0..<5 {
                        // Try 5 times to find a location where the number can be moved, otherwise just give up and end the game.
                        location = generateEmptyLocation()
                        board[location] = numberType
                        var success = false
                        for direction in Direction.values {
                            if board.canMoveTile(location, inDirection: direction) {
                                success = true
                            }
                        }
                        board[location] = .Empty
                        if success {
                            break
                        }
                    }
                } else if lastTurnExtension != 3 && RNG.generateBool() {
                    // Place the number randomly about half the time to avoid making it too obvious that we're decreasing.
                    location = generateEmptyLocation()
                } else {
                    // Find the location that yields the least difference between the target total moves and the total moves that would exist if the number was placed there.
                    
                    var locationData = Array<Int>(count: board.totalTiles, repeatedValue: 5000 /** Large number so that non-empty locations are unlikely to ultimately be selected. */)
                    
                    for i in 0..<board.totalTiles {
                        if board[i] == .Empty {
                            board[i] = numberType
                            locationData[i] = getTotalMoves()
                            board[i] = .Empty
                        }
                    }
                    
                    let target = getTotalMoves() - 1
                    for i in 0..<locationData.count {
                        // Compute difference between target and actual total moves.
                        locationData[i] = abs(locationData[i] - target)
                    }
                    
                    // Find minimum difference.
                    let startLocation = RNG.generateInt(board.totalTiles)
                    var selectedLocation = startLocation
                    
                    for i in startLocation..<board.totalTiles {
                        if locationData[i] < locationData[selectedLocation] {
                            selectedLocation = i
                        }
                    }
                    
                    for i in 0..<startLocation {
                        if locationData[i] < locationData[selectedLocation] {
                            selectedLocation = i
                        }
                    }
                    
                    location = selectedLocation
                }
            }
        } else {
            // Use standard algorithm.
            if RNG.generateInt(10) < max(3, 8 - broken) {
                location = generateMaxMovesLocation(numberType)
            } else {
                location = generateEmptyLocation()
            }
        }
        
        // Make sure that there are enough broken tiles to end the game if the game is going to end.
        board[location] = numberType
        if numbers > 2 && broken < 2 && decreaseDelays < BoardFiller.maxDecreaseDelays && getTotalMoves() == 0 && RNG.generateInt(4) != 0 {
            
            board[location] = .Empty
            decreaseDelays = decreaseDelays + 1
            fullTileIntensity = BoardFiller.fullTileIntensity_Max
            location = generateMaxMovesLocation(numberType)
        }
        
        // Avoid making an auto-link if avoiding doing so won't increase the difficulty of the game.
        if board.hasLink {
            board[location] = .Empty
            if let solved = solvePuzzleWithTile(numberType) {
                location = solved
            } else if let solved = solvePuzzleWithTile(.Number1) {
                location = solved
                numberType = .Number1
            } else if let solved = solvePuzzleWithTile(.Number2) {
                location = solved
                numberType = .Number2
            } else if let solved = solvePuzzleWithTile(.Number3) {
                location = solved
                numberType = .Number3
            }
        }
        
        board[location] = numberType
        if notify {
            refillListener?.tileSet(location, after: board[location])
        }
        
        board.boardListener = boardListener
        return location
    }
    
    
    // MARK: Private Helper Functions
    
    /** Resets `self` to a new (beginning) difficulty level if `lastRecordedScore > board.score` (indicates `board` was cleared) or `self` was never fully initialized. */
    private func resetIfNeeded() {
        if lastRecordedScore > board.score || lastRecordedScore < 0 {
            lastRecordedScore = board.score
            decreaseThreshold = RNG.generateIntTriangle(1000, peak: 500)
            lastTurnExtension = 0
            decreaseDelays = 0
            fullTileIntensity = BoardFiller.fullTileIntensity_Normal
            if  RNG.generateInt(50) == 0 {
                // Make the game really easy every 50th game.
                decreaseThreshold = 999 // 999 is the highest non-decreasing score we allow.
                fullTileIntensity = BoardFiller.fullTileIntensity_Min
            }
        }
    }
    
    /**
     Finds an arbitrary location on `board` that is `.Empty`.
     - returns: An `Int` representing the location on `board`, or `-1` of no locations on `board` are `.Empty`.
     */
    private func generateEmptyLocation() -> Int {
        for _ in 0..<5 {
            // Try 5 times to get a random location that's `Empty`.
            let location = RNG.generateInt(board.totalTiles)
            if board[location] == .Empty {
                return location
            }
        }
        
        // Failed after a few random tries, so just systematically find any empty location.
        let startLocation = RNG.generateInt(board.totalTiles)
        for i in startLocation..<board.totalTiles {
            if board[i] == .Empty {
                return i
            }
        }
        
        for i in 0..<startLocation {
            if board[i] == .Empty {
                return i
            }
        }
        
        // No empty location exists on `board`. This case should never occur, which is why -1 is returned instead of `nil`. (It shouldn't occur because `addNumber` is only called after another number is moved, which guarantees that the location of that number is .Empty. The other functions are only called by `refillBoard`, which will only add new tiles if it knows at least one location is .Empty. This result may need to be updated if these conditions are changed.)
        return -1
    }
    
    /**
     Finds the total number of moves available to all number `Tile`s on `board`.
     - returns: The total number of moves.
     */
    private func getTotalMoves() -> Int {
        var totalMoves = 0
        for i in 0..<board.totalTiles {
            if board[i].isNumber {
                for direction in Direction.values {
                    if board.canMoveTile(i, inDirection: direction) {
                        totalMoves += 1
                    }
                }
            }
        }
        return totalMoves
    }
    
    /**
     If a `Tile` can be added to `board` that will cause a link immediately, or after one valid move (can be by the `Tile` that would be added), the location where the `Tile` should be added is returned.
     - parameters:
        - tile: The type of `Tile` to try to solve the puzzle with.
     - returns: The location where `tile` should be added in order to make the puzzle solvable, or `nil` if no such location exists.
     */
    private func solvePuzzleWithTile(tile: Tile) -> Int? {
        let boardListener = board.boardListener
        board.boardListener = nil
        
        for i in 0..<board.totalTiles {
            if board[i] == .Empty {
                board[i] = tile
                if board.hasLink {
                    board[i] = .Empty
                    continue
                }
                
                for j in 0..<board.totalTiles {
                    if board[j].isNumber {
                        let boardCopy = Board(otherBoard: board)
                        for direction in Direction.values {
                            if boardCopy.moveTile(j, inDirection: direction) && boardCopy.hasLink {
                                board[i] = .Empty
                                board.boardListener = boardListener
                                return i
                            }
                        }
                    }
                }
                
                board[i] = .Empty
            }
        }
        
        // Can't solve in one move.
        board.boardListener = boardListener
        return nil
    }
    
    /**
     Finds the location on `board` where `tile` can be added to create the maximum possible amount of total moves available on the board.
     - parameters:
        - tile: The type of `tile` that would be added to `board`.
     - returns: The found location.
     */
    private func generateMaxMovesLocation(tile: Tile) -> Int {
        let boardListener = board.boardListener
        board.boardListener = nil
        
        // Find a location that makes for a lot of additional moves to skew the duration of the game higher.
        var maxMoves = -1 // <0 to guarantee overwrite.
        var maxMovesLocation = -1 // <0 to guarantee overwrite.
        
        let startLocation = RNG.generateInt(board.totalTiles)
        
        for i in startLocation..<board.totalTiles {
            if board[i] == .Empty {
                board[i] = tile
                let totalMoves = getTotalMoves()
                if totalMoves > maxMoves {
                    maxMoves = totalMoves
                    maxMovesLocation = i
                }
                board[i] = .Empty
            }
        }
        
        for i in 0..<startLocation {
            if board[i] == .Empty {
                board[i] = tile
                let totalMoves = getTotalMoves()
                if totalMoves > maxMoves {
                    maxMoves = totalMoves
                    maxMovesLocation = i
                }
                board[i] = .Empty
            }
        }
        
        board.boardListener = boardListener
        return maxMovesLocation
    }
    
    /**
     Generates one of `Number1` - `Number3`.
     - returns: The generated `Tile` type.
     */
    private func generateNumberType() -> Tile {
        var ones: Double = 0
        var twos: Double = 0
        var threes: Double = 0
        for i in 0..<board.totalTiles {
            switch board[i] {
            case .Number1: ones += 1
            case .Number2: twos += 1
            case .Number3: threes += 1
            default: break
            }
        }
        
        // Try to keep the board populated with at least one of each number type, but without being too obvious about it.
        if twos == 0 && RNG.generateBool() {
            return .Number2
        } else if ones == 0 && RNG.generateBool() {
            return .Number1
        } else if threes == 0 && RNG.generateBool() {
            return .Number3
        }
        
        let totalNumbers = ones + twos + threes
        
        var choices: Array<Tile> = [.Number1, .Number2, .Number3]
        
        if ones / totalNumbers > 0.5 {
            choices.removeAtIndex(0)
        } else if twos / totalNumbers > 0.5 {
            choices.removeAtIndex(1)
        } else if threes / totalNumbers > 0.5 {
            choices.removeAtIndex(2)
        }
        
        if choices.count == 3 {
            let onePercentage = 35
            let twoPercentage = 45
            // let threePercentage = 20
            
            let generated = RNG.generateInt(100)
            
            if generated < onePercentage {
                return .Number1
            } else if generated < twoPercentage {
                return .Number2
            } else {
                return .Number3
            }
        } else {
            if RNG.generateBool() {
                return choices[0]
            } else {
                return choices[1]
            }
        }
    }
    
    /**
     Generates one of `Full0` - `Full10`.
     - returns: The generated `Tile` type.
     */
    private func generateFullType() -> Tile {
        if fullTileIntensity == BoardFiller.fullTileIntensity_Min {
            if board.score < 100 {
                return .Full7
            } else {
                if RNG.generateInt(15) == 0 {
                    return .Full4
                } else {
                    return .Full7
                }
            }
        } else if fullTileIntensity == BoardFiller.fullTileIntensity_Max {
            if board.score < 100 {
                return .Full7
            } else {
                if RNG.generateInt(5) == 0 {
                    return .Full4
                } else {
                    return .Full7
                }
            }
        } else { // fullTileIntensity = BoardFiller.fullTileIntensiry_Normal
            if board.score < 100 {
                return .Full7
            } else {
                if RNG.generateInt(10) == 0 {
                    return .Full4
                } else {
                    return .Full7
                }
            }
        }
    }
    
    /**
     Generates one of `Zlink1` - `Zlink9`.
     - returns: The generated `Tile` type.
     */
    private func generateZlinkType() -> Tile {
        var numberOfZlink: Int
        
        if RNG.generateInt(BoardFiller.secretZlinkPercentage) == 0 {
            numberOfZlink = 8
        } else if board.score >= BoardFiller.zlinkIncrement5 {
            numberOfZlink = RNG.generateInt(8)
        } else if board.score >= BoardFiller.zlinkIncrement4 {
            numberOfZlink = RNG.generateInt(7)
        } else if board.score >= BoardFiller.zlinkIncrement3 {
            numberOfZlink = RNG.generateInt(6)
        } else if board.score >= BoardFiller.zlinkIncrement2 {
            numberOfZlink = RNG.generateInt(5)
        } else if board.score >= BoardFiller.zlinkIncrement1 {
            numberOfZlink = RNG.generateInt(4)
        } else {
            numberOfZlink = RNG.generateInt(3)
        }
        
        var zlinksFound = Array<Bool>(count: 9, repeatedValue: false)
        for i in 0..<board.totalTiles {
            switch board[i] {
            case .Zlink1: zlinksFound[0] = true
            case .Zlink2: zlinksFound[1] = true
            case .Zlink3: zlinksFound[2] = true
            case .Zlink4: zlinksFound[3] = true
            case .Zlink5: zlinksFound[4] = true
            case .Zlink6: zlinksFound[5] = true
            case .Zlink7: zlinksFound[6] = true
            case .Zlink8: zlinksFound[7] = true
            case .Zlink9: zlinksFound[8] = true
            default: break
            }
        }
        
        if board.score == 0 {
            if !zlinksFound[0] {
                numberOfZlink = 0
            } else if !zlinksFound[1] {
                numberOfZlink = 1
            } else if !zlinksFound[2] {
                numberOfZlink = 2
            }
        } else if board.score >= BoardFiller.zlinkIncrement1 && board.score <= BoardFiller.zlinkIncrement1 + 2 && !zlinksFound[3] {
            numberOfZlink = 3
        } else if board.score >= BoardFiller.zlinkIncrement2 && board.score <= BoardFiller.zlinkIncrement2 + 2 && !zlinksFound[4] {
            numberOfZlink = 4
        } else if board.score >= BoardFiller.zlinkIncrement3 && board.score <= BoardFiller.zlinkIncrement3 + 2 && !zlinksFound[5] {
            numberOfZlink = 5
        } else if board.score >= BoardFiller.zlinkIncrement4 && board.score <= BoardFiller.zlinkIncrement4 + 2 && !zlinksFound[6] {
            numberOfZlink = 6
        } else if board.score >= BoardFiller.zlinkIncrement5 && board.score <= BoardFiller.zlinkIncrement5 + 2 && !zlinksFound[7] {
            numberOfZlink = 7
        }
        
        switch numberOfZlink {
        case 0: return .Zlink1
        case 1: return .Zlink2
        case 2: return .Zlink3
        case 3: return .Zlink4
        case 4: return .Zlink5
        case 5: return .Zlink6
        case 6: return .Zlink7
        case 7: return .Zlink8
        case 8: return .Zlink9
        default: fatalError("BoardFiller: Internal error.")
        }
    }
    
    /**
     Generates the "ideal" location to place a full tile or Zlink on `board`.
     - returns: The generated location.
     */
    private func generateIdealZlinkOrFullLocation() -> Int {
        let boardListener = board.boardListener
        board.boardListener = nil
        
        var zlinkLocations = Array<Int>()
        for i in 0..<board.totalTiles {
            if board[i].isZlink {
                zlinkLocations.append(i)
            }
        }
        
        var location = -1
        
        if !zlinkLocations.isEmpty {
            var distances = Dictionary<Int, Int>()
            for location in zlinkLocations {
                let zlinkX = location % board.rowLength
                let zlinkY = location / board.rowLength
                
                for i in 0..<board.totalTiles {
                    if board[i] == .Empty {
                        board[i] = .Zlink1
                        if !board.hasLink {
                            let x = i % board.rowLength
                            let y = i / board.rowLength
                            if distances[i] != nil {
                                distances[i]! += abs(x - zlinkX) + abs(y - zlinkY)
                            } else {
                                distances[i] = abs(x - zlinkX) + abs(y - zlinkY)
                            }
                        }
                        board[i] = .Empty
                    }
                }
            }
            if distances.count == 0 {
                // The ideal algorithm failed to find a location, meaning that the only valid locations will create a connection, so just pick any location with `.Empty`.
                location = generateEmptyLocation()
            } else {
                // At least one location found; choose via RNG.
                let sortedDistances = distances.values.sort()
                let targetDistance = sortedDistances[RNG.generateIntTriangle(sortedDistances.count, peak: min(sortedDistances.count - 1, board.score / 50 + 1))]
                location = ((distances as NSDictionary).allKeysForObject(targetDistance) as! [Int])[0]
            }
        } else {
            // No Zlinks on board, so just pick any location with `.Empty`.
            location = generateEmptyLocation()
        }
        
        board.boardListener = boardListener
        return location
    }
    
}


/**
 Listener protocol to allow notification when a `Zlink9` is placed on a `Board` by a `BoardFiller` instance.
 
 - seealso: `BoardFiller`
 */
protocol SecretZlinkListener {
    
    /** Called by the `BoardFiller` when it places a `Zlink9` on a `Board`. */
    func onSecretZlinkSeen()
    
}


/**
 Listener protocol to allow notification when a `Tile` is placed on a `Board` by a `BoardFiller` instance.
 
 - seealso: `BoardFiller`
 */
protocol RefillListener {
    
    /** Called by the `BoardFiller` when the tile at location `location` is changed from `.Empty` to `after` by its `refillBoard` or `refillEmptyBoard` functions. */
    func tileRefilled(location: Int, after: Tile)
    
    /** Called by the `BoardFiller` when the tile at location `location` is changed from `.Empty` to `after` by its `addZlink`, `addFull` or `addNumber` functions. */
    func tileSet(location: Int, after: Tile)
    
}

/** Keys to code and decode a `BoardFiller` instance with `NSCoding`. */
private struct BoardFillerEncodingKeys {
    
    static let boardKey = "com.megawattgaming.zlink.BoardFiller.boardKey"
    static let decreaseThresholdKey = "com.megawattgaming.zlink.BoardFiller.decreaseThresholdKey"
    static let lastTurnExtensionKey = "com.megawattgaming.zlink.BoardFiller.lastTurnExtensionKey"
    static let decreaseDelaysKey = "com.megawattgaming.zlink.BoardFiller.decreaseDelaysKey"
    static let fullTileIntensityKey = "com.megawattgaming.zlink.BoardFiller.fullTileIntensityKey"
    static let lastRecordedScoreKey = "com.megawattgaming.zlink.BoardFiller.lastRecordedScoreKey"
    
}