//
//  PlayController.swift
//  Zlink
//
//  Created by Kennan Mell on 2/5/16.
//  Copyright © 2016 MegaWatt Gaming. All rights reserved.
//

import UIKit
import GameKit

/**
 `PlayController` controls the play page. It is also responsible for controlling or dispatching control events for the Power-Ups slider and the board the user plays on.
 
 - seealso: `Board`, `BoardFiller`, `PlayView`
 */
class PlayController: UIViewController {
    
    // MARK: Properties
    
    /** The Storyboard ID of `PlayController`. */
    static let ID = "Play"
    
    /** The `Board` instance representing the game the user is playing. */
    fileprivate let board = SavedData.board
    
    /** A `BoardFiller` instance tied to the game the user is playing (should refill `board`). */
    fileprivate let boardFiller = SavedData.boardFiller
    
    /** The intended tiles per row of the board the user plays on. */
    static let boardLength = 6
    
    /** A helper/sub- controller that animates changes to the board. */
    fileprivate var boardController: BoardController!
    
    /** A helper/sub-controller that performs actions after `boardController` is finished with a batch of animations. */
    fileprivate var allAnimationsCompleteListener: PlayAllAnimationsCompleteListener!
    
    /** `true` if and only if the power-ups slider is open (visible). */
    var powerupsOpen = false {
        didSet {
            let powerUpsView = playView.powerUpsView
            let powerUpsButton = playView.powerupsButton
            
            if powerupsOpen {
                playView.messageLabel.text = nil

                // Update the displays of each button on the slider.
                
                let tileRepairButton = powerUpsView.boardRepairButton
                if SavedData.boardRepairUsedInCurrentGame {
                    tileRepairButton.setImage(ImageManager.image(forName: "powerup_tile_repair_disabled"), for: UIControlState())
                    tileRepairButton.setImage(ImageManager.image(forName: "powerup_tile_repair_disabled"), for: .highlighted)
                } else {
                    tileRepairButton.setImage(ImageManager.image(forName: "powerup_tile_repair"), for: UIControlState())
                    tileRepairButton.setImage(ImageManager.image(forName: "powerup_tile_repair_highlighted"), for: .highlighted)
                }
                
                let magicTileButton = powerUpsView.magicWandButton
                if SavedData.magicWandUsedInCurrentGame {
                    magicTileButton.setImage(ImageManager.image(forName: "powerup_magic_tile_disabled"), for: UIControlState())
                    magicTileButton.setImage(ImageManager.image(forName: "powerup_magic_tile_disabled"), for: .highlighted)
                } else {
                    magicTileButton.setImage(ImageManager.image(forName: "powerup_magic_tile"), for: UIControlState())
                    magicTileButton.setImage(ImageManager.image(forName: "powerup_magic_tile_highlighted"), for: .highlighted)
                }
                
                let shuffleButton = powerUpsView.shuffleButton
                if SavedData.shuffleUsedInCurrentGame {
                    shuffleButton.setImage(ImageManager.image(forName: "powerup_shuffle_disabled"), for: UIControlState())
                    shuffleButton.setImage(ImageManager.image(forName: "powerup_shuffle_disabled"), for: .highlighted)
                } else {
                    shuffleButton.setImage(ImageManager.image(forName: "powerup_shuffle"), for: UIControlState())
                    shuffleButton.setImage(ImageManager.image(forName: "powerup_shuffle_highlighted"), for: .highlighted)
                }
                
                // Make sure inventory label is up to date.
                powerUpsView.inventoryLabel.text = "Power-Ups: " + String(SavedData.powerupsOwned)
                
                powerUpsButton.setImage(ImageManager.image(forName: "play_powerup_down"), for: UIControlState())
                powerUpsButton.setImage(ImageManager.image(forName: "play_powerup_down_highlighted"), for: .highlighted)
                
                // The amount of the total height of the powerups view that gets shown when it slides open.
                let amountShown = powerUpsView.frame.height * 0.85
                // Slide view open.
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                    powerUpsView.frame.origin.y -= amountShown
                    }, completion: nil)
            } else {
                powerUpsButton.setImage(ImageManager.image(forName: "play_powerup"), for: UIControlState())
                powerUpsButton.setImage(ImageManager.image(forName: "play_powerup_highlighted"), for: .highlighted)
                
                // Slide view closed.
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                    self.playView.powerUpsView.frame.origin.y = self.view.frame.height + 1
                    }, completion: nil)

            }
        }
    }
    
    /** The location of the `Tile` currently selected by the user, or `nil` if no `Tile` is currently selected. */
    var selectedTile: Int? {
        didSet {
            if selectedTile == nil {
                for i in 0..<board.totalTiles {
                    playView.boardView.tileButtonArray[i].setImage(ImageManager.image(forTile: board[i]), for: UIControlState())
                    playView.boardView.tileButtonArray[i].setImage(ImageManager.highlightedImage(forTile: board[i]), for: .highlighted)
                }
            } else if board[selectedTile!].isFull {
                for i in 0..<board.totalTiles {
                    if board[i].isFull {
                        playView.boardView.tileButtonArray[i].setImage(ImageManager.selectedImage(forTile: board[i]), for: UIControlState())
                        playView.boardView.tileButtonArray[i].setImage(ImageManager.selectedImage(forTile: board[i]), for: .highlighted)
                    } else {
                        playView.boardView.tileButtonArray[i].setImage(ImageManager.image(forTile: board[i]), for: UIControlState())
                        playView.boardView.tileButtonArray[i].setImage(ImageManager.highlightedImage(forTile: board[i]), for: .highlighted)
                    }
                }
            } else if board[selectedTile!].isNumber {
                for i in 0..<board.totalTiles {
                    playView.boardView.tileButtonArray[i].setImage(ImageManager.image(forTile: board[i]), for: UIControlState())
                    playView.boardView.tileButtonArray[i].setImage(ImageManager.highlightedImage(forTile: board[i]), for: .highlighted)
                }

                for direction in Direction.values {
                    if board.canMoveTile(location: selectedTile!, inDirection: direction) {
                        var locationX = selectedTile!
                        for _ in 0..<board[selectedTile!].intValue! {
                            locationX = board.shift(location: locationX, inDirection: direction)!
                            
                            playView.boardView.tileButtonArray[locationX].setImage(ImageManager.selectedImage(forTile: board[locationX]), for: UIControlState())
                            playView.boardView.tileButtonArray[locationX].setImage(ImageManager.selectedImage(forTile: board[locationX]), for: .highlighted)
                        }
                    }
                }
            } else {
                selectedTile = nil
                for i in 0..<board.totalTiles {
                    playView.boardView.tileButtonArray[i].setImage(ImageManager.image(forTile: board[i]), for: UIControlState())
                    playView.boardView.tileButtonArray[i].setImage(ImageManager.highlightedImage(forTile: board[i]), for: .highlighted)
                }
            }
        }
    }
    
    /** `self.view` cast to `PlayView`. */
    fileprivate var playView: PlayView {
        // This cast will always succeed if the Storyboard is set up correctly.
        return self.view as! PlayView
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure listeners.
        boardController = BoardController(boardView: playView.boardView)
        board.boardListener = boardController
        boardFiller.refillListener = boardController
        
        self.allAnimationsCompleteListener = PlayAllAnimationsCompleteListener(playController: self)
        boardController.allAnimationsCompleteListener = allAnimationsCompleteListener
        
        boardFiller.secretZlinkListener = PlaySecretZlinkListener()
        board.scoreListener = PlayScoreListener(label: playView.scoreLabel)
        
        // Update board.
        if !SavedData.stats.isTrackingGame {
            SavedData.shuffleUsedInCurrentGame = false
            SavedData.boardRepairUsedInCurrentGame = false
            SavedData.magicWandUsedInCurrentGame = false
            SavedData.stats.beginTrackingGame()
            board.clear()
            boardFiller.refillEmptyBoard()
        } else {
            // Force display of tiles even though saved board tiles are already set.
            for i in 0..<board.totalTiles {
                board[i] = board[i]
            }
        }
        
        // Update score label.
        playView.scoreLabel.text = String(board.score)
        
        // Add gesture recognizers.
        playView.restartButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PlayController.newGameTapped)))
        playView.powerupsButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PlayController.powerupsTapped)))
        playView.powerUpsView.magicWandButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PlayController.magicWandTapped)))
        playView.powerUpsView.boardRepairButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PlayController.boardRepairTapped)))
        playView.powerUpsView.shuffleButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PlayController.shuffleTapped)))
        playView.isUserInteractionEnabled = true
        playView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PlayController.backgroundPressed)))
                
        for i in 0..<board.totalTiles {
            // Add tile swipe gesture recognizers.
            let swipeGestureRecognizerLeft = UISwipeGestureRecognizer(target: self, action: #selector(PlayController.tileSwiped(_:)));
            swipeGestureRecognizerLeft.direction = .left
            playView.boardView.tileButtonArray[i].addGestureRecognizer(swipeGestureRecognizerLeft)
            
            let swipeGestureRecognizerRight = UISwipeGestureRecognizer(target: self, action: #selector(PlayController.tileSwiped(_:)));
            swipeGestureRecognizerRight.direction = .right
            playView.boardView.tileButtonArray[i].addGestureRecognizer(swipeGestureRecognizerRight)
            
            let swipeGestureRecognizerUp = UISwipeGestureRecognizer(target: self, action: #selector(PlayController.tileSwiped(_:)));
            swipeGestureRecognizerUp.direction = .up
            playView.boardView.tileButtonArray[i].addGestureRecognizer(swipeGestureRecognizerUp)
            
            let swipeGestureRecognizerDown = UISwipeGestureRecognizer(target: self, action: #selector(PlayController.tileSwiped(_:)));
            swipeGestureRecognizerDown.direction = .down
            playView.boardView.tileButtonArray[i].addGestureRecognizer(swipeGestureRecognizerDown)
            
            // Add tile single-tap gesture recognizer.
            playView.boardView.tileButtonArray[i].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PlayController.tileTapped(_:))))
        }
    }
    
    
    // MARK: Powerups Slider Delegate
    
    /** Toggles whether the Power-Ups slider is open/closed. Opens an alert promting the user to visit the Market instead if they're out of Power-Ups. Called when the user taps the powerups button. */
    func powerupsTapped() {
        MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.buttonPressSoundLocation)
        playView.messageLabel.text = nil
        if SavedData.powerupsOwned <= 0 {
            let alert = AlertView()
            alert.titleLabel.text = "Out of Power-Ups!"
            alert.messageLabel.text =  "Visit the Market to get more?"
            alert.aspectRatio = 1 / 0.85
            
            alert.topButton.setImage(ImageManager.image(forName: "popup_market"), for: UIControlState())
            alert.topButton.setImage(ImageManager.image(forName: "popup_market_highlighted"), for: .highlighted)
            
            alert.bottomButton.setImage(ImageManager.image(forName: "popup_cancel"), for: UIControlState())
            alert.bottomButton.setImage(ImageManager.image(forName: "popup_cancel_highlighted"), for: .highlighted)

            mainController.presentAlert(alert: alert, topButtonAction: {
                MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.buttonPressSoundLocation)
                self.mainController.setViewController(id: MarketController.ID)
            }, bottomButtonAction: {
                MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.buttonPressSoundLocation)
            })
        } else {
            powerupsOpen = !powerupsOpen
            selectedTile = nil
        }
    }
    
    
    /** Activates the Magic Wand Power-Up if it hasn't been used already. Called when the user taps the magic wand button in the powerups bar. */
    func magicWandTapped() {
        if SavedData.magicWandUsedInCurrentGame {
            playView.messageLabel.text = "You can only use each Power-Up once per game."
        } else {
            MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.buttonPressSoundLocation)
            playView.messageLabel.text = nil
            self.powerupsOpen = false
            board.magicWand()
            SavedData.powerupsOwned -= 1
            SavedData.magicWandUsedInCurrentGame = true
        }
    }
    
    
    /** Activates the Board Repair Power-Up if it hasn't been used already and there is at least one `Tile` to repair. Called when the user clicks the board repair button in the powerups bar. */
    func boardRepairTapped() {
        if SavedData.boardRepairUsedInCurrentGame {
            playView.messageLabel.text = "You can only use each Power-Up once per game."
        } else {
            MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.buttonPressSoundLocation)
            playView.messageLabel.text = nil
            if board.isBroken {
                self.powerupsOpen = false
                board.repairBoard()
                SavedData.powerupsOwned -= 1
                SavedData.boardRepairUsedInCurrentGame = true
            } else {
                playView.messageLabel.text = "That Power-Up can only be used when there are black holes on the board."
            }
        }
    }
    
    /** Activates the Shuffle Power-Up if it hasn't been used already. Called when the user taps the shuffle button in the powerups bar. */
    func shuffleTapped() {
        if SavedData.shuffleUsedInCurrentGame {
            playView.messageLabel.text = "You can only use each Power-Up once per game."
        } else {
            MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.buttonPressSoundLocation)
            playView.messageLabel.text = nil
            self.powerupsOpen = false
            boardFiller.shuffleBoard()
            SavedData.powerupsOwned -= 1
            SavedData.shuffleUsedInCurrentGame = true
        }
    }
    
    
    // MARK: New Game Button Delegate
    
    /** Opens a pop-up confirming that the user wants to start a new game, then starts a new game on confirmation. Called when the user taps the new game button. */
    func newGameTapped() {
        MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.buttonPressSoundLocation)
        powerupsOpen = false
        playView.messageLabel.text = nil
        selectedTile = nil
        
        let alert = AlertView()
        alert.titleLabel.text = "Start new game?"
        alert.messageLabel.text =  "This will end your current game."
        alert.aspectRatio = 1 / 0.85
        
        alert.topButton.setImage(ImageManager.image(forName: "popup_newgame"), for: UIControlState())
        alert.topButton.setImage(ImageManager.image(forName: "popup_newgame_highlighted"), for: .highlighted)
        
        alert.bottomButton.setImage(ImageManager.image(forName: "popup_cancel"), for: UIControlState())
        alert.bottomButton.setImage(ImageManager.image(forName: "popup_cancel_highlighted"), for: .highlighted)
        
        mainController.presentAlert(alert: alert, topButtonAction: {
            MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.buttonPressSoundLocation)
            PlayAllAnimationsCompleteListener.reportScoreToGameCenter(self.board.score)
            SavedData.stats.finishTrackingGame()
            SavedData.stats.beginTrackingGame()
            SavedData.shuffleUsedInCurrentGame = false
            SavedData.boardRepairUsedInCurrentGame = false
            SavedData.magicWandUsedInCurrentGame = false
            self.board.clear()
            self.boardFiller.refillEmptyBoard()
        }, bottomButtonAction: {
            MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.buttonPressSoundLocation)
        })
    }
    
    
    // MARK: Board View Delegate
    
    /**
    Selects/deselects a tapped tile, or moves a tapped tile if a selected location is tapped. Called when the user taps a tile on the board.
    - parameters:
        - gestureRecognizer: The `UITapGestureRecognizer` whose touch event resulted in this function call.
    */
    func tileTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        powerupsOpen = false
        playView.messageLabel.text = nil

        let location = playView.boardView.tileButtonArray.index(of: gestureRecognizer.view as! UIButton)!

        if location == selectedTile || (selectedTile != nil && board[selectedTile!].isFull && board[location].isFull) {
            MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.selectSoundLocation)
            playView.messageLabel.text = nil
            selectedTile = nil
        } else if board[location].isFull {
            MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.selectSoundLocation)
            selectedTile = location
            playView.messageLabel.text = "The number on each gold tile is the amount of moves before it turns black."
        } else if board[location].isNumber {
            MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.selectSoundLocation)
            for direction in Direction.values {
                if board.canMoveTile(location: location, inDirection: direction) {
                    selectedTile = location
                    playView.messageLabel.text = "The directions that the tapped number can be swiped are shown."
                    return
                }
            }
            
            selectedTile = nil
            playView.messageLabel.text = "That number can't be swiped now."
        } else if board[location] == .empty && selectedTile != nil && board[selectedTile!].isNumber {
            for direction in Direction.values {
                var locationX: Int? = location
                for _ in 0..<board[selectedTile!].intValue! {
                    if locationX != nil {
                        locationX = board.shift(location: locationX!, inDirection: direction)
                    }
                    if locationX == selectedTile && board.canMoveTile(location: selectedTile!, inDirection: direction.invert()) {
                        let locationToMove = selectedTile!
                        selectedTile = nil
                        handleMove(location: locationToMove, direction: direction.invert())
                        return
                    }
                }
            }
            selectedTile = nil
        } else {
            selectedTile = nil
        }
    }
    
    /**
     Moves a swiped tile, or indicates that the attempted move is invalid. Called when the user swipes a tile on the board.
     - parameters:
        - gestureRecognizer: The `UISwipeGestureRecognizer` whose touch event resulted in this function call.
     */
    func tileSwiped(_ gestureRecognizer: UISwipeGestureRecognizer) {
        powerupsOpen = false
        playView.messageLabel.text = nil
        selectedTile = nil

        let location = playView.boardView.tileButtonArray.index(of: gestureRecognizer.view as! UIButton)!
        var direction: Direction?
        switch (gestureRecognizer.direction) {
        case UISwipeGestureRecognizerDirection.up:
            direction = Direction.up
        case UISwipeGestureRecognizerDirection.down:
            direction = Direction.down
        case UISwipeGestureRecognizerDirection.right:
            direction = Direction.right
        case UISwipeGestureRecognizerDirection.left:
            direction = Direction.left
        default:
            // This won't happen, xcode is being dumb.
            break
        }
        
        handleMove(location: location, direction: direction!)
    }
    
    // MARK: Main View Delegate
    
    /** Cleans the view by closing the Power-Ups slider, deselecting all tiles, and hiding any displayed messages. Called when the user taps the main `UIView` of this controller. */
    func backgroundPressed() {
        playView.messageLabel.text = nil
        selectedTile = nil
        powerupsOpen = false
    }
    
    
    // MARK: Helper Functions
    
    /**
     Called to handle a request by the user to move a tile. Moves the tile and updates the board state as necessary if possible, and indicates that the move was invalid otherwise.
     - parameters:
        - location: The location of the `Tile` the user wants to move.
        - direction: The `Direction` the user wants to move the `Tile` in.
     */
    fileprivate func handleMove(location: Int, direction: Direction) {
        if board.moveTile(location: location, inDirection: direction) {
            MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.moveSoundLocation)
            if board.removeLinks() {
                board.stepTime()
                boardFiller.refillBoard()
            } else {
                board.stepTime()
                _ = boardFiller.addNumber(notify: true)
            }
        } else if board[location].isNumber {
            MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.badMoveSoundLocation)
            boardController.animateBadMove(location: location)
            let intValue = String(board[location].intValue!)
            if intValue == "1" {
                playView.messageLabel.text = "There must be 1 white tile next to that number to swipe it."
            } else {
                playView.messageLabel.text = "There must be " + intValue + " white tiles next to that number to swipe it."
            }
        }
    }
    
}


