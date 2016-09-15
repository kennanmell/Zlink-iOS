//
//  BoardController.swift
//  Zlink
//
//  Created by Kennan Mell on 3/27/16.
//  Copyright © 2016 MegaWatt Gaming. All rights reserved.
//

import UIKit
import AVFoundation

/**
 `TileAnimator` can be attached to a `UIView` and a `Board` or `BoardFiller` to animate the process of modifying `Tile` types on a `Board`.
 
 `TileAnimator` will animate changes related to moving numbers, removing connections, rebuilding a `Board`, and repairing blockades. All other changes will result in the corresponding `UIView` being updated to display the correct image, but will not be animated.
 
 `TileAnimator` instances work together to collectively animate one type of animation at a time, in the order they are requested.
 
 All touch events will be disabled whenever `TileAnimator.hasAnimation == true`.
 
 - seealso: `AllAnimationsCompleteListener`, `BoardView`, `BoardListener`, `RefillListener`
 */
class BoardController:NSObject, BoardListener, RefillListener {
    
    // MARK: Properties
    
    /** The duration of the rebuild animation. */
    static let rebuildDuration = 0.5
    /** The duration of the connection removal animation. */
    static let connectFadeoutDuration = 1.5
    /** The duration of the blockade repair animation. */
    static let magicEraserDuration = 0.5
    /** The duration of the move animation. The actual duration of an animation will be this value times the `intValue` of the `Tile` type being moved. */
    static let moveDuration = 0.12
    /** The duration of the grow animation associated with the magic tile. */
    static let magicTileDuration = 0.25
    
    /** This listener will be notified when the `TileAnimator` instances complete a batch of animations. */
    var allAnimationsCompleteListener: AllAnimationsCompleteListener?
    
    /** `true` if and only if at least one instance of `TileAnimator` is currently running an animation. */
    var hasAnimation: Bool {
        return animationCounter != 0
    }
    /** The total number of animations currently being run by all instances of `TileAnimator`. */
    private var animationCounter = 0;
    /** The current type of animation being run by instances of `TileAnimator`, or `nil` if no animations are being run. */
    private var currentAnimationType: TypedAnimation?
    
    /**
     The animations that `self` is waiting to execute in the order they should be executed.
     - note: This may not be the actual order the animations are executed in if a different instance of `TileAnimator` has a different priority for the same animation types.
     */
    private var animationsToExecute = Array<TypedAnimation>()
    
    private var moveCount = 0
    
    weak var boardView: BoardView?
    
    var allowTouchesDuringAnimation = false
    
    
    // MARK: Initialization
    
    /**
     Initializes `self` to animate a specified view and background.
     - requires: `backgroundView` is the same size as `viewToAnimate` and is placed directly behind it on the display.
     - parameters:
     - viewToAnimate: The view that `self` should animate and update the image display of.
     - backgroundView: A view that has been set up to be directly behind `viewToAnimate`.
     */
    init(boardView: BoardView) {
        self.boardView = boardView
    }
    
    
    // MARK: Functions
    
    /**
     Called after `self` completes an animation. Starts the next animation (if any) if its type matches `TileAnimator.currenAnimationType`.
     - returns: `true` if and only if this call removed `self` from `TileAnimator.requestedNotification`.
     */
    private func onPreviousCompleted() {
        if animationsToExecute.isEmpty {
            allAnimationsCompleteListener?.onAllAnimationsComplete()
        } else {
            var i = 0
            while i < animationsToExecute.count {
                let animation = animationsToExecute[i]
                if (requestStartAnimation(animation)) {
                    animationsToExecute.removeAtIndex(i)
                    i -= 1
                } else {
                    // To counteract the animation being re-added by requestStartAnimation.
                    animationsToExecute.removeLast()
                }
                i += 1
            }
        }
    }
    
