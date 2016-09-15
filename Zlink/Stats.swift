//
//  Stats.swift
//  Zlink
//
//  Created by Kennan Mell on 2/4/16.
//  Copyright © 2016 MegaWatt Gaming. All rights reserved.
//

import Foundation

/** 
 `Stats` is an abstract data type that provides real-time high score tracking. A `Stats` instance stores up to `Stats.maxCount` high scores at a time as well as up to one currently-tracked score and two stats: total games played and total Zlinks linked.
 
 If another score must be added and there are already `Stats.maxCount` scores, the lowest score will be overwritten.
 
 `Stats` provides a subscript notation for accessing its stored scores. The current score may be returned by this subscript.
 
 `Stats` conforms to `NSCoding`.
 
 - seealso: `HighScore`
  */
class Stats:NSObject, NSCoding {
    
    // MARK: Subscript
    
    /**
     Read-only subscript notation for accessing the currently stored scores in the Scores. Scores are sorted in descending order, meaning that a call to `Scores.instance[0]` will produce the highest saved score, and so on. The currently tracked score can be returned by this subscript. Returned `HighScores` can be modified by the client without changing `self`.
     - returns: The `index`th highest score stored by `self`.
     - requires: `index` is between 0 (inclusive) and `count` (exclusive).
     */
    subscript(index: Int) -> HighScore {
        if index < 0 || index >= count {
            fatalError("Stats index out of range.")
        }
        
        if storedCurrentScore == nil {
            return HighScore(otherHighScore: highScoreArray[index])
        }
        
        var i = 0
        while i < highScoreArray.count && highScoreArray[i].score > storedCurrentScore!.score {
            i += 1
        }
        
        if index < i {
            return HighScore(otherHighScore: highScoreArray[index])
        } else if index == i {
            return HighScore(otherHighScore: storedCurrentScore!)
        } else {
            return HighScore(otherHighScore: highScoreArray[index - 1])
        }
    }

    
    // MARK: Properties
    
    /** The maximum number of `HighScore`s that any `Stats` instance can store. */
    static let maxCount = 10
    
    /** The `String` defined by `Stats` to represent the date the currently-tracked `HighScore` was achieved. */
    static let currentScoreDate = "current"
    
    /** The number of `HighScore` elements stored in `self` (including the currently-tracked score). Read-only. */
    private(set) var count: Int
    
    /** Stores all currently saved `HighScores` in `self`. Should always have a `count` of `self.count - 1` because `self.count` includes the current score. */
    private var highScoreArray: Array<HighScore>
    
    /** The `HighScore` currently being tracked by `self`. Stored separately from `currentScore` to avoid representation exposure. */
    private var storedCurrentScore: HighScore?
    
    /** The `HighScore` currently being tracked by `self`. Mutating this value will not mutate the internal state of `self`. */
    var currentScore: HighScore? {
        if storedCurrentScore == nil {
            return nil
        } else {
            return HighScore(otherHighScore: storedCurrentScore!)
        }
    }
    
    /** The total number of games that `self` has tracked in its lifetime. */
    private(set) var gamesPlayed: Int
    
    /** The total value of the scores in games that the `self` has tracked in its lifetime. */
    private(set) var zlinksLinked: Int
    
    /** `true` if and only if `currentScore != nil`. */
    var isTrackingGame: Bool {
        return storedCurrentScore != nil
    }
    
    
    // MARK: NSCoding
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(count, forKey: ScoresEncodingKeys.countKey)
        aCoder.encodeObject(storedCurrentScore, forKey: ScoresEncodingKeys.currentScoreKey)
        aCoder.encodeInteger(gamesPlayed, forKey: ScoresEncodingKeys.gamesPlayedKey)
        aCoder.encodeInteger(zlinksLinked, forKey: ScoresEncodingKeys.zlinksLinkedKey)
        for i in 0..<highScoreArray.count {
            aCoder.encodeObject(highScoreArray[i])
        }
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        self.count = aDecoder.decodeIntegerForKey(ScoresEncodingKeys.countKey)
        self.storedCurrentScore = aDecoder.decodeObjectForKey(ScoresEncodingKeys.currentScoreKey) as? HighScore
        self.gamesPlayed = aDecoder.decodeIntegerForKey(ScoresEncodingKeys.gamesPlayedKey)
        self.zlinksLinked = aDecoder.decodeIntegerForKey(ScoresEncodingKeys.zlinksLinkedKey)
        
