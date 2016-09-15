//
//  MarketView.swift
//  Zlink
//
//  Created by Kennan Mell on 2/14/16.
//  Copyright © 2016 MegaWatt Gaming. All rights reserved.
//

import UIKit

/**
 `MarketView` displays the market page.
 
 - seealso: `MarketController`
 */
class MarketView: UIView {
    
    // MARK: Properties
    
    /** Used to play a reward video. */
    let watchAdButton = UIButton()
    
    /** Used to buy 10 Power-Ups. */
    let powerups10Button = UIButton()
    
    /** Used to buy 50 Power-Ups. */
    let powerups50Button = UIButton()
    
    /** Used to buy 200 Power-Ups. */
    let powerups200Button = UIButton()
    
    /** Displays the number of Power-Ups the player owns. */
    let powerupsInventoryLabel = UILabel()
    
    /** Displays the background behind the pager. */
    let pagerImage = UIImageView(image: ImageManager.imageForName("market_pager_background"))
    
    /** Used to navigate left on the pager. */
    let leftPagerButton = UIButton()
    
    /** Used to navigate right on the pager. */
    let rightPagerButton = UIButton()
    
    /** Displays the current pager screen. */
    let pagerView = UIView()
    
    /** Displays a reward earned. */
    let rewardLabel = UILabel()
    
    
    // MARK: Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        pagerView.addSubview(UIImageView(image: ImageManager.imageForName("market_pager_1")))
        pagerView.addSubview(powerupsInventoryLabel)

        backgroundColor = ImageManager.appBackgroundColor
        
        watchAdButton.setImage(ImageManager.imageForName("market_ad"), forState: .Normal)
        watchAdButton.setImage(ImageManager.imageForName("market_ad_highlighted"), forState: .Highlighted)
        
        powerups10Button.setImage(ImageManager.imageForName("market_powerup_10"), forState: .Normal)
        powerups10Button.setImage(ImageManager.imageForName("market_powerup_10_highlighted"), forState: .Highlighted)
        
        powerups50Button.setImage(ImageManager.imageForName("market_powerup_50"), forState: .Normal)
        powerups50Button.setImage(ImageManager.imageForName("market_powerup_50_highlighted"), forState: .Highlighted)

        powerups200Button.setImage(ImageManager.imageForName("market_powerup_200"), forState: .Normal)
        powerups200Button.setImage(ImageManager.imageForName("market_powerup_200_highlighted"), forState: .Highlighted)
        
        leftPagerButton.setImage(ImageManager.imageForName("market_pager_left"), forState: .Normal)
        rightPagerButton.setImage(ImageManager.imageForName("market_pager_right"), forState: .Normal)
        
        powerupsInventoryLabel.textAlignment = .Center
        powerupsInventoryLabel.textColor = UIColor(red: 199.0 / 255.0, green: 153.0 / 255.0, blue: 71.0 / 255.0, alpha: 1.0)
        
        rewardLabel.backgroundColor = UIColor(white: 64.0 / 255.0, alpha: 1.0)
        rewardLabel.textAlignment = .Center
        rewardLabel.textColor = UIColor(red: 236.0 / 255.0, green: 239.0 / 255.0, blue: 232.0 / 255.0, alpha: 1.0)
        rewardLabel.text = "Reward earned!"
        rewardLabel.adjustsFontSizeToFitWidth = true
        
