//
//  MarketController.swift
//  Zlink
//
//  Created by Kennan Mell on 2/5/16.
//  Copyright © 2016 MegaWatt Gaming. All rights reserved.
//

import UIKit
import StoreKit
import SystemConfiguration

/**
 `MarketController` controls the Market page. It is also responsible for handling IAP payment transactions and playing/rewarding for reward videos.
 
 - seealso: `MarketView`
 */
class MarketController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver, ChartboostDelegate {
    
    // MARK: Properties
    
    /** The Storyboard ID of `MarketController`. */
    static let ID = "Market"
    
    /** The maximum number of reward videos the user is allowed to watch each day. */
    static let maxAdsPerDay = 5
    
    /** The product identifier for all IAPs. */
    fileprivate let productIdentifiers = Set(["com.megawattgaming.zlink.powerup_10", "com.megawattgaming.zlink.powerup_50", "com.megawattgaming.zlink.powerup_200"])
    
    /** The SKProduct used to purchase 10 Power-Ups. */
    fileprivate var powerups10: SKProduct?
    
    /** The SKProduct used to purchase 50 Power-Ups. */
    fileprivate var powerups50: SKProduct?
    
    /** The SKProduct used to purchase 200 Power-Ups. */
    fileprivate var powerups200: SKProduct?
    
    /** `true` if and only if a reward video is currently playing. */
    fileprivate(set) var rewardedVideoPlaying = false
    
    /** The current page of the info pager. */
    var currentPagerPage = 0 {
        didSet {
            if oldValue != currentPagerPage {
                let newImage: UIImageView
                switch currentPagerPage {
                case 0: newImage = UIImageView(image: ImageManager.image(forName: "market_pager_1"))
                case 1: newImage = UIImageView(image: ImageManager.image(forName: "market_pager_2"))
                case 2: newImage = UIImageView(image: ImageManager.image(forName: "market_pager_3"))
                case 3: newImage = UIImageView(image: ImageManager.image(forName: "market_pager_4"))
                case 4: newImage = UIImageView(image: ImageManager.image(forName: "market_pager_5"))
                case 5: newImage = UIImageView(image: ImageManager.image(forName: "market_pager_6"))
                default: fatalError("MarketView: Invalid Pager Page")
                }
                
                newImage.frame = marketView.pagerView.subviews[0].frame
                
                UIView.transition(from: marketView.pagerView.subviews[0], to: newImage, duration: 1.0, options: UIViewAnimationOptions.transitionCrossDissolve, completion: nil)
                
                if currentPagerPage == 0 {
                    marketView.pagerView.addSubview(marketView.powerupsInventoryLabel)
                    marketView.powerupsInventoryLabel.frame = CGRect(x: 0, y: marketView.pagerView.frame.height * 0.025, width: marketView.pagerView.frame.width, height: marketView.pagerView.frame.height)
                } else {
                    marketView.powerupsInventoryLabel.removeFromSuperview()
                }
            }
        }
    }
    
