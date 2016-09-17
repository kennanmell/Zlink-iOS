//
//  HomeController.swift
//  Zlink
//
//  Created by Kennan Mell on 2/8/16.
//  Copyright © 2016 MegaWatt Gaming. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


/**
 `HomeController` controls the home page.
 
 - seealso: `HomeView`
 */
class HomeController: UIViewController {
    
    // MARK: Properties
    
    /** The Storyboard ID of `HomeController`. */
    static let ID = "Home"
    
    /** `self.view` cast to `HomeView`. */
    fileprivate var homeView: HomeView {
        // This cast will always succeed if the Storyboard is set up correctly.
        return self.view as! HomeView
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check if there is a saved game and set the play button's image accordingly.
        if !SavedData.stats.isTrackingGame && SavedData.stats.count != 0 {
            homeView.playButton.setImage(ImageManager.image(forName: "new_button"), for: UIControlState())
            homeView.playButton.setImage(ImageManager.image(forName: "new_button_highlighted"), for: .highlighted)
        } else {
            homeView.playButton.setImage(ImageManager.image(forName: "play_button"), for: UIControlState())
            homeView.playButton.setImage(ImageManager.image(forName: "play_button_highlighted"), for: .highlighted)
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
            tileView.setImage(ImageManager.image(forName: "board_empty"), for: UIControlState())
        }
        
        if bestScore != nil {
            boardView.tileButtonArray[6].setImage(ImageManager.image(forName: "zlink_green"), for: UIControlState())
            boardView.tileButtonArray[6].setImage(ImageManager.image(forName: "zlink_green_excited"), for: .highlighted)
            boardView.tileButtonArray[6].adjustsImageWhenHighlighted = true
            
            boardView.tileButtonArray[7].setImage(ImageManager.image(forName: "zlink_pink"), for: UIControlState())
            boardView.tileButtonArray[7].setImage(ImageManager.image(forName: "zlink_pink_excited"), for: .highlighted)
            boardView.tileButtonArray[7].adjustsImageWhenHighlighted = true

            boardView.tileButtonArray[8].setImage(ImageManager.image(forName: "zlink_blue"), for: UIControlState())
            boardView.tileButtonArray[8].setImage(ImageManager.image(forName: "zlink_blue_excited"), for: .highlighted)
            boardView.tileButtonArray[8].adjustsImageWhenHighlighted = true
        }

        if bestScore >= BoardFiller.zlinkIncrement1 {
            boardView.tileButtonArray[3].setImage(ImageManager.image(forName: "zlink_purple"), for: UIControlState())
            boardView.tileButtonArray[3].setImage(ImageManager.image(forName: "zlink_purple_excited"), for: .highlighted)
            boardView.tileButtonArray[3].adjustsImageWhenHighlighted = true
        }
        if bestScore >= BoardFiller.zlinkIncrement2 {
            boardView.tileButtonArray[5].setImage(ImageManager.image(forName: "zlink_red"), for: UIControlState())
            boardView.tileButtonArray[5].setImage(ImageManager.image(forName: "zlink_red_excited"), for: .highlighted)
            boardView.tileButtonArray[5].adjustsImageWhenHighlighted = true
        }
        if bestScore >= BoardFiller.zlinkIncrement3 {
            boardView.tileButtonArray[0].setImage(ImageManager.image(forName: "zlink_white"), for: UIControlState())
            boardView.tileButtonArray[0].setImage(ImageManager.image(forName: "zlink_white_excited"), for: .highlighted)
            boardView.tileButtonArray[0].adjustsImageWhenHighlighted = true
        }
        if bestScore >= BoardFiller.zlinkIncrement4 {
            boardView.tileButtonArray[1].setImage(ImageManager.image(forName: "zlink_orange"), for: UIControlState())
            boardView.tileButtonArray[1].setImage(ImageManager.image(forName: "zlink_orange_excited"), for: .highlighted)
            boardView.tileButtonArray[1].adjustsImageWhenHighlighted = true
        }
        if bestScore >= BoardFiller.zlinkIncrement5 {
            boardView.tileButtonArray[2].setImage(ImageManager.image(forName: "zlink_black_round"), for: UIControlState())
            boardView.tileButtonArray[2].setImage(ImageManager.image(forName: "zlink_black_round_excited"), for: .highlighted)
            boardView.tileButtonArray[2].adjustsImageWhenHighlighted = true
        }
        if SavedData.secretZlinkSeen {
            boardView.tileButtonArray[4].setImage(ImageManager.image(forName: "zlink_rainbow"), for: UIControlState())
            boardView.tileButtonArray[4].setImage(ImageManager.image(forName: "zlink_rainbow_excited"), for: .highlighted)
            boardView.tileButtonArray[4].adjustsImageWhenHighlighted = true
        }
        
        // Prepare gesture recognizers.
        homeView.playButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(HomeController.playTapped)))
    }
    
    
    // MARK: Play Button Delegate
    
    /** Called when the user taps the play/new game button. */
    func playTapped() {
        MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.buttonPressSoundLocation)
        if SavedData.stats.count == 0 {
            // Tutorial never viewed, open tutorial scene.
            mainController.setViewController(id: TutorialController.ID)
        } else {
            // Tutorial already viewed, open play scene.
            mainController.setViewController(id: PlayController.ID)
        }
    }
    
}
