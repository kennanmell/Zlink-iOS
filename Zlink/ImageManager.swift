//
//  ImageManager.swift
//  Zlink
//
//  Created by Kennan Mell on 2/4/16.
//  Copyright © 2016 MegaWatt Gaming. All rights reserved.
//

import Foundation
import UIKit

/** 
`ImageManager`'s primary purpose is to optimize memory usage by ensuring that no two `UIImage`s in memory ever have the same name. This invariant only holds if all `UIImage`s used within the application are retrieved by this struct (as opposed to being initialized).
 
 `ImageManager` also provides convenience functions to map `Tile`s to `UIImage`s.
 */
struct ImageManager {
    
    // MARK: Properties
    
    /** The background color of each top-level view (has to be set manually by that view). */
    static let appBackgroundColor = UIColor(red: 229.0 / 255.0, green: 231.0 / 255.0, blue: 224.0 / 255.0, alpha: 1.0)
    
    /** All images in memory that have been initialized by `ImageManager` are stored in this property. */
    private static let storedImages = NSMapTable(keyOptions: NSMapTableStrongMemory, valueOptions: NSMapTableWeakMemory)
    
    
    // MARK: Functions
    
    /**
     Returns a `UIImage` with the specified name. If a `UIImage` with the same name was previously initialized by `ImageManager` and is still in memory, that instance is returned. Otherwise, a new `UIImage` is instatiated and returned.
     - returns: A `UIImage` with name `name`.
     - parameters:
        - name: The name of the `UIImage` to return.
     - requires: An image asset with name `name` exists.
     */
    static func imageForName(name: String) -> UIImage {
        let image = storedImages.objectForKey(name) as? UIImage
        if image != nil {
            return image!
        } else {
            let result = UIImage(named: name)
            if result == nil {
                fatalError("No image asset named " + name)
            } else {
                storedImages.setObject(result!, forKey: name)
                return result!
            }
        }
    }
    
    /** 
    Returns a `UIImage` representing a `Tile` in normal form.
    - parameters:
        - tile: The type of `Tile` the returned `UIImage` should represent.
    - returns: A `UIImage` representing `tile`.
    */
    static func imageForTile(tile: Tile) -> UIImage {
        switch tile {
        case .Empty: return imageForName("board_empty")
        case .Broken: return imageForName("board_broken")
        case .Full0: return imageForName("board_full_breaking_3")
        case .Full1: return imageForName("board_full_breaking_2")
        case .Full2: return imageForName("board_full_breaking_2")
        case .Full3: return imageForName("board_full_breaking_1")
        case .Full4: return imageForName("board_full_breaking_1")
        case .Full5: return imageForName("board_full")
        case .Full6: return imageForName("board_full")
        case .Full7: return imageForName("board_full")
        case .Full8: return imageForName("board_full")
        case .Number1: return imageForName("board_number_one")
        case .Number2: return imageForName("board_number_two")
        case .Number3: return imageForName("board_number_three")
        case .Zlink1: return imageForName("zlink_green")
        case .Zlink2: return imageForName("zlink_pink")
        case .Zlink3: return imageForName("zlink_blue")
        case .Zlink4: return imageForName("zlink_purple")
        case .Zlink5: return imageForName("zlink_red")
        case .Zlink6: return imageForName("zlink_white")
        case .Zlink7: return imageForName("zlink_orange")
        case .Zlink8: return imageForName("zlink_black_round")
        case .Zlink9: return imageForName("zlink_rainbow")
        }
    }
    
    /**
     Returns a `UIImage` representing a `Tile` in linked form (normal form if the `Tile` can't exist in linked form).
     - parameters:
        - tile: The type of `Tile` the returned `UIImage` should represent.
     - returns: A `UIImage` representing `tile`.
     */
    static func linkedImageForTile(tile: Tile) -> UIImage {
        switch tile {
        case .Zlink1: return imageForName("zlink_green_connected")
        case .Zlink2: return imageForName("zlink_pink_connected")
        case .Zlink3: return imageForName("zlink_blue_connected")
        case .Zlink4: return imageForName("zlink_purple_connected")
        case .Zlink5: return imageForName("zlink_red_connected")
        case .Zlink6: return imageForName("zlink_white_connected")
        case .Zlink7: return imageForName("zlink_orange_connected")
        case .Zlink8: return imageForName("zlink_black_round_connected")
        case .Zlink9: return imageForName("zlink_rainbow_connected")
        case .Full0: return imageForName("board_full_connected")
        case .Full1: return imageForName("board_full_connected")
        case .Full2: return imageForName("board_full_connected")
        case .Full3: return imageForName("board_full_connected")
        case .Full4: return imageForName("board_full_connected")
        case .Full5: return imageForName("board_full_connected")
        case .Full6: return imageForName("board_full_connected")
        case .Full7: return imageForName("board_full_connected")
        case .Full8: return imageForName("board_full_connected")
        case .Number1: return imageForName("board_number_one_connected")
        case .Number2: return imageForName("board_number_two_connected")
        case .Number3: return imageForName("board_number_three_connected")
        default: return imageForTile(tile)
        }
    }
    
    /**
     Returns a `UIImage` representing a `Tile` in highlighted form (normal form if the `Tile` can't exist in highlighted form).
     - parameters:
     - tile: The type of `Tile` the returned `UIImage` should represent.
     - returns: A `UIImage` representing `tile`.
     */
    static func highlightedImageForTile(tile: Tile) -> UIImage {
        switch tile {
        case .Zlink1: return imageForName("zlink_green_excited")
        case .Zlink2: return imageForName("zlink_pink_excited")
        case .Zlink3: return imageForName("zlink_blue_excited")
        case .Zlink4: return imageForName("zlink_purple_excited")
        case .Zlink5: return imageForName("zlink_red_excited")
        case .Zlink6: return imageForName("zlink_white_excited")
        case .Zlink7: return imageForName("zlink_orange_excited")
        case .Zlink8: return imageForName("zlink_black_round_excited")
        case .Zlink9: return imageForName("zlink_rainbow_excited")
        default: return imageForTile(tile)
        }
    }
    
    /**
     Returns a `UIImage` representing a `Tile` in selected form (normal form if the `Tile` can't exist in selected form).
     - parameters:
     - tile: The type of `Tile` the returned `UIImage` should represent.
     - returns: A `UIImage` representing `tile`.
     */
    static func selectedImageForTile(tile: Tile) -> UIImage {
        switch tile {
        case .Empty: return imageForName("board_empty_selected")
        case .Full0: return imageForName("board_full_selected_1")
        case .Full1: return imageForName("board_full_selected_2")
        case .Full2: return imageForName("board_full_selected_3")
        case .Full3: return imageForName("board_full_selected_4")
        case .Full4: return imageForName("board_full_selected_5")
        case .Full5: return imageForName("board_full_selected_6")
        case .Full6: return imageForName("board_full_selected_7")
        case .Full7: return imageForName("board_full_selected_8")
        default: return imageForTile(tile)
        }
    }
    
}