/** Used to keep the `scoreLabel`'s text up-to-date. */
private class PlayScoreListener:NSObject, ScoreListener {
    
    /** The minimum amount of time allowed between changes to the graphical representation of the score (in seconds). */
    fileprivate let updateInterval = 0.1
    
    /** Updates to the score that haven't been reflected graphically yet. These will be reflected graphically when the appropriate number of `updateInterval`s have passed. */
    fileprivate var pendingChanges = Array<Int>()
    
    /** The `UILabel` whose text should represent the current score on `PlayController.board`. */
    fileprivate weak var label: UILabel?
    
    /**
     Sole constructor.
     - parameters:
        - label: The `UILabel` whose text should represent the current score on `PlayController.board`.
     */
    init(label: UILabel) {
        self.label = label
    }
    
    func onScoreCleared() {
        label?.text = "0"
    }
    
    func onScoreIncremented(newScore: Int) {
        SavedData.stats.incrementCurrentScore()
        pendingChanges.append(newScore)
        if pendingChanges.count == 1 {
            play()
        }
    }
    
    /** Plays the next pending change, if any. */
    fileprivate func play() {
        if pendingChanges.count != 0 {
            let time = DispatchTime.now() + Double(Int64(updateInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                self.label?.text = String(self.pendingChanges.removeFirst())
                self.play()
            })
        }
    }
    
}


