//
//  TutorialSceneView.swift
//  Zlink
//
//  Created by Kennan Mell on 3/4/16.
//  Copyright © 2016 MegaWatt Gaming. All rights reserved.
//

import UIKit

/**
 `TutorialSceneView` displays one animated sub-page of the tutorial page.
 
 - seealso: `TutorialController`
 */
class TutorialSceneView: UIView {
    
    // MARK: Properties
    
    /** Used to show the board the tutorial finger animates. */
    let boardView = BoardView(length: TutorialController.boardLength)
    
    /** Displays the top text of the tutorial sub-page. */
    let topTextLabel = UILabel()
    
    /** Displays the bottom text of the tutorial sub-page. */
    let bottomTextLabel = UILabel()
    
    /** Displays the finger that moves around on the page. */
    let fingerImage = UIImageView(image: ImageManager.image(forName: "tutorial_finger"))
    
    
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
        topTextLabel.adjustsFontSizeToFitWidth = true
        topTextLabel.numberOfLines = 0
        topTextLabel.textAlignment = .center
        
        bottomTextLabel.lineBreakMode = .byWordWrapping
        bottomTextLabel.adjustsFontSizeToFitWidth = true
        bottomTextLabel.numberOfLines = 0
        bottomTextLabel.textAlignment = .center
        bottomTextLabel.alpha = 0.0
        
        for tileImage in boardView.tileButtonArray {
            tileImage.isUserInteractionEnabled = false
        }

        addSubview(boardView)
        addSubview(topTextLabel)
        addSubview(bottomTextLabel)
        addSubview(fingerImage)
    }
    
    
    // MARK: Layout Guidelines
    
    override func layoutSubviews() {
        
        // CONSTRAINTS
        
        // Aspect ratios for various items on the page.
        let fingerAspectRatio: CGFloat = 253.0 / 700.0

        // The length (or width) of the board view.
        let boardViewDimension: CGFloat
        // The size of the text for the top and bottom labels.
        let textSize: CGFloat
        if UIDevice.current.userInterfaceIdiom == .pad {
            // iPad
            boardViewDimension = self.frame.width * 0.67
            textSize = self.frame.width / 18
        } else if self.frame.height == 480.0 {
            // iPhone 4 or 4s
            boardViewDimension = self.frame.width * 0.8
            textSize = self.frame.width / 16
        } else {
            // iPhone 5 and later
            boardViewDimension = self.frame.width * 0.95
            textSize = self.frame.width / 14
        }
        
        // INSTRUCTIONS
        
        boardView.frame = CGRect(x: self.frame.width / 2 - boardViewDimension / 2, y: self.frame.height / 2 - boardViewDimension / 2, width: boardViewDimension, height: boardViewDimension)
        
        let topSpaceToFill = boardView.frame.origin.y - TopBarView.topBarHeight
        topTextLabel.frame = CGRect(x: boardView.frame.origin.x, y: 0, width: boardView.frame.width, height: self.frame.width / 3.5)
        topTextLabel.frame.origin.y = TopBarView.topBarHeight + topSpaceToFill / 2 - topTextLabel.frame.height / 2
        topTextLabel.font = UIFont(name: "Dosis", size: textSize)
        
        bottomTextLabel.frame = CGRect(x: boardView.frame.origin.x, y: 0, width: boardView.frame.width, height: self.frame.width / 3.5)
        bottomTextLabel.frame.origin.y = boardView.frame.origin.y + boardView.frame.height
        bottomTextLabel.font = UIFont(name: "Dosis", size: textSize)
        
        let fingerWidth = boardView.tileButtonArray[0].frame.width * 0.8
        fingerImage.frame = CGRect(x: boardView.frame.origin.x + boardView.tileButtonArray[0].frame.origin.x + boardView.tileButtonArray[0].frame.width / 2 - fingerWidth / 2, y: boardView.frame.origin.y + boardView.tileButtonArray[0].frame.origin.y + boardView.tileButtonArray[0].frame.height / 2, width: fingerWidth, height: fingerWidth / fingerAspectRatio)
    }
}
