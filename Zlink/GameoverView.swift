//
//  GameoverView.swift
//  Zlink
//
//  Created by Kennan Mell on 2/17/16.
//  Copyright © 2016 MegaWatt Gaming. All rights reserved.
//

import UIKit

/**
 `GameoverView` displays the game over page.
 
 - seealso: `GameoverController`, `BoardView`
 */
class GameoverView: UIView {
    
    // MARK: Properties
    
    /** Used to display the state of the board when the player lost. */
    let boardView = BoardView(length: PlayController.boardLength)
    
    /** Displays the page's title. */
    let titleImage = UIImageView(image: ImageManager.imageForName("gameover_title"))
    
    /** Displays the background behind the score the user achieved. */
    let scoreImage = UIImageView(image: ImageManager.imageForName("gameover_score"))
    
    /** Used to start a new game. */
    let newGameButton = UIButton()
    
    /** Used to share the screen. */
    let shareButton = UIButton()
    
    /** Displays the score the user achieved. */
    let scoreLabel = UILabel()
    
    /** Displays a badge indicating the user just got a high score. */
    let highScoreStickerImage = UIImageView(image: ImageManager.imageForName("gameover_sticker"))
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = ImageManager.appBackgroundColor
        
        shareButton.setImage(ImageManager.imageForName("gameover_share"), forState: .Normal)
        shareButton.setImage(ImageManager.imageForName("gameover_share_highlighted"), forState: .Highlighted)
        
        newGameButton.setImage(ImageManager.imageForName("new_button"), forState: .Normal)
        newGameButton.setImage(ImageManager.imageForName("new_button_highlighted"), forState: .Highlighted)
        
        scoreLabel.text = "000"
        scoreLabel.textAlignment = .Center
        scoreLabel.textColor = UIColor(white: 39.0 / 255.0, alpha: 1.0)
        
        for tile in boardView.tileButtonArray {
            tile.userInteractionEnabled = false
        }
        
        addSubview(boardView)
        addSubview(scoreImage)
        addSubview(newGameButton)
        addSubview(shareButton)
        addSubview(scoreLabel)
        addSubview(titleImage)
        addSubview(highScoreStickerImage)
    }
    
    
    // MARK: Layout Guidelines
    
    override func layoutSubviews() {
        
        // CONSTRAINTS
        
        // The number of rows on the page. This page has a row for the title, the board, the score, and the new game button.
        let numberOfRows: CGFloat = 4
        
        // Aspect ratios for various items on the page.
        let titleImageAspectRatio: CGFloat = 1.782 / 0.324
        let scoreImageAspectRatio: CGFloat = 1.672 / 0.54
        let newGameButtonAspectRatio: CGFloat = 1.672 / 0.4
        let shareButtonAspectRatio: CGFloat = 86.0 / 133.0
        
        // The amount of the width of the screen (on each side) to reserve for padding.
        let horizontalMargin: CGFloat
        // The amount of the height of the screen (on each side, not including the top bar) to reserve for padding.
        let verticalMargin: CGFloat
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            // iPad
            horizontalMargin = self.frame.width * 0.22
            verticalMargin = self.frame.height * 0.03
        } else if self.frame.height == 480.0 {
            // iPhone 4 or 4s
            horizontalMargin = self.frame.width * 0.2
            verticalMargin = self.frame.height * 0.04
        } else {
            // iPhone 5 and later
            horizontalMargin = self.frame.width * 0.15
            verticalMargin = self.frame.height * 0.05
        }
        
        // The unscaled text size of the score text
        let scoreTextSize: CGFloat = 0.2

        
        // INSTRUCTIONS
        
        // Lay out all main frames, ignoring for their y-origin for now.
        
        let itemsWidth = self.frame.width - 2 * horizontalMargin
        
        titleImage.frame = CGRect(x: horizontalMargin, y: 0, width: itemsWidth, height: itemsWidth / titleImageAspectRatio)
        
        boardView.frame = CGRect(x: horizontalMargin, y: 0, width: itemsWidth, height: itemsWidth)
        
        scoreImage.frame = CGRect(x: horizontalMargin, y: 0, width: itemsWidth, height: itemsWidth / scoreImageAspectRatio)
        
        newGameButton.frame = CGRect(x: horizontalMargin, y: 0, width: itemsWidth, height: itemsWidth / newGameButtonAspectRatio)
        
        // Determine the y-origin of each item and update that value accordingly for each item.
        let verticalSpaceAvailable = self.frame.height - titleImage.frame.height - boardView.frame.height - scoreImage.frame.height - newGameButton.frame.height - 2 * verticalMargin - TopBarView.topBarHeight
        
        let verticalSpacePerItem = verticalSpaceAvailable / (numberOfRows - 1)
        
        titleImage.frame.origin.y = TopBarView.topBarHeight + verticalMargin
        boardView.frame.origin.y = titleImage.frame.origin.y + titleImage.frame.height + verticalSpacePerItem
        scoreImage.frame.origin.y = boardView.frame.origin.y + boardView.frame.height + verticalSpacePerItem
        newGameButton.frame.origin.y = scoreImage.frame.origin.y + scoreImage.frame.height + verticalSpacePerItem

        // Update frames for helper items like text boxes and scroll/page views.
        let shareButtonWidth = scoreImage.frame.width * 0.06
        shareButton.frame = CGRect(x: scoreImage.frame.origin.x + scoreImage.frame.width * 0.9, y: scoreImage.frame.origin.y + scoreImage.frame.height * 0.12, width: shareButtonWidth, height: shareButtonWidth / shareButtonAspectRatio)
        
        scoreLabel.frame = scoreImage.frame
        scoreLabel.frame.origin.y -= scoreImage.frame.width / 25
        scoreLabel.font = UIFont(name: "Dosis-SemiBold", size: scoreImage.frame.width * scoreTextSize)
        
        highScoreStickerImage.frame = CGRect(x: scoreImage.frame.origin.x - self.frame.width * 0.048, y: scoreImage.frame.origin.y - self.frame.width * 0.048, width: scoreImage.frame.width * 0.3, height: scoreImage.frame.width * 0.3)
    }
    
}