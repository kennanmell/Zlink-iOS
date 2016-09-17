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
    fileprivate static let storedImages: NSMapTable<NSString, UIImage> = NSMapTable(keyOptions: NSPointerFunctions.Options.strongMemory, valueOptions: NSPointerFunctions.Options.weakMemory)
    
    
    // MARK: Functions
    
    /**
     Returns a `UIImage` with the specified name. If a `UIImage` with the same name was previously initialized by `ImageManager` and is still in memory, that instance is returned. Otherwise, a new `UIImage` is instatiated and returned.
     - returns: A `UIImage` with name `name`.
     - parameters:
        - forName: The name of the `UIImage` to return.
     - requires: An image asset with name `name` exists.
     */
    static func image(forName name: String) -> UIImage {
        let image = storedImages.object(forKey: name as NSString?)
        if image != nil {
            return image!
        } else {
            let result = UIImage(named: name)
            if result == nil {
                fatalError("No image asset named " + name)
            } else {
                storedImages.setObject(result!, forKey: name as NSString?)
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
    static func image(forTile tile: Tile) -> UIImage {
        switch tile {
        case .empty: return image(forName: "board_empty")
        case .broken: return image(forName: "board_broken")
        case .full0: return image(forName: "board_full_breaking_3")
        case .full1: return image(forName: "board_full_breaking_2")
        case .full2: return image(forName: "board_full_breaking_2")
        case .full3: return image(forName: "board_full_breaking_1")
        case .full4: return image(forName: "board_full_breaking_1")
        case .full5: return image(forName: "board_full")
        case .full6: return image(forName: "board_full")
        case .full7: return image(forName: "board_full")
        case .full8: return image(forName: "board_full")
        case .number1: return image(forName: "board_number_one")
        case .number2: return image(forName: "board_number_two")
        case .number3: return image(forName: "board_number_three")
        case .zlink1: return image(forName: "zlink_green")
        case .zlink2: return image(forName: "zlink_pink")
        case .zlink3: return image(forName: "zlink_blue")
        case .zlink4: return image(forName: "zlink_purple")
        case .zlink5: return image(forName: "zlink_red")
        case .zlink6: return image(forName: "zlink_white")
        case .zlink7: return image(forName: "zlink_orange")
        case .zlink8: return image(forName: "zlink_black_round")
        case .zlink9: return image(forName: "zlink_rainbow")
        }
    }
    
    /**
     Returns a `UIImage` representing a `Tile` in linked form (normal form if the `Tile` can't exist in linked form).
     - parameters:
        - forTile: The type of `Tile` the returned `UIImage` should represent.
     - returns: A `UIImage` representing `tile`.
     */
    static func linkedImage(forTile tile: Tile) -> UIImage {
        switch tile {
        case .zlink1: return image(forName: "zlink_green_connected")
        case .zlink2: return image(forName: "zlink_pink_connected")
        case .zlink3: return image(forName: "zlink_blue_connected")
        case .zlink4: return image(forName: "zlink_purple_connected")
        case .zlink5: return image(forName: "zlink_red_connected")
        case .zlink6: return image(forName: "zlink_white_connected")
        case .zlink7: return image(forName: "zlink_orange_connected")
        case .zlink8: return image(forName: "zlink_black_round_connected")
        case .zlink9: return image(forName: "zlink_rainbow_connected")
        case .full0: return image(forName: "board_full_connected")
        case .full1: return image(forName: "board_full_connected")
        case .full2: return image(forName: "board_full_connected")
        case .full3: return image(forName: "board_full_connected")
        case .full4: return image(forName: "board_full_connected")
        case .full5: return image(forName: "board_full_connected")
        case .full6: return image(forName: "board_full_connected")
        case .full7: return image(forName: "board_full_connected")
        case .full8: return image(forName: "board_full_connected")
        case .number1: return image(forName: "board_number_one_connected")
        case .number2: return image(forName: "board_number_two_connected")
        case .number3: return image(forName: "board_number_three_connected")
        default: return image(forTile: tile)
        }
    }
    
    /**
     Returns a `UIImage` representing a `Tile` in highlighted form (normal form if the `Tile` can't exist in highlighted form).
     - parameters:
     - forTile: The type of `Tile` the returned `UIImage` should represent.
     - returns: A `UIImage` representing `tile`.
     */
    static func highlightedImage(forTile tile: Tile) -> UIImage {
        switch tile {
        case .zlink1: return image(forName: "zlink_green_excited")
        case .zlink2: return image(forName: "zlink_pink_excited")
        case .zlink3: return image(forName: "zlink_blue_excited")
        case .zlink4: return image(forName: "zlink_purple_excited")
        case .zlink5: return image(forName: "zlink_red_excited")
        case .zlink6: return image(forName: "zlink_white_excited")
        case .zlink7: return image(forName: "zlink_orange_excited")
        case .zlink8: return image(forName: "zlink_black_round_excited")
        case .zlink9: return image(forName: "zlink_rainbow_excited")
        default: return image(forTile: tile)
        }
    }
    
    /**
     Returns a `UIImage` representing a `Tile` in selected form (normal form if the `Tile` can't exist in selected form).
     - parameters:
     - forTile: The type of `Tile` the returned `UIImage` should represent.
     - returns: A `UIImage` representing `tile`.
     */
    static func selectedImage(forTile tile: Tile) -> UIImage {
        switch tile {
        case .empty: return image(forName: "board_empty_selected")
        case .full0: return image(forName: "board_full_selected_1")
        case .full1: return image(forName: "board_full_selected_2")
        case .full2: return image(forName: "board_full_selected_3")
        case .full3: return image(forName: "board_full_selected_4")
        case .full4: return image(forName: "board_full_selected_5")
        case .full5: return image(forName: "board_full_selected_6")
        case .full6: return image(forName: "board_full_selected_7")
        case .full7: return image(forName: "board_full_selected_8")
        default: return image(forTile: tile)
        }
    }
    
}
