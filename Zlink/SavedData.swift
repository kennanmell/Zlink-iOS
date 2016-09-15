//
//  SavedData.swift
//  Zlink
//
//  Created by Kennan Mell on 2/4/16.
//  Copyright © 2016 MegaWatt Gaming. All rights reserved.
//

import Foundation

/** 
 `SavedData` is an abstract data type singleton/static struct that stores a collection of static properties representing settings, achievements, and data related to the Zlink game.
 
 If `SavedData.saveCurrentData()` is called, each property is guaranteed to have the same value it had at the time of the call the next time the application opens.
 
 - seealso: `Board`, `BoardFiller`, `Stats`
*/
struct SavedData {
    
    // MARK: Properties
    
    /** A `Board` instance. */
    static var board = boardFiller.board
    
    /** A `BoardFiller` instance. `boardFiller.board == SavedData.board` */
    static var boardFiller = SavedData.loadBoardFiller()
    
    
    /** A `Stats` instance. */
    static let stats = SavedData.loadInstance()
    
    /** The last day that the daily reward was given away. Format: "mm/dd/yyyy" */
    static var lastFreeGiveawayDate = NSUserDefaults.standardUserDefaults().stringForKey(SavedDataEncodingKeys.lastFreeGiveawayDateKey)
    
    /** The number of video ads the user has watched on the current day. */
    static var adsWatchedToday = NSUserDefaults.standardUserDefaults().integerForKey(SavedDataEncodingKeys.adsWatchedTodayKey)
    
    /** The day the user first opened the app since it was last downloaded/reset. Format: "mm/dd/yyyy" */
    static var dateOfFirstOpen = NSUserDefaults.standardUserDefaults().stringForKey(SavedDataEncodingKeys.dateOfFirstOpenKey)
    
    /** The total number of Power-Ups the user owns. */
    static var powerupsOwned = NSUserDefaults.standardUserDefaults().integerForKey(SavedDataEncodingKeys.powerupsOwnedKey)
    
    /** `true` if and only if the application should play background music while active. */
    static var musicOn = NSUserDefaults.standardUserDefaults().boolForKey(SavedDataEncodingKeys.musicOnKey)
    
    /** `true` if and only if the application should play sound effects for events. */
    static var sfxOn = NSUserDefaults.standardUserDefaults().boolForKey(SavedDataEncodingKeys.sfxOnKey)
    
    /** `true` if and only if the user has seen `Tile.Zlink9` */
    static var secretZlinkSeen = NSUserDefaults.standardUserDefaults().boolForKey(SavedDataEncodingKeys.secretZlinkSeenKey)
    
    /** `true` if and only if the Shuffle Power-Up was used in the current game. Meaningless if `!SavedData.stats.isTrackingGame`. */
    static var shuffleUsedInCurrentGame = NSUserDefaults.standardUserDefaults().boolForKey(SavedDataEncodingKeys.shuffleUsedInCurrentGameKey)
    
    /** `true` if and only if the Board Repair Power-Up was used in the current game. Meaningless if `!SavedData.stats.isTrackingGame`. */
    static var boardRepairUsedInCurrentGame = NSUserDefaults.standardUserDefaults().boolForKey(SavedDataEncodingKeys.boardRepairUsedInCurrentGameKey)
    
    /** `true` if and only if the Magic Wand Power-Up was used in the current game. Meaningless if `!SavedData.stats.isTrackingGame`. */
    static var magicWandUsedInCurrentGame = NSUserDefaults.standardUserDefaults().boolForKey(SavedDataEncodingKeys.magicWandUsedInCurrentGameKey)
    
    
    // MARK: Functions
    
    /**
     Saves the default state of all `SavedData` properties to permanent storage.
     - postcondition:
        + `!secretZlinkSeen`
        + `musicOn`
        + `sfxOn`
        + `!shuffleUsedInCurrentGame`
        + `!boardRepairUsedInCurrentGame`
        + `!magicWandUsedInCurrentGame`
        + `dateOfFirstOpen == lastFreeGiveawayDate == Calendar.getCurrentDate()` (at time of call)
        + `adsWatchedToday == 0` (Only holds if no previous value existed; an existing previous value is not modified.)
        + powerupsOwned == 5` (Only holds if no previous value existed; an existing previous value is not modified.)
        + `stats.clear()` is called by this function.
     */
    static func saveDefaultData() {
        // Update key-value data.
        let dataManager = NSUserDefaults.standardUserDefaults()
        if dataManager.objectForKey(SavedDataEncodingKeys.powerupsOwnedKey) == nil {
            powerupsOwned = 5
        }
        if dataManager.objectForKey(SavedDataEncodingKeys.adsWatchedTodayKey) == nil {
            adsWatchedToday = 0
        }
        dateOfFirstOpen = Calendar.getCurrentDate()
        lastFreeGiveawayDate = dateOfFirstOpen
        secretZlinkSeen = false
        musicOn = true
        sfxOn = true
        shuffleUsedInCurrentGame = false
        boardRepairUsedInCurrentGame = false
        magicWandUsedInCurrentGame = false
        
        // Clear stats.
        stats.clear()
        NSKeyedArchiver.archiveRootObject(stats, toFile: SavedDataEncodingKeys.statsArchiveURL.path!)
        
        // Save updated data.
        saveCurrentData()
    }
    