        var highScore = aDecoder.decodeObject()
        while highScore is HighScore {
            self.highScoreArray.append(highScore as! HighScore)
            highScore = aDecoder.decodeObject()
        }
    }
    
    
    // MARK: Initialization
    
    /**
     Returns a new `Stats` instance.
     - postcondition:
        + `self.count == 0`
        + `self.currentScore == nil`
        + `self.zlinksLinked == 0`
        + `self.gamesPlayed == 0`
     */
    override init() {
        self.highScoreArray = Array<HighScore>()
        self.count = 0
        self.storedCurrentScore = nil
        self.zlinksLinked = 0
        self.gamesPlayed = 0
        
        super.init()
    }
    
    
    // MARK: Functions
    
    /**
     Clears `self`.
     - postcondition:
        + `self.count == 0`
        + `self.currentScore == nil`
        + `self.zlinksLinked == 0`
        + `self.gamesPlayed == 0`
     */
    func clear() {
        self.highScoreArray = Array<HighScore>()
        self.storedCurrentScore = nil
        self.count = 0
        self.zlinksLinked = 0
        self.gamesPlayed = 0
    }
    
    /**
     Incerases `currentScore.score` by `1`.
     - requires: `self.isTrackingGame`
     */
    func incrementCurrentScore() {
        if storedCurrentScore == nil {
            fatalError("No game being tracked; nothing to increment.")
        }
        storedCurrentScore!.score += 1
        zlinksLinked += 1
    }
    
    /**
     Finishes tracking the current game, and sets the date of that `HighScore` to the current date in "mm/dd/yyyy" format.
     - requires: `self.isTrackingGame`
     - postcondition: `!self.isTrackingGame`
     */
    func finishTrackingGame() {
        if storedCurrentScore == nil {
            fatalError("No game being tracked; nothing to finish.")
        }
        var insertLocation = 0
        while insertLocation < highScoreArray.count && highScoreArray[insertLocation].score > storedCurrentScore!.score {
            insertLocation += 1
        }
        
        storedCurrentScore!.date = Calendar.getCurrentDate()
        if insertLocation < count {
            highScoreArray.insert(storedCurrentScore!, atIndex: insertLocation)
        } else if count < Stats.maxCount {
            highScoreArray.append(storedCurrentScore!)
        }
        
        storedCurrentScore = nil
    }
    
    /**
     Begins tracking a new game, starting from a score of 0.
     - requires: `!self.isTrackingGame`
     - postcondition: `self.isTrackingGame`
     */
    func beginTrackingGame() {
        if storedCurrentScore != nil {
            fatalError("Can't track multiple games; must finish tracking current game first.")
        }
        gamesPlayed += 1
        if count < Stats.maxCount {
            count += 1
        }
        storedCurrentScore = HighScore(score: 0, date: Stats.currentScoreDate)
    }
    
}


/** Keys to code and decode a `Stats` instance with `NSCoding`. */
private struct ScoresEncodingKeys {
    
    static let countKey = "com.megawattgaming.zlink.Stats.countKey"
    static let currentScoreKey = "com.megawattgaming.zlink.Stats.currentScoreKey"
    static let gamesPlayedKey = "com.megawattgaming.zlink.Stats.gamesPlayedKey"
    static let zlinksLinkedKey = "com.megawattgaming.zlink.Stats.zlinksLinkedKey"
    
}