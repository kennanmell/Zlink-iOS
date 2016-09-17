//
//  StatsController.swift
//  Zlink
//
//  Created by Kennan Mell on 2/5/16.
//  Copyright © 2016 MegaWatt Gaming. All rights reserved.
//

import UIKit

/**
 `StatsController` manages the stats page. It is also responsible for managing the selection and deselection of high scores on its page.
 
 - seealso: `Stats`, `StatsView`
 */
class StatsController: UIViewController {
    
    // MARK: Properties
    
    /** The Storyboard ID of `StatsController`. */
    static let ID = "Stats"
    
    /** The image to share. Stored as a property so the share button doesn't appear pressed when the image is shared. */
    fileprivate var screenshot: UIImage?
    
    /** The high score currently selected (to see the date), or `nil` if no high score is currently selected. */
    var selectedHighScore: Int? = nil {
        willSet {
            if selectedHighScore != nil {
                // Deselect the currently selected high score.
                statsView.highScoreImagesArray[selectedHighScore!].setImage(UIImage(named: "scores_score_background"), for: UIControlState())
                statsView.highScoreLabelsArray[selectedHighScore!].text = String(selectedHighScore! + 1) + ". " + String(SavedData.stats[selectedHighScore!].score)
            }
        }
        didSet {
            if selectedHighScore != nil {
                if selectedHighScore! >= SavedData.stats.count {
                    fatalError("Attempted to select non-existent high score.")
                }
                
                // Select the newly selected high score.
                statsView.highScoreImagesArray[selectedHighScore!].setImage(UIImage(named: "scores_score_background_highlighted"), for: UIControlState())
                statsView.highScoreLabelsArray[selectedHighScore!].text = SavedData.stats[selectedHighScore!].date
            }
        }
    }
    
    /** `self.view` cast to `StatsView`. */
    fileprivate var statsView: StatsView {
        // This cast will always succeed if the Storyboard is set up correctly.
        return (self.view as! StatsView)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add button gesture listeners.
        statsView.shareButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(StatsController.shareTapped)))
        statsView.resetDataButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(StatsController.resetDataTapped)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Update displayed data.
        statsView.gamesPlayedLabel.text = String(SavedData.stats.gamesPlayed)
        statsView.zlinksLinkedLabel.text = String(SavedData.stats.zlinksLinked)
        
        let highScoreBackgrounds = statsView.highScoreImagesArray
        let highScoreLabels = statsView.highScoreLabelsArray
        
        if highScoreBackgrounds.count != highScoreLabels.count || highScoreBackgrounds.count != SavedData.stats.count {
            fatalError("Count mismatch.")
        }
        
        for i in 0..<SavedData.stats.count {
            // Add gesture recognizer for newly created button.
            highScoreBackgrounds[i].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(StatsController.highScoreTapped(_:))))
            highScoreLabels[i].text = String(i + 1) + ". " + String(SavedData.stats[i].score)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if screenshot == nil {
            // Get screenshot to share.
            let layer = UIApplication.shared.keyWindow!.layer
            let scale = UIScreen.main.scale
            UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
            layer.render(in: UIGraphicsGetCurrentContext()!)
            screenshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
    }
    
    
    // MARK: High Score Buttons Delegate
    
    /**
     Selects a high score, or deselects it if it's already selected.
     - parameters:
        - recognizer: The `UITapGestureRecognizer` whose gesture resulted in this function being called. Contains the information necessary to determine which score to select.
     */
    func highScoreTapped(_ recognizer: UITapGestureRecognizer) {
        let index = statsView.highScoreImagesArray.index(of: recognizer.view as! UIButton)!
        if selectedHighScore == index {
            selectedHighScore = nil
        } else {
            selectedHighScore = index
        }
    }
    
        
    // MARK: Reset Data Button Delegate
    
    /** Clears all saved user data and takes the user to the home page. Called when the user taps the reset data button. */
    func resetDataTapped() {
        MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.buttonPressSoundLocation)
        self.selectedHighScore = nil
        
        let alert = AlertView()
        alert.titleLabel.text = "Reset All Data?"
        alert.messageLabel.text =  "You will lose all scores, preferences, in-progress games, and other saved data. Power-Up Inventory and Game Center data will not be lost."
        alert.aspectRatio = 1 / 1.1
        
        alert.topButton.setImage(ImageManager.image(forName: "popup_reset"), for: UIControlState())
        alert.topButton.setImage(ImageManager.image(forName: "popup_reset_highlighted"), for: .highlighted)
        
        alert.bottomButton.setImage(ImageManager.image(forName: "popup_cancel"), for: UIControlState())
        alert.bottomButton.setImage(ImageManager.image(forName: "popup_cancel_highlighted"), for: .highlighted)
        
        mainController.presentAlert(alert: alert, topButtonAction: {
            MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.buttonPressSoundLocation)
            SavedData.saveDefaultData()
            self.mainController.setViewController(id: HomeController.ID)
        }, bottomButtonAction: {
            MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.buttonPressSoundLocation)
        })
    }
    
    
    // MARK: Share Button Delegate
    
    /** Shares a screenshot of this page. Called when the user clicks the share button. */
    func shareTapped() {
        MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.buttonPressSoundLocation)
        self.selectedHighScore = nil
        
        // Set up and open Apple's default sharing feature.
        let text = "Check out my stats in Zlink!"
        
        var objectsToShare: Array<NSObject> = [text as NSObject]
        
        if let website = URL(string: "http://www.megawattgaming.com/") {
            objectsToShare.append(website as NSObject)
        }
        
        if screenshot != nil {
            objectsToShare.append(screenshot!)
        }
        
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        let popoverView = UIView()
        if activityVC.responds(to: #selector(getter: UIViewController.popoverPresentationController)) {
            // iPad
            let shareButton = (self.view as! StatsView).shareButton
            popoverView.frame = CGRect(x: shareButton.frame.origin.x + shareButton.frame.width / 2, y: shareButton.frame.origin.y - view.frame.height * 0.01, width: 1, height: 1)
            self.view.addSubview(popoverView)
            activityVC.popoverPresentationController?.sourceView = popoverView
        }
        
        self.navigationController!.present(activityVC, animated: true, completion: {
            popoverView.removeFromSuperview()
        })
    }
    
}
