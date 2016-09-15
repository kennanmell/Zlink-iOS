//
//  TutorialScene5View.swift
//  Zlink
//
//  Created by Kennan Mell on 3/10/16.
//  Copyright © 2016 MegaWatt Gaming. All rights reserved.
//

import UIKit

/**
 `TutorialScene5View` displays the last sub-page of the tutorial.
 
 - seealso: `TutorialController`
 */
class TutorialScene5View: UIView {
    
    // MARK: Properties
    
    /** Displays the text prompting the user to play. */
    let textLabel = UILabel()
    
    /** Used to navigate to the play page. */
    let playButton = UIButton()
    
    
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
        backgroundColor = ImageManager.appBackgroundColor
        
        textLabel.lineBreakMode = .ByWordWrapping
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .Center
        textLabel.text = "How many Zlinks can you link?"
        
        addSubview(textLabel)
        addSubview(playButton)
    }
    
    
    // MARK: Layout Guidelines
    
    override func layoutSubviews() {
        
        // CONSTRAINTS
        
        // Aspect ratios for various items on the page.
        let playButtonAspectRatio: CGFloat = 1.672 / 0.4

        // The amount of the width of the screen (on each side) to reserve for padding.
        let horizontalMargin = self.frame.width * 0.18
        
        // INSTRUCTIONS
        
        let playButtonWidth = self.frame.width - horizontalMargin * 2
        playButton.frame = CGRect(x: horizontalMargin, y: self.frame.height / 2 + TopBarView.topBarHeight, width: playButtonWidth, height: playButtonWidth / playButtonAspectRatio)
        
        textLabel.frame = CGRect(x: horizontalMargin, y: TopBarView.topBarHeight, width: self.frame.width - 2 * horizontalMargin, height: playButton.frame.origin.y - TopBarView.topBarHeight)
        textLabel.font = UIFont(name: "Dosis", size: self.frame.width / 12)
    }
}