//
//  MainController.swift
//  Zlink
//
//  Created by Kennan Mell on 2/8/16.
//  Copyright © 2016 MegaWatt Gaming. All rights reserved.
//

import UIKit
import GameKit

extension UIViewController {
    /** `self.navigationController` cast to `MainController` for convenience. Should only be used if the Storyboard or `UIViewController` has been set up so that the cast will succeed. */
    var mainController: MainController {
        // This cast will always succeed if the Storyboard is set up correctly and the variable is only accessed from a top-level view controller.
        return navigationController as! MainController
    }
}

/**
 `MainController` controls the top bar, the side menu, navigation between `UIViewController`s, and the presentation of `AlertView`s.
 
 - seealso: `MenuView`, `TopBarView`, `AlertView`
 */
class MainController: UINavigationController, GKGameCenterControllerDelegate {
    
    // MARK: Properties
    
    /** `true` if and only if `self` has its side menu open. */
    var menuOpen = false {
        didSet {
            // The time it takes for the side menu to animate opening and closing.
            let menuSlideAnimationDuration = 0.4

            // Notify tutorial of change if it's open.
            let viewController = getCurrentViewController()
            if viewController is TutorialController {
                (viewController as! TutorialController).menuIsOpen = menuOpen
            }
            
            if !menuOpen && oldValue {
                self.menuView.leftoverView.backgroundColor = nil
                UIApplication.shared.beginIgnoringInteractionEvents()
                UIView.animate(withDuration: menuSlideAnimationDuration, delay:0, options: .curveEaseIn, animations: {
                    self.menuView.frame.origin.x += self.menuView.menuFrame.width
                    }, completion: { _ in
                        self.menuView.frame.origin.x = self.view.frame.width + 1
                        UIApplication.shared.endIgnoringInteractionEvents()
                })
            } else if menuOpen && !oldValue {
                // Make sure button images are up-to-date
                if SavedData.stats.isTrackingGame {
                    menuView.playButton.setImage(ImageManager.image(forName: "menu_play"), for: UIControlState())
                    menuView.playButton.setImage(ImageManager.image(forName: "menu_play_highlighted"), for: .highlighted)
                } else {
                    menuView.playButton.setImage(ImageManager.image(forName: "menu_newgame"), for: UIControlState())
                    menuView.playButton.setImage(ImageManager.image(forName: "menu_newgame_highlighted"), for: .highlighted)
                }
                
                if SavedData.musicOn {
                    menuView.musicButton.setImage(ImageManager.image(forName: "menu_music_on"), for: UIControlState())
                    menuView.musicButton.setImage(ImageManager.image(forName: "menu_music_on_highlighted"), for: .highlighted)
                } else {
                    menuView.musicButton.setImage(ImageManager.image(forName: "menu_music_off"), for: UIControlState())
                    menuView.musicButton.setImage(ImageManager.image(forName: "menu_music_off_highlighted"), for: .highlighted)
                }
                
                if SavedData.sfxOn {
                    menuView.sfxButton.setImage(ImageManager.image(forName: "menu_sfx_on"), for: UIControlState())
                    menuView.sfxButton.setImage(ImageManager.image(forName: "menu_sfx_on_highlighted"), for: .highlighted)
                } else {
                    menuView.sfxButton.setImage(ImageManager.image(forName: "menu_sfx_off"), for: UIControlState())
                    menuView.sfxButton.setImage(ImageManager.image(forName: "menu_sfx_off_highlighted"), for: .highlighted)
                }
                
                // Clean the `PlayController` if it's open.
                let viewController = getCurrentViewController()
                if viewController is PlayController {
                    (viewController as! PlayController).powerupsOpen = false
                    (viewController!.view as! PlayView).messageLabel.text = nil
                    (viewController as! PlayController).selectedTile = nil
                }
                
                self.menuView.frame.origin.x = 0
                self.menuView.leftoverView.backgroundColor = UIColor(white: 0.2, alpha: 0.5)
                UIApplication.shared.beginIgnoringInteractionEvents()
                UIView.animate(withDuration: menuSlideAnimationDuration, delay: 0, options: .curveEaseOut, animations: {
                    self.menuView.frame.origin.x = -1 * self.menuView.menuFrame.width + 1
                    }, completion: { _ in
                        UIApplication.shared.endIgnoringInteractionEvents()
                })
            }
        }
    }
    
    /** A weak reference to the side menu view. */
    fileprivate weak var menuView: MenuView!
    
    fileprivate var topBarView: TopBarView = TopBarView()
    
