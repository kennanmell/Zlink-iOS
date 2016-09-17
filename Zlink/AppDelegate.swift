//
//  AppDelegate.swift
//  Zlink
//
//  Created by Kennan Mell on 2/5/16.
//  Copyright © 2016 MegaWatt Gaming. All rights reserved.
//

/*
 NOTES ABOUT CODE:
 
 + The Zlink application utilizes the model-view-controller design pattern. Each of the 6 top-level scenes (Play, Home, Stats, Market, Gameover, Tutorial) has a top-level controller and (except Tutorial) a top-level view, but may use sub-controllers, sub-views, or models as necessary.
 
 + Navigation between scenes is controlled by the `MainController` class, which is also responsible for controlling the top bar, side menu, and custom alerts.
 
 + The Storyboard is used solely to designate the navigation controller and the top-level view and controller for each scene; all views are defined programatically. In order to programatically initialize view controllers on the storyboard, each top-level controller has a Storyboard ID `String` that should match its static `ID` property.
 
 + The launch screen is defined solely by `LaunchImage` (an asset in Resources/Images.xcassets).
 
 + Each non-private class/struct/enum is placed in a file whose name matches the class name, with the exception of protocols and extensions, which are placed in the same file as the class(es) intended to call their functions.
 
 + Most of the application's data is stored in models, but to avoid having trivial model objects, controllers are allowed store and modify non-permanent information about their state and their view's state. Models have no information about the application's views or controllers, and views have no information the application's models or controllers.
 
 + To improve performance, data is not saved automatically. The `AppDelegate` is responsible for saving data to permanent storage when appropriate.
 
 + Static functions and variables are used in favor global functions and variables.
 
 
 HOW TO PLAY:
 
 + Zlink is a 1-player board game where the player attempts to get the highest score possible before losing. The board played on is a 6x6 square. Each subsection of the board contains a tile, which may be a white tile, a gold tile, a black tile, a Zlink, or a number. The properties of these types of tile are defined in context below.
 
 + Moving: A number can be moved in one of four directions (up, down, left, right) if and only if that number of tiles adjacent to it (in the direction to move) are white tiles. When a number is moved, the white tiles mentioned previously are converted to gold tiles and the number is converted to a white tile. After a number is moved, a new number is added to the board and time is advanced by one unit.
 
 + Scoring: Two Zlinks are considered linked if one can be reached from the other by walking only on gold tiles and numbers and only in the four main directions (up, down, left, right). If at any point two Zlinks on the board are linked, three things happen in the following order: the linked Zlinks and all gold tiles and numbers touching them are removed from the board, the player's score is increased by one for each Zlink removed, and new Zlinks, numbers, and/or gold tiles may be added to the board.
 
 + Losing: The game ends when no numbers on the board can be swiped in any direction and the board has no links. If a gold tile has been on the board for a predetermined amount of time units, it turns into a black tile. Black tiles cannot be moved over or used in links, thus the more black tiles the player has on the board, the more likely they are to lose quickly.
 
 + Power-Ups: One of each of the following Power-Ups may be used each game:
    + Magic Tile: Turns all white tiles on the board into gold tiles.
    + Tile Repair: Turns all black tiles on the board into white tiles.
    + Shuffle: Rearranges the tiles on the board.
 
 
 APP FEATURES:
 
 + Stats page with top scores and other facts.
 
 + Home screen showing all Zlink types the player has seen, including the secret Zlink.
 
 + Easy navigation via side menu.
 
 + Animated tutorial.
 
 + Game Center integration.
 
 + Power-Ups earnable via reward videos, daily rewards, or in-app purchases.

 */

