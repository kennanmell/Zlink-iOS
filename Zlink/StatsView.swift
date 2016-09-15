//
//  StatsView.swift
//  Zlink
//
//  Created by Kennan Mell on 2/16/16.
//  Copyright © 2016 MegaWatt Gaming. All rights reserved.
//

import UIKit

/**
 `StatsView` displays the stats page.
 
 - seealso: `StatsController`
 */
class StatsView: UIView {
    
    // MARK: Properties
    
    /** Background of the Zlinks linked stat. */
    private let zlinksLinkedImage = UIImageView(image: ImageManager.imageForName("scores_zlinks_linked"))
    
    /** Displays the Zlinks linked stat. */
    let zlinksLinkedLabel = UILabel()
    
    /** Background of the games played stat. */
    private let gamesPlayedImage = UIImageView(image: ImageManager.imageForName("scores_games_played"))
    
    /** Displays the games played stat. */
    let gamesPlayedLabel = UILabel()
    
    /** Used to reset all game data. */
    let resetDataButton = UIButton()
    
    /** Used to share the Stats page. */
    let shareButton = UIButton()
    
    /** Used to display the user's highest scores. Should be initialized with the number of scores it needs to display. */
    private let statsScrollView = StatsScrollView(numberOfScores: SavedData.stats.count)
    
    /** Background of the high scores scroller. */
    private let highScoresImage = UIImageView(image: ImageManager.imageForName("scores_high_scores_background"))
    
    /** Its contents are the backgrounds behind the player's high scores (ordered from highest to lowest score). */
    var highScoreImagesArray: Array<UIButton> {
        return statsScrollView.highScoreImagesArray
    }
    
    /** Its contents are the labels of the player's high scores (ordered from highest to lowest). */
    var highScoreLabelsArray: Array<UILabel> {
        return statsScrollView.highScoreLabelsArray
    }
    
    
    // MARK: Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = ImageManager.appBackgroundColor
        
        resetDataButton.setImage(ImageManager.imageForName("scores_reset"), forState: .Normal)
        resetDataButton.setImage(ImageManager.imageForName("scores_reset_highlighted"), forState: .Highlighted)
        shareButton.setImage(ImageManager.imageForName("scores_share"), forState: .Normal)
        shareButton.setImage(ImageManager.imageForName("scores_share_highlighted"), forState: .Highlighted)
        
        zlinksLinkedLabel.text = "000"
        gamesPlayedLabel.text = "000"
        zlinksLinkedLabel.textAlignment = .Center
        gamesPlayedLabel.textAlignment = .Center
        zlinksLinkedLabel.textColor = UIColor(red: 229.0 / 255.0, green: 231.0 / 255.0, blue: 224.0 / 255.0, alpha: 1.0)
        gamesPlayedLabel.textColor = UIColor(red: 229.0 / 255.0, green: 231.0 / 255.0, blue: 224.0 / 255.0, alpha: 1.0)
        
