//
//  TopBarView.swift
//  Zlink
//
//  Created by Kennan Mell on 2/14/16.
//  Copyright © 2016 MegaWatt Gaming. All rights reserved.
//

import UIKit

// Note: This class is defined to be part of `MainController` by Main.storyboard.

/**
 `TopBarView` displays the top bar on the top of every page.
 
 - seealso: `MainController`
 */
class TopBarView: UIView {
    
    // MARK: Properties
    
    /** The height of the visible top bar. */
    static var topBarHeight: CGFloat {
        return UIScreen.main.bounds.width / (2.5 / 0.324)
    }
        
    /** Displays the Zlink logo. */
    let backgroundImage = UIImageView(image: ImageManager.image(forName: "topbar_background"))
    
    /** Displays the name of the current page. */
    let titleLabel = UILabel()
    
    /** Used to toggle the side menu. */
    let menuButton = UIButton()
    
    /** Used to navigate to the home page. */
    let homeButton = UIButton()
    
    
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
        menuButton.setImage(ImageManager.image(forName: "topbar_menu"), for: UIControlState())
        menuButton.setImage(ImageManager.image(forName: "topbar_menu_selected"), for: .highlighted)
        
        homeButton.setImage(ImageManager.image(forName: "topbar_zlink"), for: UIControlState())
        homeButton.setImage(ImageManager.image(forName: "topbar_zlink_excited"), for: .highlighted)
        
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor(red: 244.0 / 255.0, green: 246.0 / 255.0, blue: 239.0 / 255.0, alpha: 1.0)
        
        addSubview(backgroundImage)
        addSubview(menuButton)
        addSubview(homeButton)
        addSubview(titleLabel)
    }
    
    
    // MARK: Layout Guidelines
    
    override func layoutSubviews() {
        
        // CONSTRAINTS
        
        // Aspect ratios for various items on the view.
        let backgroundImageAspectRatio: CGFloat = 2.5 / 0.324
        let buttonAspectRatio: CGFloat = 0.564 / 0.324
        
        
        // INSTRUCTIONS
        
        backgroundImage.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.width / backgroundImageAspectRatio)
        
        homeButton.frame = CGRect(x: 0, y: 0, width: backgroundImage.frame.height * buttonAspectRatio, height: backgroundImage.frame.height)
        
        menuButton.frame = homeButton.frame
        menuButton.frame.origin.x = self.frame.width - menuButton.frame.width
        
        titleLabel.frame = backgroundImage.frame
        titleLabel.font = UIFont(name: "Dosis-Semibold", size: backgroundImage.frame.height / 1.25)

        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width, height: TopBarView.topBarHeight)
    }
    
}
