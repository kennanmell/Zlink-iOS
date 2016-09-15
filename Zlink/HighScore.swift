//
//  HighScore.swift
//  Zlink
//
//  Created by Kennan Mell on 3/23/16.
//  Copyright © 2016 MegaWatt Gaming. All rights reserved.
//

import Foundation

/**
 `HighScore` is an abstract data type intended to be used with the `Stats` class. A `HighScore` stores an `Int` representing a score achieved in a game of Zlink and a `String` representing the date the score was achieved.
 
 `HighScore` conforms to `NSCoding`.
 
 - seealso: `Stats`
 */
class HighScore: NSObject, NSCoding {
    
    // MARK: Properties
    
    /** An `Int` representing a score achieved in a game of Zlink. */
    var score: Int
    /** A `String` representing the date `score` was achieved. */
    var date: String
    
    
    // MARK: Initialization
    
    /**
     Returns a new `HighScore` instance.
     - parameters:
        - score: `self.score` will be set to this value.
        - date: `self.date` will be set to this value.
     - requires: Although not a strict requirement, it is advised that `score >= 0` and `date` is in "mm/dd/yyyy" format.
     */
    init(score: Int, date: String) {
        self.score = score
        self.date = date
    }
    
    /**
     Returns a new `HighScore` instance with the same abstract value as another `HighScore`.
     - parameters:
        - otherHighScore: The `HighScore` instance to copy.
     - postcondition: `self.score == otherHighScore.score && self.date == otherHighScore.date`
     */
    init(otherHighScore: HighScore) {
        self.score = otherHighScore.score
        self.date = otherHighScore.date
    }
    
    
    // MARK: NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        let score = aDecoder.decodeIntegerForKey(HighScoreEncodingKeys.scoreKey)
        let date = aDecoder.decodeObjectForKey(HighScoreEncodingKeys.dateKey) as! String
        self.init(score: score, date: date)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(score, forKey: HighScoreEncodingKeys.scoreKey)
        aCoder.encodeObject(date, forKey: HighScoreEncodingKeys.dateKey)
    }
    
}

/** Keys to access permanently stored properties of a GameData instance with NSCoding. */
private struct HighScoreEncodingKeys {
    static let scoreKey = "com.megawattgaming.zlink.HighScore.scoreKey"
    static let dateKey = "com.megawattgaming.zlink.HighScore.dateKey"
}