    /** The `AlertView` currently displayed by this `MainController`, or `nil` if no `AlertView` is currently displayed. */
    fileprivate var displayedAlert: AlertView?
    
    /** The action to perform when the top button of `displayedAlert` is pressed. */
    fileprivate var topButtonAction: () -> Void = {}
    
    /** The action to perform when the bottom button of `displayedAlert` is pressed. */
    fileprivate var bottomButtonAction: () -> Void = {}
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.isHidden = true
        
        // Adjust `topBarView` frame.
        self.view.addSubview(topBarView)
        self.topBarView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: topBarView.menuButton.frame.height)
        
        // Set up side menu.
        let menuView = MenuView(superViewFrame: self.view.frame)
        self.menuView = menuView
        menuView.frame = CGRect(x: self.view.frame.width + 1, y: 0, width: self.view.frame.width + menuView.menuFrame.width, height: self.view.frame.height)
        view.addSubview(menuView)
        
        // Make sure top bar appears in front of side menu.
        view.bringSubview(toFront: topBarView)
        
        // Prepare top bar gesture recognizers.
        topBarView.menuButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MainController.menuTapped)))
        topBarView.homeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MainController.homeTapped)))
        
        // Prepare side menu gesture recognizers.
        menuView.playButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MainController.playTapped)))
        menuView.leaderboardButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MainController.leaderboardTapped)))
        menuView.scoresButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MainController.scoresTapped)))
        menuView.marketButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MainController.marketTapped)))
        menuView.sfxButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MainController.sfxTapped)))
        menuView.musicButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MainController.musicTapped)))
        menuView.tutorialButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MainController.tutorialTapped)))
        menuView.leftoverView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MainController.menuClosed)))
        let swipeToCloseAction = UISwipeGestureRecognizer(target: self, action: #selector(MainController.menuClosed))
        swipeToCloseAction.direction = .right
        menuView.leftoverView.addGestureRecognizer(swipeToCloseAction)
    }
    
    
    // MARK: Navigation
    
    /**
    Changes the currently displayed scene to be a specified scene. Does not change scenes if the specified scene is the current scene. Always hides the side menu.
    - parameters:
        - id: The Storyboard Identifier of the destination `UIViewController`.
    - requires: `id` is the Storyboard Identifier for a `UIViewController` in the main storyboard.
    */
    func setViewController(id: String) {
        menuOpen = false
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let destViewController = mainStoryboard.instantiateViewController(withIdentifier: id)
        
        let currentClassName = NSStringFromClass(object_getClass(getCurrentViewController()))
        let newClassName = NSStringFromClass(object_getClass(destViewController))

        if currentClassName != newClassName {
            self.setViewControllers([destViewController], animated: true)
            
            // Update the top bar's title to reflect the new controller.
            switch id {
            case PlayController.ID: topBarView.titleLabel.text = "Zlink"
            case StatsController.ID: topBarView.titleLabel.text = "Stats"
            case MarketController.ID: topBarView.titleLabel.text = "Market"
            case TutorialController.ID: topBarView.titleLabel.text = "Tutorial"
            default: topBarView.titleLabel.text = ""
            }
        }
    }
    
    /** Recursive helper function that gets the "top" `UIViewController`. Used to determine whenter not to switch scenes when `setViewController` is called. */
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
    
    
    // MARK: GKGameCenterControllerDelegate
    
    func gameCenterViewControllerDidFinish(_ gcViewController: GKGameCenterViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: Topbar Button Delegates
    
    /** Called when user taps the menu button. */
    func menuTapped() {
        MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.buttonPressSoundLocation)
        menuOpen = !menuOpen
    }
    
    /** Called when user taps the home button. */
    func homeTapped() {
        MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.buttonPressSoundLocation)
        setViewController(id: HomeController.ID)
    }
    
    
    // MARK: Menu Button Delegates
    
    /** Called when the user taps or right-swipes outside the side menu while it's open. */
    func menuClosed() {
        menuOpen = false
    }
    
    /** Called when user taps the play/new game button. */
    func playTapped() {
        MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.buttonPressSoundLocation)
        setViewController(id: PlayController.ID)
    }
    
    /** Called when user taps the leaderboard button. */
    func leaderboardTapped() {
        MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.buttonPressSoundLocation)
        
        // Show game center leaderboard
        let gcViewController: GKGameCenterViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = self
        gcViewController.viewState = GKGameCenterViewControllerState.leaderboards
        gcViewController.leaderboardIdentifier = "best_score"
        self.present(gcViewController, animated: true, completion: nil)

    }
    
    /** Called when user taps the scores button. */
    func scoresTapped() {
        MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.buttonPressSoundLocation)
        setViewController(id: StatsController.ID)
    }
    
    /** Called when user taps the market button. */
    func marketTapped() {
        MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.buttonPressSoundLocation)
        setViewController(id: MarketController.ID)
    }
    
    /** Called when user taps the SFX toggle button. */
    func sfxTapped() {
        if SavedData.sfxOn {
            menuView.sfxButton.setImage(ImageManager.image(forName: "menu_sfx_off"), for: UIControlState())
            menuView.sfxButton.setImage(ImageManager.image(forName: "menu_sfx_off_highlighted"), for: .highlighted)
        } else {
            menuView.sfxButton.setImage(ImageManager.image(forName: "menu_sfx_on"), for: UIControlState())
            menuView.sfxButton.setImage(ImageManager.image(forName: "menu_sfx_on_highlighted"), for: .highlighted)
        }
        SavedData.sfxOn = !SavedData.sfxOn
        MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.buttonPressSoundLocation)
    }
    
    /** Called when user taps the music toggle button. */
    func musicTapped() {
        MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.buttonPressSoundLocation)
        SavedData.musicOn = !SavedData.musicOn
        if SavedData.musicOn {
            MediaPlayer.isPlayingBackgroundMusic = true
            menuView.musicButton.setImage(ImageManager.image(forName: "menu_music_on"), for: UIControlState())
            menuView.musicButton.setImage(ImageManager.image(forName: "menu_music_on_highlighted"), for: .highlighted)
        } else {
            MediaPlayer.isPlayingBackgroundMusic = false
            menuView.musicButton.setImage(ImageManager.image(forName: "menu_music_off"), for: UIControlState())
            menuView.musicButton.setImage(ImageManager.image(forName: "menu_music_off_highlighted"), for: .highlighted)
        }
    }
    
    /** Called when user taps the tutorial button. */
    func tutorialTapped() {
        MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.buttonPressSoundLocation)
        setViewController(id: TutorialController.ID)
    }
    
    
    // MARK: AlertView Delegate
    
    /**
     Dismisses the currently displayed alert (if any) then presents a new one. The presented alert will be dismissed if the user taps outside it on the screen.
     - parameters:
        - alert: The `AlertView` to present. If this alert has only one button, it should be the bottom button.
        - topButtonAction: The action to take if the top button of `alert` is pressed. The alert is dismissed after performing this action. Ignored if the image displayed by `alert`'s top button is nil.
        - bottomButtonAction: The action to take if the bottom button of `alert` is pressed. The alert is dismissed after performing this action.
     */
    func presentAlert(alert: AlertView, topButtonAction: @escaping () -> Void, bottomButtonAction: @escaping () -> Void) {
        self.dismissAlert()
        if (alert.topButton.currentImage != nil) {
            self.topButtonAction = topButtonAction
            alert.topButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MainController.topAlertButtonTapped)))
        }
        self.displayedAlert = alert
        self.bottomButtonAction = bottomButtonAction
        alert.bottomButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MainController.bottomAlertButtonTapped)))
        alert.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MainController.dismissAlert)))
        alert.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        self.view.addSubview(alert)
        self.view.bringSubview(toFront: alert)
        
        // Notify tutorial of change if it's open.
        let viewController = getCurrentViewController()
        if viewController is TutorialController {
            (viewController as! TutorialController).menuIsOpen = true
        }
    }
    
    /** Dismisses the currently displayed alert (if any). Called after performing an action on the currently displayed alert, or if the user taps outside the bounds of the currently displayed alert while it's being displayed. */
    @objc fileprivate func dismissAlert() {
        self.topButtonAction = {}
        self.bottomButtonAction = {}
        self.displayedAlert?.removeFromSuperview()
        self.displayedAlert = nil
        
        // Notify tutorial of change if it's open.
        let viewController = getCurrentViewController()
        if viewController is TutorialController {
            (viewController as! TutorialController).menuIsOpen = false
        }
    }
    
    /** Called when user taps the top button (if any) of the currently displayed alert (if any). */
    @objc fileprivate func topAlertButtonTapped() {
        topButtonAction()
        dismissAlert()
    }
    
    /** Called when user taps the bottom button (if any) of the currently displayed alert (if any). */
    @objc fileprivate func bottomAlertButtonTapped() {
        bottomButtonAction()
        dismissAlert()
    }
    
}