    /**
     Starts a specified `TypedAnimation` if it is the type currently animated by `TileAnimator`. Otherwise, it will be executed when the type is a match.
     - parameters:
     - typedAnimation: The `TypedAnimation` that `self` should execute.
     - returns: `true` is the `TypedAnimation` will be executed immediately, `false` if it will be executed later.
     */
    private func requestStartAnimation(typedAnimation: TypedAnimation) -> Bool {
        if !self.hasAnimation && !allowTouchesDuringAnimation {
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        }
        
        if (currentAnimationType == nil) {
            if typedAnimation.type == .Connected {
                // Playing this here so it doesn't overlap with move sound.
                MediaPlayer.playMP3Sound(MediaPlayer.linkMadeSoundLocation)
            }
            currentAnimationType = typedAnimation
            typedAnimation.play(self)
            animationCounter += 1
            return true
        } else if (typedAnimation == currentAnimationType!) {
            typedAnimation.play(self)
            animationCounter += 1
            return true
        } else {
            animationsToExecute.append(typedAnimation)
            return false
        }
    }
    
    
    // MARK: BoardListener
    
    private func generalChange(type: ChangeType, location: Int, before: Tile, after: Tile) {
        let animation = TypedAnimation(type: type, animation: nil, locationOfButton: location)
        animation.oldImage = ImageManager.imageForTile(after)
        animation.oldHighlightedImage = ImageManager.highlightedImageForTile(after)
        requestStartAnimation(animation)
    }
    
    func tileSet(location: Int, before: Tile, after: Tile) {
        generalChange(.Set, location: location, before: before, after: after)
    }
    
    func tileRepaired(location: Int, before: Tile, after: Tile) {
        let fadein = CABasicAnimation(keyPath: "opacity")
        fadein.duration = BoardController.magicEraserDuration
        fadein.fromValue = 0.0
        fadein.toValue = 1.0
        
        let animation = TypedAnimation(type: .Repaired, animation: fadein, locationOfButton: location)
        animation.oldImage = ImageManager.imageForName("board_empty")
        animation.backgroundImage = ImageManager.imageForName("board_tile_repairing")
        requestStartAnimation(animation)
    }
    
    func tileMagicWanded(location: Int, before: Tile, after: Tile) {
        let grow = CABasicAnimation(keyPath: "transform")
        grow.duration = BoardController.magicTileDuration
        var tr = CATransform3DIdentity
        tr = CATransform3DScale(tr, 0.01, 0.01, 1);
        grow.fromValue = NSValue(CATransform3D: tr)
        grow.toValue = NSValue(CATransform3D: CATransform3DIdentity)
        
        let animation = TypedAnimation(type: .MagicTiled, animation: grow, locationOfButton: location)
        animation.oldImage = ImageManager.imageForTile(after)
        requestStartAnimation(animation)
    }
    
    func tileMoved(location: Int, before: Tile, after: Tile) {
        if before.isNumber {
            let shrink = CABasicAnimation(keyPath: "transform")
            shrink.duration = BoardController.moveDuration * Double(before.intValue!)
            var tr = CATransform3DIdentity
            tr = CATransform3DScale(tr, 0.01, 0.01, 1);
            shrink.toValue = NSValue(CATransform3D: tr)
            
            let animation = TypedAnimation(type: .Moved, animation: shrink, locationOfButton: location)
            animation.shrink = true
            animation.oldImage = ImageManager.imageForTile(before)
            animation.newImage = ImageManager.imageForName("board_empty")
            animation.play(self)
        } else {
            let grow = CABasicAnimation(keyPath: "transform")
            grow.duration = BoardController.moveDuration
            var tr = CATransform3DIdentity
            tr = CATransform3DScale(tr, 0.01, 0.01, 1);
            grow.fromValue = NSValue(CATransform3D: tr)
            grow.toValue = NSValue(CATransform3D: CATransform3DIdentity)
            
            moveCount += 1
            var type = ChangeType.Moved1
            switch moveCount {
            case 2: type = .Moved2
            case 3: type = .Moved3
            default: break
            }
            let animation = TypedAnimation(type: type, animation: grow, locationOfButton: location)
            animation.oldImage = ImageManager.imageForTile(after)
            //animation.delay = BoardController.moveDuration * Double(moveCount) - BoardController.moveDuration
            requestStartAnimation(animation)
        }
    }
    