    /** Saves the current state of all `SavedData` properties to permanent storage. */
    static func saveCurrentData() {
        let dataManager = NSUserDefaults.standardUserDefaults()
        
        // Save key-value data.
        dataManager.setObject(lastFreeGiveawayDate, forKey: SavedDataEncodingKeys.lastFreeGiveawayDateKey)
        dataManager.setInteger(adsWatchedToday, forKey: SavedDataEncodingKeys.adsWatchedTodayKey)
        dataManager.setObject(dateOfFirstOpen, forKey: SavedDataEncodingKeys.dateOfFirstOpenKey)
        dataManager.setInteger(powerupsOwned, forKey: SavedDataEncodingKeys.powerupsOwnedKey)
        dataManager.setBool(musicOn, forKey: SavedDataEncodingKeys.musicOnKey)
        dataManager.setBool(sfxOn, forKey: SavedDataEncodingKeys.sfxOnKey)
        dataManager.setBool(secretZlinkSeen, forKey: SavedDataEncodingKeys.secretZlinkSeenKey)
        dataManager.setBool(shuffleUsedInCurrentGame, forKey: SavedDataEncodingKeys.shuffleUsedInCurrentGameKey)
        dataManager.setBool(magicWandUsedInCurrentGame, forKey: SavedDataEncodingKeys.magicWandUsedInCurrentGameKey)
        dataManager.setBool(boardRepairUsedInCurrentGame, forKey: SavedDataEncodingKeys.boardRepairUsedInCurrentGameKey)
        dataManager.synchronize()
        
        // Save board and boardFiller.
        NSKeyedArchiver.archiveRootObject(boardFiller, toFile: SavedDataEncodingKeys.boardFillerArchiveURL.path!)
        
        // Save stats.
        NSKeyedArchiver.archiveRootObject(stats, toFile: SavedDataEncodingKeys.statsArchiveURL.path!)
    }
    
    /** Loads the saved `BoardFiller` instance from disk. Returns the loaded instance if it exists, and a new `Board` and `BoardFiller` otherwise. */
    private static func loadBoardFiller() -> BoardFiller {
        var result = NSKeyedUnarchiver.unarchiveObjectWithFile(SavedDataEncodingKeys.boardFillerArchiveURL.path!) as? BoardFiller
        if result == nil {
            result = BoardFiller(board: Board(rowLength: PlayController.boardLength))
        }
        return result!
    }
    
    /** Loads the saved `Stats` instance from disk. Returns the loaded instance if it exists, and a new `Stats` otherwise. */
    private static func loadInstance() -> Stats {
        let result = NSKeyedUnarchiver.unarchiveObjectWithFile(SavedDataEncodingKeys.statsArchiveURL.path!) as? Stats
        if result == nil {
            return Stats()
        } else {
            return result!
        }
    }
    
}

/** Keys to code and decode a `SavedData` instance with `NSCoding` and `NSUserDefaults`. */
private struct SavedDataEncodingKeys {
    
    // Key for board and boardFiller.
    static let boardFillerArchiveURL = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!.URLByAppendingPathComponent("sharedBoardFiller")
    
    // Key for stats.
    private static let statsArchiveURL = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!.URLByAppendingPathComponent("scores")
    
    // Keys for NSUserDefaults.
    static let dateOfFirstOpenKey = "com.megawattgaming.zlink.SavedData.dateOfFirstOpenKey"
    static let powerupsOwnedKey = "com.megawattgaming.zlink.SavedData.powerupsOwnedKey"
    static let musicOnKey = "com.megawattgaming.zlink.SavedData.musicOnKey"
    static let sfxOnKey = "com.megawattgaming.zlink.SavedData.sfxOnKey"
    static let secretZlinkSeenKey = "com.megawattgaming.zlink.SavedData.secretZlinkSeenKey"
    static let lastFreeGiveawayDateKey = "com.megawattgaming.zlink.SavedData.lastFreeGiveawayDateKey"
    static let adsWatchedTodayKey = "com.megawattgaming.zlink.SavedData.adsWatchedTodayKey"
    static let shuffleUsedInCurrentGameKey = "com.megawattgaming.zlink.SavedData.shuffleUsedInCurrentGameKey"
    static let boardRepairUsedInCurrentGameKey = "com.megawattgaming.zlink.SavedData.boardRepairUsedInCurrentGameKey"
    static let magicWandUsedInCurrentGameKey = "com.megawattgaming.zlink.SavedData.magicWandUsedInCurrentGameKey"
    
}