import UIKit
import AVFoundation
import GameKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: Properties
    
    var window: UIWindow?
    
    /** `true` if and only if Game Center has been successfully authenticated. */
    var gameCenterAuthenticated = false

    
    // MARK: Functions
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Save default data if the app has never opened before.
        if SavedData.dateOfFirstOpen == nil {
            SavedData.saveDefaultData()
        }
                
        // Prepare Chartboost ads.
        Chartboost.start(withAppId: "56e3c2882fdf346cf3cd353c", appSignature: "16a421d64ada386cff627f98a68171309e276d96", delegate: nil)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Save user data.
        SavedData.saveCurrentData()
        
        // Pause background music if necessary.
        MediaPlayer.isPlayingBackgroundMusic = false
        
        // Notify tutorial of change if it's open.
        if let tutorialController = getCurrentViewController() as? TutorialController {
            tutorialController.applicationIsActive = false
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        let currentViewController = getCurrentViewController()

        // Start background music if player has SFX on and no other sounds are playing (including in-app video ads).
        let sess = AVAudioSession.sharedInstance()
        if sess.isOtherAudioPlaying {
            _ = try? sess.setCategory(AVAudioSessionCategoryAmbient, with: .mixWithOthers)
            _ = try? sess.setActive(true, with: [])
        } else if SavedData.musicOn && (!(currentViewController is MarketController) || !(currentViewController as! MarketController).rewardedVideoPlaying) {
            MediaPlayer.isPlayingBackgroundMusic = true
        }
        
        // Authenticate game center if necessary.
        if !gameCenterAuthenticated {
            let localPlayer = GKLocalPlayer.localPlayer()
            localPlayer.authenticateHandler = { (viewController : UIViewController?, error : Error?) -> Void in
                if localPlayer.isAuthenticated {
                    self.gameCenterAuthenticated = true
                } else {
                    print("not able to authenticate fail")
                    self.gameCenterAuthenticated = false
                    
                    if (error != nil) {
                        print("\(error!.localizedDescription)")
                    } else {
                        print("error is nil")
                    }
                }
            }
        }
        
        // Notify tutorial of change if it's open.
        if currentViewController is TutorialController {
            (currentViewController as! TutorialController).applicationIsActive = true
        }
        
        // Give away daily reward if necessary.
        let currentDate = Calendar.getCurrentDate()
        if currentViewController != nil && SavedData.lastFreeGiveawayDate != nil && currentDate != SavedData.lastFreeGiveawayDate {
            SavedData.lastFreeGiveawayDate = currentDate
            SavedData.adsWatchedToday = 0
            SavedData.powerupsOwned += 1
            
            let alert = AlertView()
            alert.titleLabel.text = "Daily Reward"
            alert.messageLabel.text =  "You earned one free Power-Up for playing Zlink today!\n\nVisit the Market for more FREE Power-Ups?"
            alert.aspectRatio = 1 / 1.12
            
            alert.topButton.setImage(ImageManager.image(forName: "popup_market"), for: UIControlState())
            alert.topButton.setImage(ImageManager.image(forName: "popup_market_highlighted"), for: .highlighted)
            
            alert.bottomButton.setImage(ImageManager.image(forName: "popup_close"), for: UIControlState())
            alert.bottomButton.setImage(ImageManager.image(forName: "popup_close_highlighted"), for: .highlighted)
            
            let stickerImage = UIImageView(image: ImageManager.image(forName: "popup_daily_reward"))
            alert.addSubview(stickerImage)
            alert.bringSubview(toFront: stickerImage)
            alert.frame = CGRect(x: 0, y: 0, width: currentViewController!.view.frame.width, height: currentViewController!.view.frame.height)
            alert.setNeedsLayout()
            alert.layoutIfNeeded()
            let stickerImageDimension = alert.backgroundButton.frame.width / 6
            stickerImage.frame = CGRect(x: alert.backgroundButton.frame.origin.x + alert.backgroundButton.frame.width - stickerImageDimension * 0.8, y: alert.backgroundButton.frame.origin.y - stickerImageDimension * 0.2, width: stickerImageDimension, height: stickerImageDimension)
            
            currentViewController!.mainController.presentAlert(alert: alert, topButtonAction: {
                MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.buttonPressSoundLocation)
                currentViewController!.mainController.setViewController(id: MarketController.ID)
                }, bottomButtonAction: {
                    MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.buttonPressSoundLocation)
            })
        }
    }
    
    /** Recursive helper function that gets the current `ViewController`, if any. */
    fileprivate func getCurrentViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getCurrentViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return getCurrentViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return getCurrentViewController(base: presented)
        }
        
        return base
    }
    
}