    func tileLinked(location: Int, before: Tile, after: Tile) {
        let fadeout = CABasicAnimation(keyPath: "opacity")
        fadeout.duration = BoardController.connectFadeoutDuration
        fadeout.fromValue = 1.0
        fadeout.toValue = 0.0
        
        let animation = TypedAnimation(type: .Connected, animation: fadeout, locationOfButton: location)
        animation.fadeout = true
        animation.oldImage = ImageManager.linkedImageForTile(before)
        animation.newImage = ImageManager.imageForName("board_empty")
        
        requestStartAnimation(animation)
    }
    
    func tileCleared(location: Int, before: Tile, after: Tile) {
        boardView?.tileButtonArray[location].setImage(ImageManager.imageForTile(after), forState: .Normal)
        boardView?.tileButtonArray[location].setImage(ImageManager.highlightedImageForTile(after), forState: .Highlighted)
    }
    
    func tileTimeStepped(location: Int, before: Tile, after: Tile) {
        if after == .Broken {
            let fadeout = CABasicAnimation(keyPath: "opacity")
            fadeout.duration = 0.1
            fadeout.fromValue = 1.0
            fadeout.toValue = 0.0
            fadeout.repeatCount = 4
            
            boardView?.backgroundTileButtonArray[location].setImage(nil, forState: .Normal)
            boardView?.backgroundTileButtonArray[location].setImage(nil, forState: .Highlighted)
            boardView?.tileButtonArray[location].setImage(ImageManager.imageForName("board_tile_breaking"), forState: .Normal)
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                self.boardView?.tileButtonArray[location].setImage(ImageManager.imageForName("board_broken"), forState: .Normal)
                self.boardView?.tileButtonArray[location].setImage(ImageManager.imageForName("board_broken"), forState: .Highlighted)
            })
            boardView?.tileButtonArray[location].layer.addAnimation(fadeout, forKey: "opacity")
            CATransaction.commit()
        } else if before != .Full8 {
            // else if instead of else because .Full10 and .Full9 display the same image anyway. If changed to else, path tiles would appear too soon on move animation if time advanced immediately after a move (before the animation completed).
            boardView?.tileButtonArray[location].setImage(ImageManager.imageForTile(after), forState: .Normal)
            boardView?.tileButtonArray[location].setImage(ImageManager.imageForTile(after), forState: .Highlighted)
        }
    }
    
    
    // MARK: RefillListener
    
    func tileRefilled(location: Int, after: Tile) {
        let fadein = CABasicAnimation(keyPath: "opacity")
        fadein.duration = BoardController.rebuildDuration
        fadein.fromValue = 0.0
        fadein.toValue = 1.0
        
        let animation = TypedAnimation(type: .Set, animation: fadein, locationOfButton: location)
        animation.oldImage = ImageManager.imageForTile(after)
        animation.oldHighlightedImage = ImageManager.highlightedImageForTile(after)

        requestStartAnimation(animation)
    }
    
    func tileSet(location: Int, after: Tile) {
        let animation = TypedAnimation(type: .Set, animation: nil, locationOfButton: location)
        animation.oldImage = ImageManager.imageForTile(after)
        animation.oldHighlightedImage = ImageManager.highlightedImageForTile(after)
        requestStartAnimation(animation)
    }
    
    
    // MARK: Bad Move Animation
    
    /** Can be called to run an animation that indicates to the user that the move they tried to make was invalid. */
    func animateBadMove(location: Int) {
        let duration = 0.1
        let radiansToRotate = 0.2
        let rotate = CABasicAnimation(keyPath: "transform.rotation.z")
        rotate.duration = duration
        rotate.fromValue = -radiansToRotate
        rotate.toValue = radiansToRotate
        rotate.autoreverses = true
        rotate.repeatCount = 3
        boardView?.tileButtonArray[location].layer.addAnimation(rotate, forKey: "transform.rotation.z")
    }
    
    // MARK: Shuffle Animation
    
    func animateShuffle(board: Board, boardCopy: Board) {
        var initialFrames = Array<CGRect>(count: board.totalTiles, repeatedValue: CGRect())
        var newFrames = Array<CGRect>(count: board.totalTiles, repeatedValue: CGRect())
        var markedTiles = Array<Bool>(count: boardCopy.totalTiles, repeatedValue: false)
        
        for i in 0..<board.totalTiles {
            for j in 0..<board.totalTiles {
                if board[i] == boardCopy[j] && !markedTiles[j] {
                    initialFrames[j] = ((board.boardListener as? BoardController)?.boardView?.tileButtonArray[j].frame)!
                    newFrames[j] = ((board.boardListener as? BoardController)?.boardView?.tileButtonArray[i].frame)!
                    markedTiles[j] = true
                    break
                }
            }
        }
        
        for i in 0..<board.totalTiles {
            ((board.boardListener as? BoardController)?.boardView?.backgroundTileButtonArray[i])!.setImage(ImageManager.imageForTile(boardCopy[i]), forState: .Normal)
            ((board.boardListener as? BoardController)?.boardView?.tileButtonArray[i])!.setImage(nil, forState: .Normal)
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            UIView.animateWithDuration(2.5, delay: 0, options: .CurveEaseInOut, animations: {
                ((board.boardListener as? BoardController)?.boardView?.backgroundTileButtonArray[i])!.frame = newFrames[i]
                }, completion: { _ in
                    ((board.boardListener as? BoardController)?.boardView?.tileButtonArray[i])!.setImage(ImageManager.imageForTile(board[i]), forState: .Normal)
                    ((board.boardListener as? BoardController)?.boardView?.backgroundTileButtonArray[i])!.setImage(nil, forState: .Normal)
                    ((board.boardListener as? BoardController)?.boardView?.backgroundTileButtonArray[i])!.frame = initialFrames[i]
                    
                    ((board.boardListener as? BoardController)?.boardView?.tileButtonArray[i])!.setImage(ImageManager.highlightedImageForTile(board[i]), forState: .Highlighted)
                    if UIApplication.sharedApplication().isIgnoringInteractionEvents() {
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    }
                    
                    if i == board.totalTiles - 1 {
                        self.allAnimationsCompleteListener?.onAllAnimationsComplete()
                    }
            })
        }
    }
    
}

