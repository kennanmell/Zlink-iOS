//
//  HomeController.swift
//  Zlink
//
//  Created by Kennan Mell on 2/8/16.
//  Copyright © 2016 MegaWatt Gaming. All rights reserved.
//

import UIKit

/**
 `HomeController` controls the home page.
 
 - seealso: `HomeView`
 */
class HomeController: UIViewController {
    
    // MARK: Properties
    
    /** The Storyboard ID of `HomeController`. */
    static let ID = "Home"
    
    /** `self.view` cast to `HomeView`. */
    private var homeView: HomeView {
        // This cast will always succeed if the Storyboard is set up correctly.
        return self.view as! HomeView
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check if there is a saved game and set the play button's image accordingly.
        if !SavedData.stats.isTrackingGame && SavedData.stats.count != 0 {
            homeView.playButton.setImage(ImageManager.imageForName("new_button"), forState: .Normal)
            homeView.playButton.setImage(ImageManager.imageForName("new_button_highlighted"), forState: .Highlighted)
        } else {
            homeView.playButton.setImage(ImageManager.imageForName("play_button"), forState: .Normal)
            homeView.playButton.setImage(ImageManager.imageForName("play_button_highlighted"), forState: .Highlighted)
        }
        
        // Fill in Zlinks on the `BoardView`.
        let bestScore: Int?
        if SavedData.stats.count != 0 {
            bestScore = SavedData.stats[0].score
        } else {
            bestScore = nil
        }
        
        let boardView = homeView.boardView
        for tileView in boardView.tileButtonArray {
            tileView.setImage(ImageManager.imageForName("board_empty"), forState: .Normal)
        }
        
        if bestScore != nil {
            boardView.tileButtonArray[6].setImage(ImageManager.imageForName("zlink_green"), forState: .Normal)
            boardView.tileButtonArray[6].setImage(ImageManager.imageForName("zlink_green_excited"), forState: .Highlighted)
            boardView.tileButtonArray[6].adjustsImageWhenHighlighted = true
            
            boardView.tileButtonArray[7].setImage(ImageManager.imageForName("zlink_pink"), forState: .Normal)
            boardView.tileButtonArray[7].setImage(ImageManager.imageForName("zlink_pink_excited"), forState: .Highlighted)
            boardView.tileButtonArray[7].adjustsImageWhenHighlighted = true

            boardView.tileButtonArray[8].setImage(ImageManager.imageForName("zlink_blue"), forState: .Normal)
            boardView.tileButtonArray[8].setImage(ImageManager.imageForName("zlink_blue_excited"), forState: .Highlighted)
            boardView.tileButtonArray[8].adjustsImageWhenHighlighted = true
        }

        if bestScore >= BoardFiller.zlinkIncrement1 {
            boardView.tileButtonArray[3].setImage(ImageManager.imageForName("zlink_purple"), forState: .Normal)
            boardView.tileButtonArray[3].setImage(ImageManager.imageForName("zlink_purple_excited"), forState: .Highlighted)
            boardView.tileButtonArray[3].adjustsImageWhenHighlighted = true
        }
        if bestScore >= BoardFiller.zlinkIncrement2 {
            boardView.tileButtonArray[5].setImage(ImageManager.imageForName("zlink_red"), forState: .Normal)
            boardView.tileButtonArray[5].setImage(ImageManager.imageForName("zlink_red_excited"), forState: .Highlighted)
            boardView.tileButtonArray[5].adjustsImageWhenHighlighted = true
        }
        if bestScore >= BoardFiller.zlinkIncrement3 {
            boardView.tileButtonArray[0].setImage(ImageManager.imageForName("zlink_white"), forState: .Normal)
            boardView.tileButtonArray[0].setImage(ImageManager.imageForName("zlink_white_excited"), forState: .Highlighted)
            boardView.tileButtonArray[0].adjustsImageWhenHighlighted = true
        }
        if bestScore >= BoardFiller.zlinkIncrement4 {
            boardView.tileButtonArray[1].setImage(ImageManager.imageForName("zlink_orange"), forState: .Normal)
            boardView.tileButtonArray[1].setImage(ImageManager.imageForName("zlink_orange_excited"), forState: .Highlighted)
            boardView.tileButtonArray[1].adjustsImageWhenHighlighted = true
        }
        if bestScore >= BoardFiller.zlinkIncrement5 {
            boardView.tileButtonArray[2].setImage(ImageManager.imageForName("zlink_black_round"), forState: .Normal)
            boardView.tileButtonArray[2].setImage(ImageManager.imageForName("zlink_black_round_excited"), forState: .Highlighted)
            boardView.tileButtonArray[2].adjustsImageWhenHighlighted = true
        }
        if SavedData.secretZlinkSeen {
            boardView.tileButtonArray[4].setImage(ImageManager.imageForName("zlink_rainbow"), forState: .Normal)
            boardView.tileButtonArray[4].setImage(ImageManager.imageForName("zlink_rainbow_excited"), forState: .Highlighted)
            boardView.tileButtonArray[4].adjustsImageWhenHighlighted = true
        }
        
        // Prepare gesture recognizers.
        homeView.playButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(HomeController.playTapped)))
    }
    
    
    // MARK: Play Button Delegate
    
    /** Called when the user taps the play/new game button. */
    func playTapped() {
        MediaPlayer.playMP3Sound(MediaPlayer.buttonPressSoundLocation)
        if SavedData.stats.count == 0 {
            // Tutorial never viewed, open tutorial scene.
            mainController.setViewController(TutorialController.ID)
        } else {
            // Tutorial already viewed, open play scene.
            mainController.setViewController(PlayController.ID)
        }
    }
    
}