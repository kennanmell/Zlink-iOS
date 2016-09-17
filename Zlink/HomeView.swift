//
//  HomeView.swift
//  Zlink
//
//  Created by Kennan Mell on 2/14/16.
//  Copyright © 2016 MegaWatt Gaming. All rights reserved.
//

import UIKit

/**
 `HomeView` displays the home page.
 
 - seealso: `HomeController`, `BoardView`
 */
class HomeView: UIView {
    
    // MARK: Properties
    
    /** Displays the title image. */
    let titleImage = UIImageView(image: ImageManager.image(forName: "home_title"))
    
    /** Used as the trophy case displaying the Zlinks seen by the player. */
    let boardView = BoardView(length: 3 /* 3x3=9 is the number of different Zlink types. */)
    
    /** Used to resume the current game or start a new one. (Redirects to tutorial on 1st open.) */
    let playButton = UIButton()
    
    
    // MARK: Initialization

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = ImageManager.appBackgroundColor
        
        playButton.setImage(ImageManager.image(forName: "play_button"), for: UIControlState())
        playButton.setImage(ImageManager.image(forName: "play_button_highlighted"), for: .highlighted)
        
        for tile in boardView.tileButtonArray {
            tile.adjustsImageWhenHighlighted = false
        }
        
        addSubview(boardView)
        addSubview(playButton)
        addSubview(titleImage)
    }
    
    
    // MARK: Layout Guidelines
    
    override func layoutSubviews() {
        
        // CONSTRAINTS
        
        // The number of rows on the page. This page has a row for the title, a row for the board, and a row for the play button.
        let numberOfRows: CGFloat = 3
        
        // Aspect ratios for various items on the page.
        let titleImageAspectRatio: CGFloat = 1.42 / 0.478
        let playButtonAspectRatio: CGFloat = 1.672 / 0.4
        
        // The amount of the width of the screen (on each side) to reserve for padding.
        let horizontalMargin: CGFloat
        // The amount of the height of the screen (on each side, not including the top bar) to reserve for padding.
        let verticalMargin: CGFloat
        if UIDevice.current.userInterfaceIdiom == .pad {
            // iPad
            horizontalMargin = self.frame.width * 0.22
            verticalMargin = self.frame.height * 0.065
        } else if self.frame.height == 480.0 {
            // iPhone 4 or 4s
            horizontalMargin = self.frame.width * 0.2
            verticalMargin = self.frame.height * 0.07
        } else {
            // iPhone 5 or later
            horizontalMargin = self.frame.width * 0.15
            verticalMargin = self.frame.height * 0.075
        }
        
        
        // INSTRUCTIONS
        
        // Lay out all main frames, ignoring for their y-origin for now.
        let titleWidth = self.frame.width - 2 * horizontalMargin
        titleImage.frame = CGRect(x: horizontalMargin, y: 0, width: titleWidth, height: titleWidth / titleImageAspectRatio)
        
        let boardViewDimension = self.frame.width - 2 * horizontalMargin
        boardView.frame = CGRect(x: horizontalMargin, y: 0, width: boardViewDimension, height: boardViewDimension)
        
        let playButtonWidth = self.frame.width - 2 * horizontalMargin
        playButton.frame = CGRect(x: horizontalMargin, y: 0, width: playButtonWidth, height: playButtonWidth / playButtonAspectRatio)

        // Determine the y-origin of each item and update that value accordingly for each item.
        let verticalSpaceAvailable = self.frame.height - 2 * verticalMargin - TopBarView.topBarHeight - titleImage.frame.height - boardView.frame.height - playButton.frame.height
        let verticalSpacePerItem = verticalSpaceAvailable / (numberOfRows - 1)
        
        titleImage.frame.origin.y = TopBarView.topBarHeight + verticalMargin
        boardView.frame.origin.y = titleImage.frame.origin.y + titleImage.frame.height + verticalSpacePerItem
        playButton.frame.origin.y = boardView.frame.origin.y + boardView.frame.height + verticalSpacePerItem
    }
    
}
