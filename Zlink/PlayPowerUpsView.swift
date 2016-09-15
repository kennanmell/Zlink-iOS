//
//  PlayPowerUpsView.swift
//  Zlink
//
//  Created by Kennan Mell on 2/17/16.
//  Copyright © 2016 MegaWatt Gaming. All rights reserved.
//

import UIKit

/**
 `PlayPowerUpsView` displays the power-ups slider.
 
 - seealso: `PlayView`, `PlayController`
 */
class PlayPowerUpsView: UIView {
    
    // MARK: Properties
    
    /** Displays background of the power-ups slider. This is a `UIButton` rather than just a `UIImageView` to prevent `self` from being hidden when the user taps it. */
    let backgroundButton = UIButton()
    
    /** Displays the number of Power-Ups the player owns. */
    let inventoryLabel = UILabel()
    
    /** Used to activate a magic wand Power-Up. */
    let magicWandButton = UIButton()
    
    /** Used to activate a board repair Power-Up. */
    let boardRepairButton = UIButton()
    
    /** Used to activate a shuffle Power-Up. */
    let shuffleButton = UIButton()
    
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    /** Shared initializer. */
    private func initialize() {
        backgroundButton.setImage(ImageManager.imageForName("powerup_background"), forState: .Normal)
        backgroundButton.adjustsImageWhenHighlighted = false
        
        inventoryLabel.text = "0"
        inventoryLabel.textAlignment = .Center
        inventoryLabel.textColor = UIColor(red: 255.0 / 255.0, green: 210.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)

        magicWandButton.setImage(ImageManager.imageForName("powerup_magic_tile"), forState: .Normal)
        magicWandButton.setImage(ImageManager.imageForName("powerup_magic_tile_highlighted"), forState: .Highlighted)
        
        boardRepairButton.setImage(ImageManager.imageForName("powerup_tile_repair"), forState: .Normal)
        boardRepairButton.setImage(ImageManager.imageForName("powerup_tile_repair_highlighted"), forState: .Highlighted)
        
        shuffleButton.setImage(ImageManager.imageForName("powerup_shuffle"), forState: .Normal)
        shuffleButton.setImage(ImageManager.imageForName("powerup_shuffle_highlighted"), forState: .Highlighted)
        
        addSubview(backgroundButton)
        addSubview(inventoryLabel)
        addSubview(magicWandButton)
        addSubview(boardRepairButton)
        addSubview(shuffleButton)
    }
    
    
    // MARK: Layout Guidelines
    
    override func layoutSubviews() {
        
        // CONSTRAINTS

        // The number of powerup buttons
        let numberOfButtons: CGFloat = 3
        
        // Aspect ratios of various items on the page.
        let buttonAspectRatio: CGFloat = 127.0 / 99.0
        
        // The amount of the height of the view to use as padding between the top of the view and the top of the buttons.
        let topMargin = self.frame.height * 0.27
        
        // The amount of the width of the view (on each side)that should be used as a margin for the buttons.
        let horizontalMargin = self.frame.width * 0.10
        
        // The amount of the width of the view that each button's width should be.
        let buttonWidth = self.frame.width * 0.12
        
        
        // INSTRUCTIONS

        backgroundButton.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
                
        inventoryLabel.font = UIFont(name: "Dosis-SemiBold", size: self.frame.width / 15)
        inventoryLabel.frame = CGRect(x: 0, y: backgroundButton.frame.origin.y, width: self.frame.width, height: self.frame.width / 10)
        
        let horizontalSpaceAvailable = self.frame.width - 2 * horizontalMargin - buttonWidth * numberOfButtons
        let horizontalSpacePerItem = horizontalSpaceAvailable / (numberOfButtons - 1)
        
        magicWandButton.frame = CGRect(x: horizontalMargin, y: topMargin, width: buttonWidth, height: buttonWidth / buttonAspectRatio)
        
        shuffleButton.frame = CGRect(x: magicWandButton.frame.origin.x + magicWandButton.frame.width + horizontalSpacePerItem, y: topMargin, width: buttonWidth, height: buttonWidth / buttonAspectRatio)
        
        boardRepairButton.frame = CGRect(x: shuffleButton.frame.origin.x + shuffleButton.frame.width + horizontalSpacePerItem, y: topMargin, width: buttonWidth, height: buttonWidth / buttonAspectRatio)
    }
    
}