        addSubview(watchAdButton)
        addSubview(powerups10Button)
        addSubview(powerups50Button)
        addSubview(powerups200Button)
        addSubview(pagerImage)
        addSubview(rewardLabel)
        addSubview(pagerView)
        addSubview(leftPagerButton)
        addSubview(rightPagerButton)
    }
    
    
    // MARK: Layout Guidelines
    
    override func layoutSubviews() {
        
        // CONSTRAINTS
        
        // The number of rows on the page. This page has a row for each of 4 buttons and a row for the info pager.
        let numberOfRows: CGFloat = 5
        
        // Aspect ratios for various items on the page.
        let buttonAspectRatio: CGFloat = 837.0 / 179.0
        let pagerBackgroundAspectRatio: CGFloat = 838.0 / 650.0
        let pagerImageAspectRatio: CGFloat = 838.0 / 651.0
        let pagerArrowAspectRatio: CGFloat = 131.0 / 117.0
        
        // The amount of the width of the screen (on each side) to reserve for padding.
        let horizontalMargin: CGFloat
        // The amount of the height of the screen (on each side, not including the top bar) to reserve for padding.
        let verticalMargin: CGFloat
        // The height / width of the reward message that pops up when the user gets a reward.
        let rewardLabelAspectRatio: CGFloat
        // The unscaled text size of the reward message label.
        let rewardLabelTextSize: CGFloat
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            // iPad
            horizontalMargin = self.frame.width * 0.22
            verticalMargin = self.frame.height * 0.035
            rewardLabelAspectRatio = 6.0 / 1.0
            rewardLabelTextSize = 0.075
        } else if self.frame.height == 480.0 {
            // iPhone 4 or 4s
            horizontalMargin = self.frame.width * 0.2
            verticalMargin = self.frame.height * 0.05
            rewardLabelAspectRatio = 12.0 / 1.0
            rewardLabelTextSize = 0.05
        } else {
            // iPhone 5 and later
            horizontalMargin = self.frame.width * 0.15
            verticalMargin = self.frame.height * 0.07
            rewardLabelAspectRatio = 6.0 / 1.0
            rewardLabelTextSize = 0.075
        }
        
        // The unscaled text size of the inventory label.
        let inventoryLabelTextSize: CGFloat = 0.175

        
        // INSTRUCTIONS
        
        // Lay out all main frames, ignoring for their y-origin for now.
        let itemsWidth = self.frame.width - 2 * horizontalMargin
        
        pagerImage.frame = CGRect(x: horizontalMargin, y: 0, width: itemsWidth, height: itemsWidth / pagerBackgroundAspectRatio)
        
        leftPagerButton.frame = CGRect(x: horizontalMargin + itemsWidth * 0.08, y: 0, width: itemsWidth * 0.15, height: itemsWidth * 0.15 / pagerArrowAspectRatio)
        
        watchAdButton.frame = CGRect(x: horizontalMargin, y: 0, width: itemsWidth, height: itemsWidth / buttonAspectRatio)
        powerups10Button.frame = watchAdButton.frame
        powerups50Button.frame = watchAdButton.frame
        powerups200Button.frame = watchAdButton.frame
        
        // Determine the y-origin of each item and update that value accordingly for each item.
        let verticalSpaceAvailable = self.frame.height - pagerImage.frame.height - watchAdButton.frame.height - powerups10Button.frame.height - powerups50Button.frame.height - powerups200Button.frame.height - 3 * verticalMargin - TopBarView.topBarHeight
        
        let verticalSpacePerItem = verticalSpaceAvailable / (numberOfRows - 2)
        
        pagerImage.frame.origin.y = TopBarView.topBarHeight + verticalMargin
        leftPagerButton.frame.origin.y = pagerImage.frame.origin.y + pagerImage.frame.height * 0.085
        rightPagerButton.frame = leftPagerButton.frame
        rightPagerButton.frame.origin.x = pagerImage.frame.origin.x + pagerImage.frame.width - itemsWidth * 0.08 - rightPagerButton.frame.width
        watchAdButton.frame.origin.y = pagerImage.frame.origin.y + pagerImage.frame.height + verticalMargin
        powerups10Button.frame.origin.y = watchAdButton.frame.origin.y + watchAdButton.frame.height + verticalSpacePerItem
        powerups50Button.frame.origin.y = powerups10Button.frame.origin.y + powerups10Button.frame.height + verticalSpacePerItem
        powerups200Button.frame.origin.y = powerups50Button.frame.origin.y + powerups50Button.frame.height + verticalSpacePerItem
        
        // Update frames for helper items like text boxes and scroll/page views.
        powerupsInventoryLabel.font = UIFont(name: "Dosis-SemiBold", size: pagerImage.frame.width * inventoryLabelTextSize)
        
        rewardLabel.frame = CGRect(x: 0, y: self.frame.height + 1, width: self.frame.width, height: self.frame.width / rewardLabelAspectRatio)
        rewardLabel.font = UIFont(name: "Dosis-SemiBold", size: rewardLabel.frame.width * rewardLabelTextSize)
        
        let pagerImageHeight = pagerImage.frame.width * 0.9 / pagerImageAspectRatio
        pagerView.frame = CGRect(x: pagerImage.frame.origin.x + pagerImage.frame.width * 0.05, y: pagerImage.frame.origin.y + pagerImage.frame.height * 0.05, width: pagerImage.frame.width * 0.9, height: pagerImageHeight)
        pagerView.subviews[0].frame = CGRect(x: 0, y: 0, width: pagerView.frame.width, height: pagerView.frame.height)
        powerupsInventoryLabel.frame = CGRect(x: 0, y: pagerView.frame.height * 0.025, width: pagerView.frame.width, height: pagerView.frame.height)
    }
    
}