/** Helper class for `TileAnimator` that stores a `CABasicAnimation` and other information about requirements of `TileAnimator`-specific animations. Used to simplify the process of animating `Board` tiles. */
private class TypedAnimation {
    
    // MARK: Properties
    
    /** The "type" of `self`. Other `TypedAnimation`s with the equal `type`s are considered equal to `self`. */
    let type: ChangeType
    /** The animation that `self` will execute when its `play` function is called. */
    let animation: CABasicAnimation?
    /** The image that should display while `animation` is playing, or `nil` if the image should be unchanged when the animation begins. */
    var oldImage: UIImage?
    /** The highlighted version of `oldImage` (if any) to display when `viewToAnimate` in the highlighted state. The highlighted state is set to match the image of `newImage` if this value is set to `nil`. */
    var oldHighlightedImage: UIImage?
    /** The image the animated view should display after `animation` completes, or `nil` if the image should be unchanged after the animation completes. */
    var newImage: UIImage?
    /** The highlighted version of `newImage` (if any) to display when `viewToAnimate` in the highlighted state. The highlighted state is set to match the image of `newImage` if this value is set to `nil`. */
    var newHighlightedImage: UIImage?
    /** The image that should be displayed in the background while `animation` is playing. `ImageHolder.emptyTileImage` by default. */
    var backgroundImage: UIImage? = ImageManager.imageForName("board_empty")
    /** The time difference (in seconds) between the time the `play` function is called and `animation` begins. `0` by default. */
    var delay = 0.0
    
    var locationOfButton: Int
    
    /** Temporary fix for the flash that occurs when a fading view resets its bounds before the completion block is activated to change its image. */
    var fadeout = false
    /** Temporary fix for the flash that occurs when a shrinking view resets its bounds before the completion block is activated to change its image. */
    var shrink  = false
    
    
    // MARK: Initialization
    
    /**
     Sole initializer.
     - parameters:
     - type: The "type" of `self`. Other `TypedAnimation`s with equal `type`s are considered equal to `self`.
     - animation: The `CABasicAnimation` that `self` will execute when its `play` function is called, or `nil` if no `CABasicAnimation` should be executed by that function call.
     */
    init(type: ChangeType, animation: CABasicAnimation?, locationOfButton: Int) {
        self.type = type;
        self.animation = animation;
        self.locationOfButton = locationOfButton
    }
    
    
    // MARK: Functions
    