    /** `self.view` cast to `MarketView`. */
    fileprivate var marketView: MarketView {
        // This cast will always succeed if the Storyboard is set up correctly.
        return (self.view as! MarketView)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make sure inventory label is up to date.
        marketView.powerupsInventoryLabel.text = String(SavedData.powerupsOwned)

        // Prepare for IAP transactions by requesting product data.
        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers: self.productIdentifiers)
            request.delegate = self
            request.start()
        } else {
            let alert = UIAlertController(title: "In-App Purchases Not Enabled", message: "Please enable In-App Purchases in Settings.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.default, handler: { alertAction in
                alert.dismiss(animated: true, completion: nil)
                
                let url: URL? = URL(string: UIApplicationOpenSettingsURLString)
                if url != nil {
                    UIApplication.shared.openURL(url!)
                }
                
            }))
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { alertAction in
                alert.dismiss(animated: true, completion: nil)
            }))
            mainController.present(alert, animated: true, completion: nil)
        }
        SKPaymentQueue.default().add(self)
        
        // Add gesture recognizers.
        marketView.rightPagerButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MarketController.pageRight)))
        marketView.leftPagerButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MarketController.pageLeft)))
        marketView.watchAdButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MarketController.watchAdTapped)))
        marketView.powerups10Button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MarketController.buy10Tapped)))
        marketView.powerups50Button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MarketController.buy50Tapped)))
        marketView.powerups200Button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MarketController.buy200Tapped)))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Chartboost.setDelegate(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Chartboost.setDelegate(nil)
    }
    
    
    // MARK: Pager Arrow Delegates
    
    /** Changes the pager page to be the one to the right of the current page (loops around if there is no right page). */
    func pageRight() {
        MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.buttonPressSoundLocation)
        if currentPagerPage == 5 {
            // There are only 6 pager pager pages.
            currentPagerPage = 0
        } else {
            currentPagerPage += 1
        }
    }
    
    /** Changes the pager page to be the one to the left of the current page (loops around if there is no left page). */
    func pageLeft() {
        MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.buttonPressSoundLocation)
        if currentPagerPage == 0 {
            // There are only 6 pager pager pages.
            currentPagerPage = 5
        } else {
            currentPagerPage -= 1
        }
    }
    
    
    // MARK: ChartboostDelegate
    
    func didDisplayRewardedVideo(_ location: String!) {
        rewardedVideoPlaying = true
        MediaPlayer.isPlayingBackgroundMusic = false
    }
    
    func didCompleteRewardedVideo(_ location: String!, withReward reward: Int32) {
        rewardedVideoPlaying = false
        MediaPlayer.isPlayingBackgroundMusic = SavedData.musicOn
        SavedData.powerupsOwned += 1
        SavedData.adsWatchedToday += 1
        SavedData.saveCurrentData()
        marketView.powerupsInventoryLabel.text = String(SavedData.powerupsOwned)
        showRewardMessage("You got 1 Power-Up!")
    }
    
    
    // MARK: Watch Ad Button Delegate
    
    /** Plays an ad for the user, or notifies them if it was unable to play an ad. Called when the user taps the watch ad button. */
    func watchAdTapped() {
        MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.buttonPressSoundLocation)
        if SavedData.adsWatchedToday >= MarketController.maxAdsPerDay {
            let alert = AlertView()
            alert.titleLabel.text = "Out of Ads!"
            alert.messageLabel.text =  "You can only watch " + String(MarketController.maxAdsPerDay) + " ads per day. Check back tomorrow!"
            alert.aspectRatio = 1 / 0.7
            
            alert.bottomButton.setImage(ImageManager.image(forName: "popup_close"), for: UIControlState())
            alert.bottomButton.setImage(ImageManager.image(forName: "popup_close_highlighted"), for: .highlighted)
            
            mainController.presentAlert(alert: alert, topButtonAction: {}, bottomButtonAction: {
                    MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.buttonPressSoundLocation)
            })
        } else if !connectedToNetwork() {
            showNoConnectionAlert()
        } else {
            MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.buttonPressSoundLocation)
            Chartboost.showRewardedVideo(CBLocationIAPStore)
        }
    }
    
    
    // MARK: Purchase Button Delegates
    
    /** Takes the user through the process of buying 10 Power-Ups. Called when the user taps the buy-10 button. */
    func buy10Tapped() {
        MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.buttonPressSoundLocation)
        if powerups10 != nil && connectedToNetwork() {
            let payment = SKPayment(product: powerups10!)
            SKPaymentQueue.default().add(payment)
        } else {
            showNoConnectionAlert()
        }
    }
    
    /** Takes the user through the process of buying 50 Power-Ups. Called when the user taps the buy-50 button. */
    func buy50Tapped() {
        MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.buttonPressSoundLocation)
        if powerups50 != nil && connectedToNetwork() {
            let payment = SKPayment(product: powerups50!)
            SKPaymentQueue.default().add(payment)
        } else {
            showNoConnectionAlert()
        }
    }
    
    /** Takes the user through the process of buying 200 Power-Ups. Called when the user taps the buy-200 button. */
    func buy200Tapped() {
        MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.buttonPressSoundLocation)
        if powerups200 != nil && connectedToNetwork() {
            let payment = SKPayment(product: powerups200!)
            SKPaymentQueue.default().add(payment)
        } else {
            showNoConnectionAlert()
        }
    }
    
    
    // MARK: SKProductsRequestDelegate
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        var products = response.products
        var product: SKProduct?

        if (products.count != 0) {
            for i in 0 ..< products.count {
                product = products[i]
                if product?.productIdentifier == "com.megawattgaming.zlink.powerup_10" {
                    powerups10 = product
                    print("10 powerups iap received")
                } else if product?.productIdentifier == "com.megawattgaming.zlink.powerup_50" {
                    powerups50 = product
                    print("50 powerups iap received")
                } else if product?.productIdentifier == "com.megawattgaming.zlink.powerup_200" {
                    powerups200 = product
                    print("200 powerups iap received")
                }
            }
        } else {
            print("No products found")
        }
        
        let invalidProducts = response.invalidProductIdentifiers
        
        for product in invalidProducts {
            print("Product not found: \(product)")
        }
    }
    
    
    // MARK: SKPaymentTransactionObserver
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("Received Payment Transaction Response from Apple");
        
        for transaction in transactions {
                switch transaction.transactionState {
                case .purchased:
                    print("Product Purchased");
                    
                    let powerupsToAdd: Int
                    switch transaction.payment.productIdentifier {
                    case "com.megawattgaming.zlink.powerup_10": powerupsToAdd = 10
                    case "com.megawattgaming.zlink.powerup_50": powerupsToAdd = 50
                    case "com.megawattgaming.zlink.powerup_200": powerupsToAdd = 200
                    default: powerupsToAdd = 0
                    }
                    
                    SKPaymentQueue.default().finishTransaction(transaction)
                    SavedData.powerupsOwned += powerupsToAdd
                    SavedData.saveCurrentData()
                    marketView.powerupsInventoryLabel.text = String(SavedData.powerupsOwned)
                    if powerupsToAdd > 0 {
                        showRewardMessage("You got " + String(powerupsToAdd) + " Power-Ups!")
                    }
                    break;
                case .failed:
                    print("Purchased Failed");
                    SKPaymentQueue.default().finishTransaction(transaction)
                    break;
                default:
                    break;
                }
        }
        
    }
    
    
    // MARK: Other Functions

    /** Displays an alert notifying the user that they may not be connected to the internet. */
    fileprivate func showNoConnectionAlert() {
        let alert = AlertView()
        alert.titleLabel.text = "Not Found"
        alert.messageLabel.text =  "Try checking your Internet connection."
        alert.aspectRatio = 1 / 0.7
        
        alert.bottomButton.setImage(ImageManager.image(forName: "popup_close"), for: UIControlState())
        alert.bottomButton.setImage(ImageManager.image(forName: "popup_close_highlighted"), for: .highlighted)
        
        mainController.presentAlert(alert: alert, topButtonAction: {}, bottomButtonAction: {
            MediaPlayer.playMP3Sound(soundLocation: MediaPlayer.buttonPressSoundLocation)
        })
    }
    
    /**
     Displays a message for a couple seconds telling the user that they've earned a reward.
     - parameters:
        - text: The text to display on the message. Should be only 1 line.
     */
    fileprivate func showRewardMessage(_ text: String) {
        let rewardMessage = marketView.rewardLabel
        rewardMessage.text = text
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            rewardMessage.frame.origin.y -= rewardMessage.frame.height
            }, completion: { _ in
                let time = DispatchTime.now() + Double(Int64(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time, execute: {
                    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                        rewardMessage.frame.origin.y = self.view.frame.height + 1
                        }, completion: nil)
                })
        })
    }

    /** Returns `true` if and only if the user has internet connection. */
    fileprivate func connectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
}