/** Used to save appropriate data when the secret Zlink is seen on `sharedBoard`. */
private class PlaySecretZlinkListener: NSObject, SecretZlinkListener {
    
    func onSecretZlinkSeen() {
        SavedData.secretZlinkSeen = true
        
        let zlink9 = GKAchievement(identifier: "rainbow_zlink")
        zlink9.showsCompletionBanner = false
        zlink9.percentComplete = 100
        
        GKAchievement.report([zlink9], withCompletionHandler: {(error : Error?) -> Void in
            if error != nil {
                NSLog(error!.localizedDescription)
            }
        })
    }
    
}

/** Used to determine what action to take (if any) when a `BoardController` completes a batch of animations. */
private class PlayAllAnimationsCompleteListener: NSObject, AllAnimationsCompleteListener {
    
    // MARK: Properties
    
    /** The `playController` instance that `self` should modify as necessary. */
    weak var playController: PlayController?
    
    
    // MARK: Functions
    
    /**
     Reports a score the user achieved while playing to the Game Center.
     - parameters:
        - score: The score the user achieved. This score will be reported to Game Center.
     - note: If `score` is above the maximum allowed score by Game Center, the maximum allowed score will be reported. If it is below the minimum allowed score, behavior is undefined.
     */
    static func reportScoreToGameCenter(_ score: Int) {
        if GKLocalPlayer.localPlayer().isAuthenticated == true {
            let bestScoreLeaderboard = GKLeaderboard()
            bestScoreLeaderboard.identifier = "best_score"
            bestScoreLeaderboard.timeScope = .allTime
            bestScoreLeaderboard.range = NSMakeRange(1, 1)
            bestScoreLeaderboard.loadScores(completionHandler: { _ in
                if bestScoreLeaderboard.localPlayerScore != nil {
                    if Int64(score) > bestScoreLeaderboard.localPlayerScore!.value {
                        let scoreReporter = GKScore(leaderboardIdentifier: "best_score")
                        scoreReporter.value = Int64(min(999, score))
                        let scoreArray: [GKScore] = [scoreReporter]
                        GKScore.report(scoreArray, withCompletionHandler: {(error : Error?) -> Void in
                            if error != nil {
                                NSLog(error!.localizedDescription)
                            }
                        })
                    }
                } else {
                    let scoreReporter = GKScore(leaderboardIdentifier: "best_score")
                    scoreReporter.value = Int64(min(999, score))
                    let scoreArray: [GKScore] = [scoreReporter]
                    GKScore.report(scoreArray, withCompletionHandler: {(error : Error?) -> Void in
                        if error != nil {
                            NSLog(error!.localizedDescription)
                        }
                    })
                }
            })
            
            let leaderboard = GKLeaderboard()
            leaderboard.identifier = "zlinks_linked"
            leaderboard.timeScope = .allTime
            leaderboard.range = NSMakeRange(1, 1)
            leaderboard.loadScores(completionHandler: { _ in
                var totalZlinksLinked = Int64(score)
                if leaderboard.localPlayerScore != nil {
                    totalZlinksLinked += leaderboard.localPlayerScore!.value
                }
                let zlinksLinkedReporter = GKScore(leaderboardIdentifier: "zlinks_linked")
                zlinksLinkedReporter.value = Int64(min(999999, totalZlinksLinked))
                let zlinksLinkedArray: [GKScore] = [zlinksLinkedReporter]
                GKScore.report(zlinksLinkedArray, withCompletionHandler: {(error : Error?) -> Void in
                    if error != nil {
                        NSLog(error!.localizedDescription)
                    }
                })
            })
        }
        
        
        var achievements = Array<GKAchievement>()
        
        let zlink1 = GKAchievement(identifier: "green_zlink")
        zlink1.showsCompletionBanner = false
        zlink1.percentComplete = 100
        achievements.append(zlink1)
        
        let zlink2 = GKAchievement(identifier: "pink_zlink")
        zlink2.showsCompletionBanner = false
        zlink2.percentComplete = 100
        achievements.append(zlink2)
        
        let zlink3 = GKAchievement(identifier: "blue_zlink")
        zlink3.showsCompletionBanner = false
        zlink3.percentComplete = 100
        achievements.append(zlink3)
        
        if score >= BoardFiller.zlinkIncrement1 {
            let zlink4 = GKAchievement(identifier: "purple_zlink")
            zlink4.showsCompletionBanner = false
            zlink4.percentComplete = 100
            achievements.append(zlink4)
        }
        
        if score >= BoardFiller.zlinkIncrement2 {
            let zlink5 = GKAchievement(identifier: "red_zlink")
            zlink5.showsCompletionBanner = false
            zlink5.percentComplete = 100
            achievements.append(zlink5)
        }
        
        if score >= BoardFiller.zlinkIncrement3 {
            let zlink6 = GKAchievement(identifier: "white_zlink")
            zlink6.showsCompletionBanner = false
            zlink6.percentComplete = 100
            achievements.append(zlink6)
        }
        
        if score >= BoardFiller.zlinkIncrement4 {
            let zlink7 = GKAchievement(identifier: "orange_zlink")
            zlink7.showsCompletionBanner = false
            zlink7.percentComplete = 100
            achievements.append(zlink7)
        }
        
        if score >= BoardFiller.zlinkIncrement5 {
            let zlink8 = GKAchievement(identifier: "black_zlink")
            zlink8.showsCompletionBanner = false
            zlink8.percentComplete = 100
            achievements.append(zlink8)
        }
        
        GKAchievement.report(achievements, withCompletionHandler: {(error : Error?) -> Void in
            if error != nil {
                NSLog(error!.localizedDescription)
            }
        })
    }
    
    /**
     Sole constructor.
     - parameters:
        - playController: The `playController` that `self` should modify as necessary. Stored weakly.
     */
    init(playController: PlayController) {
        self.playController = playController
    }
    
    func onAllAnimationsComplete() {
        // This function is used to check whether or not to end the game. This check is only performed after all animations are complete to avoid changing scenes too abruptly. Delaying this check will not cause problems because touch events are disabled during `TileAnimator` animations.
        if playController != nil {
            let board = playController!.board
            let boardFiller = playController!.boardFiller
            
            if board.removeLinks() {
                board.stepTime()
                boardFiller.refillBoard()
            } else if board.isGameOver {
                MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.gameoverSoundLocation)
                PlayAllAnimationsCompleteListener.reportScoreToGameCenter(board.score)
                SavedData.stats.finishTrackingGame()
                
                // Open gameover scene.
                playController?.mainController.setViewController(id: GameoverController.ID)
            }
        }
    }
}
