//
//  TutorialScene1View.swift
//  Zlink
//
//  Created by Kennan Mell on 3/10/16.
//  Copyright © 2016 MegaWatt Gaming. All rights reserved.
//

import UIKit

/**
 `TutorialScene1View` displays the first sub-page of the tutorial.
 
 - seealso: `TutorialController`
 */
class TutorialScene1View: UIView {
    
    // MARK: Properties
    
    /** Displays the top text introducing Zlinks. */
    let topTextLabel = UILabel()
    
    /** Displays the bottom text introducing Zlinks. */
    let bottomTextLabel = UILabel()
    
    /** Displays the image introducing Zlinks. */
    let zlinksImage = UIImageView(image: ImageManager.image(forName: "tutorial_zlinks_image"))

    
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
    fileprivate func initialize() {
        backgroundColor = ImageManager.appBackgroundColor
        
        topTextLabel.lineBreakMode = .byWordWrapping
        topTextLabel.numberOfLines = 0
        topTextLabel.textAlignment = .center
        topTextLabel.text = "These are Zlinks..."
        bottomTextLabel.lineBreakMode = .byWordWrapping
        bottomTextLabel.numberOfLines = 0
        bottomTextLabel.textAlignment = .center
        bottomTextLabel.text = "Your job is to make gold paths linking them!"
        
        addSubview(topTextLabel)
        addSubview(bottomTextLabel)
        addSubview(zlinksImage)
    }
    
    
    // MARK: Layout Guidelines
    
    override func layoutSubviews() {
        
        // CONSTRAINTS
        
        // Aspect ratios for various items on the page.
        let zlinksImageAspectRatio: CGFloat = 813.0 / 437.0
        
        // The amount of the width of the screen (on each side) to reserve for padding.
        let horizontalMargin = self.frame.width * 0.1
        
        // INSTRUCTIONS
        
        let zlinksImageWidth = self.frame.width - 2 * horizontalMargin
        let zlinksImageHeight = zlinksImageWidth / zlinksImageAspectRatio
        zlinksImage.frame = CGRect(x: horizontalMargin, y: TopBarView.topBarHeight + self.frame.height / 2 - zlinksImageHeight / 2 - self.frame.height / 8, width: zlinksImageWidth, height: zlinksImageHeight)
        
        topTextLabel.frame = CGRect(x: horizontalMargin, y: TopBarView.topBarHeight, width: self.frame.width - horizontalMargin * 2, height: zlinksImage.frame.origin.y - TopBarView.topBarHeight)
        topTextLabel.font = UIFont(name: "Dosis", size: self.frame.width / 12)
        
        bottomTextLabel.frame = CGRect(x: horizontalMargin, y: zlinksImage.frame.origin.y + zlinksImage.frame.height - self.frame.height / 15, width: self.frame.width - 2 * horizontalMargin, height: self.frame.height - (zlinksImage.frame.origin.y + zlinksImage.frame.height))
        bottomTextLabel.font = UIFont(name: "Dosis", size: self.frame.width / 12)
    }
}
