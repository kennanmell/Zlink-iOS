//
//  PlayView.swift
//  Zlink
//
//  Created by Kennan Mell on 2/14/16.
//  Copyright © 2016 MegaWatt Gaming. All rights reserved.
//

import UIKit

/**
 `PlayView` displays the play page.
 
 - seealso: `PlayPowerUpsView`, `PlayController`, `BoardView`
 */
class PlayView: UIView {
    
    // MARK: Properties
    
    /** Used as the board the user plays the game on. */
    let boardView = BoardView(length: PlayController.boardLength)
    
    /** Used as the power-ups slider. */
    let powerUpsView = PlayPowerUpsView()
    
    /** Displays a message above the board in certain situations. */
    let messageLabel = UILabel()
    
    /** Displays the bottom bar background. */
    let bottomBarImage = UIImageView(image: ImageManager.imageForName("play_bottom_bar_background"))
    
    /** Used to toggle the Power-Ups slider. */
    let powerupsButton = UIButton()
    
    /** Used to end the current game and start a new game. */
    let restartButton = UIButton()
    
    /** Displays the player's current score. */
    let scoreLabel = UILabel()
    
    
    // MARK: Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = ImageManager.appBackgroundColor
        
        messageLabel.lineBreakMode = .ByWordWrapping
        messageLabel.adjustsFontSizeToFitWidth = true
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .Center
        
        powerupsButton.setImage(ImageManager.imageForName("play_powerup"), forState: .Normal)
        powerupsButton.setImage(ImageManager.imageForName("play_powerup_highlighted"), forState: .Highlighted)
        
        restartButton.setImage(ImageManager.imageForName("play_reset"), forState: .Normal)
        restartButton.setImage(ImageManager.imageForName("play_reset_highlighted"), forState: .Highlighted)
        
        scoreLabel.text = "0"
        scoreLabel.textAlignment = .Center
        scoreLabel.textColor = UIColor(white: 39.0 / 255.0, alpha: 1.0)
        
        addSubview(boardView)
        addSubview(powerUpsView)
        addSubview(messageLabel)
        addSubview(bottomBarImage)
        addSubview(powerupsButton)
        addSubview(restartButton)
        addSubview(scoreLabel)
    }
    
    
    // MARK: Layout Guidelines
    
    override func layoutSubviews() {
        
        // CONSTRAINTS
        
        // Aspect ratios for various items on the page.
        let bottomBarImageAspectRatio: CGFloat = 1800.0 / 269.0
        let buttonAspectRatio: CGFloat = 0.565 / 0.375
        let powerUpsViewAspectRatio: CGFloat = 1800.0 / 810.0
        
        // The width (and height) of `boardView`.
        let boardViewDimension: CGFloat
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            // iPad
            boardViewDimension = self.frame.width * 0.75
            messageLabel.font = UIFont(name: "Dosis", size: self.frame.width / 20)
        } else if self.frame.height == 480.0 {
            // iPhone 4 or 4s
            boardViewDimension = self.frame.width * 0.85
            messageLabel.font = UIFont(name: "Dosis", size: self.frame.width / 18)
        } else {
            // iPhone 5 and later
            boardViewDimension = self.frame.width * 0.95
            messageLabel.font = UIFont(name: "Dosis", size: self.frame.width / 15)
        }

        
        // INSTRUCTIONS
        
        let bottomBarHeight = self.frame.width / bottomBarImageAspectRatio
        
        bottomBarImage.frame = CGRect(x: 0, y: self.frame.height - bottomBarHeight, width: self.frame.width, height: bottomBarHeight)
        
        powerupsButton.frame = CGRect(x: 0, y: self.frame.height - bottomBarHeight, width: bottomBarImage.frame.height * buttonAspectRatio, height: bottomBarHeight)
        
        restartButton.frame = powerupsButton.frame
        restartButton.frame.origin.x = self.frame.width - restartButton.frame.width
        
        scoreLabel.font = UIFont(name: "Dosis-Bold", size: bottomBarImage.frame.height / 1.5)
        scoreLabel.frame = CGRect(x: 0, y: self.frame.height - bottomBarHeight - bottomBarImage.frame.height / 6, width: self.frame.width, height: bottomBarHeight)
        
        boardView.frame = CGRect(x: (self.frame.width - boardViewDimension) / 2, y: self.frame.height / 2 - boardViewDimension / 2, width: boardViewDimension, height: boardViewDimension)
        
        messageLabel.frame = CGRect(x: boardView.frame.origin.x, y: TopBarView.topBarHeight, width: boardView.frame.width, height: boardView.frame.origin.y - TopBarView.topBarHeight)
        
        powerUpsView.frame = CGRect(x: 0, y: self.frame.height + 1, width: self.frame.width, height: self.frame.width / powerUpsViewAspectRatio)
        
        // Readjust the y-origin of the message to center it between the board and the top bar.
        messageLabel.frame.origin.y = TopBarView.topBarHeight + ((boardView.frame.origin.y - TopBarView.topBarHeight - messageLabel.frame.height) / 2)
    }
    
}