    /**
     Plays `animation`. Uses the other properties of `self` to make other changes or modifications to the animation, timing, and view as necessary.
     - parameters:
     - tileAnimator: The `TileAnimator` containing the `UIButton` that should be animated.
     */
    func play(boardController: BoardController) {
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue(), {
            if self.fadeout || self.shrink {
                boardController.boardView?.tileButtonArray[self.locationOfButton].alpha = 0.0
            }
            
            if (self.oldImage != nil) {
                boardController.boardView?.tileButtonArray[self.locationOfButton].setImage(self.oldImage, forState: .Normal)
                if (self.oldHighlightedImage != nil) {
                    boardController.boardView?.tileButtonArray[self.locationOfButton].setImage(self.oldHighlightedImage, forState: .Highlighted)
                } else {
                    boardController.boardView?.tileButtonArray[self.locationOfButton].setImage(self.oldImage, forState: .Highlighted)
                }
            }
            
            if self.backgroundImage != nil {
                boardController.boardView?.backgroundTileButtonArray[self.locationOfButton].setImage(self.backgroundImage, forState: .Normal)
            }
            
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                if self.type == .Moved {
                    boardController.moveCount = 0
                }
                if self.newImage != nil {
                    boardController.boardView?.tileButtonArray[self.locationOfButton].setImage(self.newImage, forState: .Normal)
                    if (self.newHighlightedImage != nil) {
                        boardController.boardView?.tileButtonArray[self.locationOfButton].setImage(self.newHighlightedImage, forState: .Highlighted)
                    } else {
                        boardController.boardView?.tileButtonArray[self.locationOfButton].setImage(self.newImage, forState: .Highlighted)
                    }
                }
                
                boardController.boardView?.backgroundTileButtonArray[self.locationOfButton].setImage(nil, forState: .Normal)
                if self.fadeout || self.shrink {
                    boardController.boardView?.tileButtonArray[self.locationOfButton].alpha = 1.0
                }
                if !self.shrink {
                    boardController.animationCounter -= 1
                    if boardController.animationCounter == 0 {
                        boardController.currentAnimationType = nil
                        if UIApplication.sharedApplication().isIgnoringInteractionEvents() {
                            UIApplication.sharedApplication().endIgnoringInteractionEvents()
                        }
                        boardController.onPreviousCompleted()
                    }
                }
            })
            if self.animation != nil {
                if self.shrink {
                    let fadeout = CABasicAnimation(keyPath: "opacity")
                    fadeout.duration = self.animation!.duration
                    fadeout.fromValue = 1.00
                    fadeout.toValue = 0.99
                    boardController.boardView?.tileButtonArray[self.locationOfButton].layer.addAnimation(fadeout, forKey: "opacity")
                }
                boardController.boardView?.tileButtonArray[self.locationOfButton].layer.addAnimation(self.animation!, forKey: self.animation!.keyPath)
            }
            CATransaction.commit()
        })
    }
    
}

/**
 Equality check for `TypedAnimation`.
 - parameters:
 - left: A `TypedAnimation` to compare with `right` for equality.
 - right: A `TypedAnimation` to compare with `left` for equality.
 - returns: `true` if and only if `left` and `right` have equal `type`s.
 */
private func == (left: TypedAnimation, right: TypedAnimation) -> Bool {
    return left.type == right.type
}

/**
 Equality check for `TypedAnimation`.
 - parameters:
 - left: A `TypedAnimation` to compare with `right` for equality.
 - right: A `TypedAnimation` to compare with `left` for equality.
 - returns: `true` if and only if `left` and `right` have different `type`s.
 */
private func != (left: TypedAnimation, right: TypedAnimation) -> Bool {
    return !(left == right)
}

/**
 Listener protocol to allow notification when a `BoardController` completes a batch of animations.
 
 - seealso: `BoardController`
 */
protocol AllAnimationsCompleteListener {
    
    /** Called by the `BoardController` when it completes a batch of animations. */
    func onAllAnimationsComplete()
}

/** Represents the different reasons a location on a `Board` might change `Tile` type. Used in conjunction with `TileListener`. */
private enum ChangeType {
    
    case Connected, Set, Moved, Moved1, Moved2, Moved3, MagicTiled, Repaired, TimeSteped
    
}