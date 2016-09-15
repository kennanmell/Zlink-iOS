//
//  GameoverController.swift
//  Zlink
//
//  Created by Kennan Mell on 2/6/16.
//  Copyright © 2016 MegaWatt Gaming. All rights reserved.
//

import UIKit

/**
 `GameoverController` controls the game over page.
 
 - seealso: `GameoverView`
 */
class GameoverController: UIViewController {
    
    // MARK: Properties
    
    /** The Storyboard ID of `GameoverController`. */
    static let ID = "Gameover"
    
    /** The `Board` instance to display. Should store the state of the last game the user played when they lost. */
    private let board = SavedData.board
    
    /** `self.view` cast to `GameoverView`. */
    private var gameoverView: GameoverView {
        // This cast will always succeed if the Storyboard is set up correctly.
        return self.view as! GameoverView
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the `BoardView` to display the state of the board when the user lost.
        for i in 0..<board.totalTiles {
            gameoverView.boardView.tileButtonArray[i].setImage(ImageManager.imageForTile(board[i]), forState: .Normal)
        }
        
        // Show correct score.
        gameoverView.scoreLabel.text = String(board.score)
        
        // Show high score sticker if necessary.
        gameoverView.highScoreStickerImage.hidden = SavedData.stats.count < 2 || !(board.score == SavedData.stats[0].score && board.score > SavedData.stats[1].score)
        
        // Prepare gesture recognizers.
        gameoverView.shareButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GameoverController.shareTapped)))
        gameoverView.newGameButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GameoverController.newGameTapped)))
    }
    
    
    // MARK: New Game Button Delegate
    
    /** Called when the user taps the new game button. */
    func newGameTapped() {
        MediaPlayer.playMP3Sound(MediaPlayer.buttonPressSoundLocation)
        mainController.setViewController(PlayController.ID)
    }
    
    
    // MARK: Share Button Delegate
    
    /** Called when the user taps the share button. */
    func shareTapped() {
        MediaPlayer.playMP3Sound(MediaPlayer.buttonPressSoundLocation)
        
        // Get screenshot to share.
        let layer = UIApplication.sharedApplication().keyWindow!.layer
        let scale = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()


        // Set up and open Apple's default sharing feature.
        let text = "Check out my latest score in Zlink!"
        
        var objectsToShare: Array<NSObject> = [text]
        
        if let website = NSURL(string: "http://www.megawattgaming.com/") {
            objectsToShare.append(website)
        }
        
        if screenshot != nil {
            objectsToShare.append(screenshot)
        }
        
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        let popoverView = UIView()
        if activityVC.respondsToSelector(Selector("popoverPresentationController")) {
            // iPad
            let shareButton = gameoverView.shareButton
            popoverView.frame = CGRect(x: shareButton.frame.origin.x - self.view.frame.width * 0.01, y: shareButton.frame.origin.y + shareButton.frame.height / 2, width: 1, height: 1)
            self.view.addSubview(popoverView)
            activityVC.popoverPresentationController?.sourceView = popoverView
        }

        self.navigationController!.presentViewController(activityVC, animated: true, completion: {
            popoverView.removeFromSuperview()
        })
    }
    
}