//
//  BoardView.swift
//  Zlink
//
//  Created by Kennan Mell on 1/25/16.
//  Copyright © 2016 MegaWatt Gaming. All rights reserved.
//

import UIKit

/**
 `BoardView` displays a board.
 
 - seealso: `BoardController`
 */
class BoardView: UIView {
    
    // MARK: Properties
    
    /** The `UIButton`s representing `Tile`s on `self`. */
    private(set) var tileButtonArray = Array<UIButton>()
    
    /** The UIButtons representing the background of `Tile`s on `self`. */
    private(set) var backgroundTileButtonArray = Array<UIButton>()
    
    /** The number of subviews representing `Board` tiles that should appear in one row (or column) or `self`. */
    let tilesPerRow: Int
    
    /** View to hold and display `backgroundImage()`. */
    private let backgroundImage = UIImageView(image: ImageManager.imageForName("board_background"))
    
    
    // MARK: Initialization
    
    /**
     Sole initializer.
     - parameters:
        - length: The length of the board to represent. (Number of tiles in a row or column of the board.)
     */
    init(length: Int) {
        if length < 1 {
            fatalError("Length must be positive.")
        }
        tilesPerRow = length
        
        // Initialize with placeholder frame.
        super.init(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        
        // Prepare background image.
        addSubview(backgroundImage)
        
        for _ in 0..<(tilesPerRow * tilesPerRow) {
            // Prepare background tile views.
            let backgroundButton = UIButton()
            backgroundButton.adjustsImageWhenHighlighted = false
            backgroundTileButtonArray.append(backgroundButton)
            
            // Prepare tile views.
            let button = UIButton()
            tileButtonArray.append(button)
            
            addSubview(backgroundButton)
            addSubview(button)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Functions
    
    override func layoutSubviews() {
        
        // Spacing between the start of the view and the start of its tileviews.
        let sideSpacing = frame.size.width * 0.028
        // Scaled tile and spacing size based on frame width.
        let scaledTileWithSpacing = (frame.size.width - (2 * sideSpacing)) / CGFloat(tilesPerRow)
        // Scaled tile spacing size based on frame width.
        let scaledTileSpacing = scaledTileWithSpacing * 0.05
        // Scaled tile length (and width) based on frame width.
        let scaledTileLength = scaledTileWithSpacing - scaledTileSpacing
        // Frame used to lay out tile views. Updated in `for` loop below.
        var tileFrame = CGRect(x: 0, y: 0, width: scaledTileLength, height: scaledTileLength)
        
        
        // Lay out background image.
        backgroundImage.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.width)
        
        // Lay out tile views and background tile views.
        for i in 0..<tileButtonArray.count {
            // Offset frame origin by the length of the button plus spacing.
            tileFrame.origin.x = CGFloat(i % tilesPerRow) * scaledTileWithSpacing + sideSpacing + (scaledTileSpacing / 2)
            tileFrame.origin.y = CGFloat(i / tilesPerRow) * scaledTileWithSpacing + sideSpacing + (scaledTileSpacing / 2)
            
            tileButtonArray[i].frame = tileFrame
            backgroundTileButtonArray[i].frame = tileFrame
            
        }
    }
}