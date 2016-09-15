//
//  AlertView.swift
//  Zlink
//
//  Created by Kennan Mell on 3/22/16.
//  Copyright © 2016 MegaWatt Gaming. All rights reserved.
//

import UIKit
 
/**
 `AlertView` displays alerts.
 
 - seealso: `MainController`
 */
class AlertView: UIView {
    
    // MARK: Properties
    
    /** The background behind an alert. This is a `UIButton` rather than just a `UIView` to prevent `self` from being dismissed when the user taps it. */
    let backgroundButton = UIButton()
    
    /** Used to activate an action on an alert then close an alert (if necessary). */
    let topButton = UIButton()
    
    /** Used to activate an action on an alert then close an alert (if necessary). */
    var bottomButton = UIButton()
    
    /** Displays the title of the alert. */
    let titleLabel = UILabel()
    
    /** Displays the message of the alert. */
    let messageLabel = UILabel()
    
    /** The intended `self.frame.width / self.frame.height`. Should be set to a value that properly encloses all text; the `messageLabel` frame will fill any empty space. */
    var aspectRatio: CGFloat = 1.0 {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
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
        backgroundButton.adjustsImageWhenHighlighted = false
                
        // Set up appearence.
        self.backgroundColor = UIColor(white: 0.2, alpha: 0.5)
        backgroundButton.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            // iPad
            backgroundButton.layer.cornerRadius = 10
        } else {
            // iPhone
            backgroundButton.layer.cornerRadius = 7.5
        }
        backgroundButton.layer.masksToBounds = true
        addSubview(backgroundButton)
        
        titleLabel.textAlignment = .Center
        titleLabel.textColor = UIColor(white: 39.0 / 255.0, alpha: 1.0)
        titleLabel.adjustsFontSizeToFitWidth = true
        
        messageLabel.textAlignment = .Center
        messageLabel.textColor = UIColor(white: 39.0 / 255.0, alpha: 1.0)
        messageLabel.lineBreakMode = .ByWordWrapping
        messageLabel.numberOfLines = 0
        
        addSubview(titleLabel)
        addSubview(messageLabel)
        addSubview(topButton)
        addSubview(bottomButton)
    }
    
    override func layoutSubviews() {
        let buttonsAspectRatio: CGFloat = 1.672 / 0.4
        
        let blurViewHorizontalMargin: CGFloat
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            // iPad
            blurViewHorizontalMargin = self.frame.width * 0.25
        } else {
            // iPhone
            blurViewHorizontalMargin = self.frame.width * 0.15
        }
        let blurViewWidth = self.frame.width - 2 * blurViewHorizontalMargin
        let blurViewHeight = blurViewWidth / aspectRatio
        backgroundButton.frame = CGRect(x: blurViewHorizontalMargin, y: self.frame.height / 2 - blurViewHeight / 2, width: self.frame.width - blurViewHorizontalMargin * 2, height: blurViewHeight)
        
        let buttonsVerticalPadding = backgroundButton.frame.height * 0.05
        let buttonsHorizontalMargin = backgroundButton.frame.width * 0.1
        let buttonsWidth = backgroundButton.frame.width - 2 * buttonsHorizontalMargin
        let buttonsHeight = buttonsWidth / buttonsAspectRatio
        if bottomButton.currentImage != nil {
            bottomButton.frame = CGRect(x: backgroundButton.frame.origin.x + buttonsHorizontalMargin, y: backgroundButton.frame.origin.y + backgroundButton.frame.height - buttonsVerticalPadding - buttonsHeight, width: buttonsWidth, height: buttonsHeight)
            
            topButton.frame = bottomButton.frame
            topButton.frame.origin.y -= bottomButton.frame.height + buttonsVerticalPadding
        } else if topButton.currentImage != nil {
            topButton.frame = CGRect(x: backgroundButton.frame.origin.x + buttonsHorizontalMargin, y: backgroundButton.frame.origin.y + backgroundButton.frame.height - buttonsVerticalPadding - buttonsHeight, width: buttonsWidth, height: buttonsHeight)
        }
        
        titleLabel.frame = CGRect(x: backgroundButton.frame.origin.x, y: backgroundButton.frame.origin.y + backgroundButton.frame.height * 0.015, width: backgroundButton.frame.width, height: buttonsHeight)
        titleLabel.font = UIFont(name: "Dosis-Bold", size: backgroundButton.frame.width / 9)
        
        let infoYOrigin = titleLabel.frame.origin.y + backgroundButton.frame.height * 0.02
        if topButton.currentImage != nil {
            messageLabel.frame = CGRect(x: topButton.frame.origin.x, y: infoYOrigin, width: topButton.frame.width, height: topButton.frame.origin.y - infoYOrigin + backgroundButton.frame.height * 0.1)
        } else {
            messageLabel.frame = CGRect(x: backgroundButton.frame.origin.x + buttonsHorizontalMargin, y: infoYOrigin, width: buttonsWidth, height: bottomButton.frame.origin.y - infoYOrigin + bottomButton.frame.height / 2)
        }
        messageLabel.font = UIFont(name: "Dosis", size: backgroundButton.frame.width / 16)
    }
}