        addSubview(highScoresImage)
        addSubview(statsScrollView)
        addSubview(gamesPlayedImage)
        addSubview(zlinksLinkedImage)
        addSubview(resetDataButton)
        addSubview(shareButton)
        addSubview(zlinksLinkedLabel)
        addSubview(gamesPlayedLabel)
    }
    
    
    // MARK: Layout Guidelines
    
    override func layoutSubviews() {
        
        // CONSTRAINTS
        
        // The number of rows on the page. This page has a row for the high scores background, a unique row for each of the two stats (games played and zlinks linked) and a row for the buttons (game center and share).
        let numberOfRows: CGFloat = 4
        
        // Aspect ratios for various items on the page.
        let buttonAspectRatio: CGFloat = 301.0 / 184.0
        let statImageAspectRatio: CGFloat = 752.0 / 154.0
        let highScoresImageAspectRatio: CGFloat = 1.5 / 2.196
        
        // The amount of the width of the screen (on each side) to reserve for padding.
        let horizontalMargin: CGFloat
        // The amount of the height of the screen (on each side, not including the top bar) to reserve for padding.
        let verticalMargin: CGFloat
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            // iPad
            horizontalMargin = self.frame.width * 0.25
            verticalMargin = self.frame.height * 0.02
        } else if self.frame.height == 480.0 {
            // iPhone 4 or 4s
            horizontalMargin = self.frame.width * 0.215
            verticalMargin = self.frame.height * 0.02
        } else {
            // iPhone 5 and later
            horizontalMargin = self.frame.width * 0.185
            verticalMargin = self.frame.height * 0.035
        }
        
        // The amount of the width of the screen to use as padding between buttons on the same row of the page.
        let buttonMiddleMargin = (self.frame.width - 2 * horizontalMargin) / 4
        
        // The unscaled text size of the stats on the page (zlinks linked and games played)
        let labelTextSize: CGFloat = 0.5
                
        
        // INSTRUCTIONS
        
        // Lay out all main frames, ignoring for their y-origin for now.
        let highScoresBackgroundWidth = self.frame.width - 2 * horizontalMargin
        highScoresImage.frame = CGRect(x: horizontalMargin, y: 0, width: highScoresBackgroundWidth, height: highScoresBackgroundWidth / highScoresImageAspectRatio)
        
        let statBackgroundWidth = self.frame.width - 2 * horizontalMargin
        gamesPlayedImage.frame = CGRect(x: horizontalMargin, y: 0, width: statBackgroundWidth, height: statBackgroundWidth / statImageAspectRatio)
        zlinksLinkedImage.frame = CGRect(x: horizontalMargin, y: 0, width: statBackgroundWidth, height: statBackgroundWidth / statImageAspectRatio)
        
        let buttonWidth = (self.frame.width - 2 * horizontalMargin - buttonMiddleMargin) / 2
        resetDataButton.frame = CGRect(x: horizontalMargin, y: 0, width: buttonWidth, height: buttonWidth / buttonAspectRatio)
        shareButton.frame = CGRect(x: resetDataButton.frame.origin.x + resetDataButton.frame.width + buttonMiddleMargin, y: 0, width: buttonWidth, height: buttonWidth / buttonAspectRatio)
        
        // Determine the y-origin of each item and update that value accordingly for each item.
        let verticalSpaceAvailable = self.frame.height - highScoresImage.frame.height - gamesPlayedImage.frame.height - zlinksLinkedImage.frame.height - resetDataButton.frame.height - 2 * verticalMargin - TopBarView.topBarHeight
        
        let verticalSpacePerItem = verticalSpaceAvailable / (numberOfRows - 1)
        
        highScoresImage.frame.origin.y = TopBarView.topBarHeight + verticalMargin
        gamesPlayedImage.frame.origin.y = highScoresImage.frame.origin.y + highScoresImage.frame.height + verticalSpacePerItem
        zlinksLinkedImage.frame.origin.y = gamesPlayedImage.frame.origin.y + gamesPlayedImage.frame.height + verticalSpacePerItem
        resetDataButton.frame.origin.y = zlinksLinkedImage.frame.origin.y + zlinksLinkedImage.frame.height + verticalSpacePerItem
        shareButton.frame.origin.y = resetDataButton.frame.origin.y
        
        // Update frames for helper items like text boxes and scroll/page views.
        zlinksLinkedLabel.frame = CGRect(x: zlinksLinkedImage.frame.origin.x + zlinksLinkedImage.frame.width / 1.75, y: zlinksLinkedImage.frame.origin.y, width: zlinksLinkedImage.frame.width / 2, height: zlinksLinkedImage.frame.height)
        zlinksLinkedLabel.font = UIFont(name: "Dosis-Bold", size: zlinksLinkedLabel.frame.height * labelTextSize)
        
        gamesPlayedLabel.frame = CGRect(x: gamesPlayedImage.frame.origin.x + gamesPlayedImage.frame.width / 1.75, y: gamesPlayedImage.frame.origin.y, width: gamesPlayedImage.frame.width / 2, height: gamesPlayedImage.frame.height)
        gamesPlayedLabel.font = UIFont(name: "Dosis-Bold", size: gamesPlayedLabel.frame.height * labelTextSize)
        
        let scrollViewHorizontalPadding = highScoresImage.frame.width * 0.025
        let scrollViewTopPadding = highScoresImage.frame.height * 0.33
        let scrollViewWidth = highScoresImage.frame.width - scrollViewHorizontalPadding * 2
        let scrollViewHeight = highScoresImage.frame.height - scrollViewTopPadding - highScoresImage.frame.height * 0.035
        statsScrollView.frame = CGRect(x: highScoresImage.frame.origin.x + scrollViewHorizontalPadding, y: highScoresImage.frame.origin.y + scrollViewTopPadding, width: scrollViewWidth, height: scrollViewHeight)
    }
    
}

/**
 `StatsScrollView` displays the user's best scores in a scroll view.
 */
private class StatsScrollView: UIScrollView {
    
    // MARK: Properties
    
    /** Its contents are the labels of the player's high scores (ordered from highest to lowest). */
    var highScoreLabelsArray = Array<UILabel>()
    
    /** Its contents are the backgrounds behind the player's high scores (ordered from highest to lowest score). */
    var highScoreImagesArray = Array<UIButton>()
    
    
    // MARK: Initialization
    
    /**
     Sole initializer.
     - parameters:
        - numberOfScores: The number of scores `self` will need to display in its scroll view.
     */
    init(numberOfScores: Int) {
        // Placeholder frame.
        super.init(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        
        self.indicatorStyle = .White
        
        // Add all the new high scores.
        for _ in 0..<numberOfScores {
            let button = UIButton()
            button.adjustsImageWhenHighlighted = false
            button.setImage(ImageManager.imageForName("scores_score_background"), forState: .Normal)
            highScoreImagesArray.append(button)
            addSubview(button)
            
            let label = UILabel()
            label.textColor = UIColor(white: 39.0 / 255.0, alpha: 1.0)
            label.textAlignment = .Center
            highScoreLabelsArray.append(label)
            addSubview(label)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Layout Guidelines
    
    override func layoutSubviews() {
        
        // CONSTRAINTS
        
        // The aspect ratio of all items in the scroll view.
        let itemsAspectRatio: CGFloat = 1.242 / 0.22
        // The amount of the width of the view (on each side) to reserve for padding.
        let horizontalMargin = self.frame.width * 0.05
        // The amount of the view to reserve for padding below each item in the view.
        let verticalMargin: CGFloat = self.frame.height * 0.03
        // The unscaled text size of any text in the subviews of `self`.
        let textSize: CGFloat = 0.125
        
        
        // INSTRUCTIONS
        
        let itemsWidth = self.frame.width - 2 * horizontalMargin
        let itemsHeight: CGFloat = itemsWidth / itemsAspectRatio
        
        var runningY: CGFloat = 0
        for i in 0..<highScoreLabelsArray.count {
            let score = highScoreLabelsArray[i]
            score.frame = CGRect(x: horizontalMargin, y: runningY, width: itemsWidth, height: itemsHeight)
            score.font = UIFont(name: "Dosis-Semibold", size: self.frame.height * textSize)
            
            highScoreImagesArray[i].frame = score.frame
            
            score.frame.origin.y += score.frame.height * 0.06
            
            runningY += itemsHeight + verticalMargin
        }
        
        self.contentSize = CGSize(width: self.frame.width, height: runningY)
    }
        
}