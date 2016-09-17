//
//  MenuView.swift
//  Zlink
//
//  Created by Kennan Mell on 2/8/16.
//  Copyright © 2016 MegaWatt Gaming. All rights reserved.
//

import UIKit

/**
 `MenuView` displays the side menu.
 
 - seealso: `MainController`
 */
class MenuView: UIView {
    
    // MARK: Properties
    
    /** Used to navigate to the play page. */
    let playButton = UIButton()
    
    /** Used to navigate to the scores page. */
    let scoresButton = UIButton()
    
    /** Used to open game center. */
    let leaderboardButton = UIButton()
    
    /** Used to navigate to the market page. */
    let marketButton = UIButton()
    
    /** Used to toggle sound effects. */
    let sfxButton = UIButton()
    
    /** Used to toggle background music. */
    let musicButton = UIButton()
    
    /** Used to navigate to the tutorial page. */
    let tutorialButton = UIButton()
    
    /** Used to make the side menu purple. */
    let purpleView = UIView()
    
    /** Used to darken the rest of the screen. */
    let leftoverView = UIView()
    
    /** The frame of the side menu (excluding the `leftoverView`). */
    var menuFrame: CGRect!
    
    
    // MARK: Initialization
    
    /**
     Sole initializer.
     - parameters:
        - superViewFrame: The frame of the `UIView` that `self` is/will be a subview of.
     */
    init(superViewFrame: CGRect) {
        super.init(frame: superViewFrame)
        
        let menuWidth: CGFloat
        if UIDevice.current.userInterfaceIdiom == .pad {
            menuWidth = superViewFrame.width * 0.5
        } else {
            let topBarAspectRatio: CGFloat = 2.5 / 0.324
            let topBarHeight = superViewFrame.width / topBarAspectRatio
            let takenAmount = topBarHeight * (0.564 / 0.324)
            menuWidth = superViewFrame.width - takenAmount + 1
        }
        
        leftoverView.frame = superViewFrame
        self.menuFrame = CGRect(x: superViewFrame.width, y: 0, width: menuWidth, height: superViewFrame.height)

        // Set up images displayed by buttons.
        // Note: Images with non-constant displays should be set by controller.
        leaderboardButton.setImage(ImageManager.image(forName: "menu_home"), for: UIControlState())
        leaderboardButton.setImage(ImageManager.image(forName: "menu_home_highlighted"), for: .highlighted)
        
        scoresButton.setImage(ImageManager.image(forName: "menu_scores"), for: UIControlState())
        scoresButton.setImage(ImageManager.image(forName: "menu_scores_highlighted"), for: .highlighted)
        
        marketButton.setImage(ImageManager.image(forName: "menu_store"), for: UIControlState())
        marketButton.setImage(ImageManager.image(forName: "menu_store_highlighted"), for: .highlighted)
        
        tutorialButton.setImage(ImageManager.image(forName: "menu_tutorial"), for: UIControlState())
        tutorialButton.setImage(ImageManager.image(forName: "menu_tutorial_highlighted"), for: .highlighted)
        
        // Set up blur
        purpleView.backgroundColor = UIColor(red: 64.0 / 255.0, green: 40.0 / 255.0, blue: 64.0 / 255.0, alpha: 1.0)
        
        addSubview(leftoverView)
        addSubview(purpleView)
        addSubview(playButton)
        addSubview(leaderboardButton)
        addSubview(scoresButton)
        addSubview(marketButton)
        addSubview(sfxButton)
        addSubview(musicButton)
        addSubview(tutorialButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("MenuView: init(coder:) has not been implemented")
    }
    
    
    // MARK: Layout Guidelines
    
    override func layoutSubviews() {
        
        // CONSTRAINTS
        
        // The number of rows on the view. This view has a row for each of 5 buttons and a row for the music/sfx toggles.
        let numberOfRows: CGFloat = 6
        
        // Aspect ratios for various items on the page.
        let buttonAspectRatio: CGFloat = 996.0 / 223.0
        let toggleAspectRatio: CGFloat = 400.0 / 223.0
        let tutorialAspectRatio: CGFloat = 1395.0 / 190.0
        
        // The amount of the width of the screen (on each side) to reserve for padding.
        let horizontalMargin = menuFrame.width * 0.1
        
        
        // INSTRUCTIONS
        let rowWidth = menuFrame.width - 2 * horizontalMargin
        let rowHeight = rowWidth / buttonAspectRatio
        
        let spaceAvailable = menuFrame.height - TopBarView.topBarHeight - (numberOfRows * rowHeight)
        let spacePerRow = spaceAvailable / (numberOfRows + 1)
        
        playButton.frame = CGRect(x: menuFrame.origin.x + horizontalMargin, y: TopBarView.topBarHeight + spacePerRow, width: rowWidth, height: rowHeight)
        
        scoresButton.frame = playButton.frame
        scoresButton.frame.origin.y += playButton.frame.height + spacePerRow
        
        leaderboardButton.frame = scoresButton.frame
        leaderboardButton.frame.origin.y += scoresButton.frame.height + spacePerRow
        
        marketButton.frame = leaderboardButton.frame
        marketButton.frame.origin.y += leaderboardButton.frame.height + spacePerRow
        
        let tutorialButtonHeight = menuFrame.width / tutorialAspectRatio
        tutorialButton.frame = CGRect(x: menuFrame.origin.x, y: menuFrame.height - tutorialButtonHeight, width: menuFrame.width, height: tutorialButtonHeight)
        
        let toggleWidth = rowHeight * toggleAspectRatio
        let toggleMiddlePadding = rowWidth - 2 * toggleWidth
        musicButton.frame = CGRect(x: menuFrame.origin.x + horizontalMargin, y: marketButton.frame.origin.y + marketButton.frame.height + spacePerRow, width: toggleWidth, height: rowHeight)
        sfxButton.frame = musicButton.frame
        sfxButton.frame.origin.x += musicButton.frame.width + toggleMiddlePadding
        
        purpleView.frame.origin.x = menuFrame.origin.x
        purpleView.frame.origin.y = menuFrame.origin.y
        purpleView.frame.size.width = menuFrame.size.width
        purpleView.frame.size.height = menuFrame.size.height
    }
}
