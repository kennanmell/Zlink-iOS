//
//  TutorialController.swift
//  Zlink
//
//  Created by Kennan Mell on 2/6/16.
//  Copyright © 2016 MegaWatt Gaming. All rights reserved.
//

import UIKit

/**
 `TutorialController` manages the scene that walks the user through the basics of playing Zlink. 
 
 - seealso: `TutorialSceneView`, `TutorialScene1View`, `TutorialScene5View`
 */
class TutorialController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    static let ID = "Tutorial"
    
    /** The length (tiles per row) of each `Board` used in the tutorial. */
    static let boardLength = 6
    
    // MARK: Properties
    private(set) var orderedViewControllers = Array<UIViewController>()
    
    var applicationIsActive = true {
        didSet {
            if orderedViewControllers[pageControl.currentPage] is TutorialSceneControllerBase {
                (orderedViewControllers[pageControl.currentPage] as! TutorialSceneControllerBase).applicationIsActive = applicationIsActive
            }
        }
    }
    
    var menuIsOpen = false {
        didSet {
            if orderedViewControllers[pageControl.currentPage] is TutorialSceneControllerBase {
                (orderedViewControllers[pageControl.currentPage] as! TutorialSceneControllerBase).menuIsOpen = menuIsOpen
            }
        }
    }
    
    private var pageControl = UIPageControl()
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        super.init(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        
        self.automaticallyAdjustsScrollViewInsets = false

        orderedViewControllers.append(TutorialScene1Controller(coder: coder)!)
        orderedViewControllers.append(TutorialScene2Controller(coder: coder)!)
        orderedViewControllers.append(TutorialScene3Controller(coder: coder)!)
        orderedViewControllers.append(TutorialScene4Controller(coder: coder)!)
        orderedViewControllers.append(TutorialScene5Controller(coder: coder)!)
        
        pageControl.numberOfPages = orderedViewControllers.count
        pageControl.userInteractionEnabled = false
        pageControl.pageIndicatorTintColor = UIColor(red: 176.0 / 255.0, green: 176.0 / 255.0, blue: 176.0 / 255.0, alpha: 1.0)
        pageControl.currentPageIndicatorTintColor = UIColor(red: 64.0 / 255.0, green: 64.0 / 255.0, blue: 64.0 / 255.0, alpha: 1.0)
    }
    
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        ((orderedViewControllers[4] as! TutorialScene5Controller).view as! TutorialScene5View).playButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TutorialController.playClicked)))
        
        setViewControllers([orderedViewControllers[0]], direction: .Forward, animated: true, completion: nil)
        
        self.view.addSubview(pageControl)
        pageControl.frame = CGRect(x: self.view.frame.width / 2 - pageControl.frame.width / 2, y: self.view.frame.height - self.view.frame.height / 20, width: pageControl.frame.width, height: pageControl.frame.height)
        self.view.bringSubviewToFront(pageControl)
    }
    
    // MARK: Play Button Delegate
    
    /** Called when the user clicks the play button. */
    func playClicked() {
        MediaPlayer.playMP3Sound(MediaPlayer.buttonPressSoundLocation)
        mainController.setViewController(PlayController.ID)
    }

    
    // MARK: UIPageViewControllerDataSource
    
    func pageViewController(pageViewController: UIPageViewController,
        viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
                return nil
            }
            
            let previousIndex = viewControllerIndex - 1
            
            guard previousIndex >= 0 else {
                return nil
            }
            
            guard orderedViewControllers.count > previousIndex else {
                return nil
            }
            
            return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(pageViewController: UIPageViewController,
        viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
                return nil
            }
            
            let nextIndex = viewControllerIndex + 1
            let orderedViewControllersCount = orderedViewControllers.count
            
            guard orderedViewControllersCount != nextIndex else {
                return nil
            }
            
            guard orderedViewControllersCount > nextIndex else {
                return nil
            }
            
            return orderedViewControllers[nextIndex]
    }
    
    
    // MARK: UIPageViewControllerDelegate
    
    func pageViewController(pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool) {
            if let firstViewController = viewControllers?.first,
                let index = orderedViewControllers.indexOf(firstViewController) {
                    pageControl.currentPage = index
            }
    }
    
}


// MARK: TutorialSceneControllerBase

private class TutorialSceneControllerBase: UIViewController {
    
    private let standardMoveDuration = BoardController.moveDuration
    
    private var currentFingerLocation = 0
    
    private var board: Board!
    
    private var instructions = Array<Instruction>()
    
    private var shouldRunNextInstruction = true
    
    private var runningInstruction = false
    
    var applicationIsActive = true {
        didSet {
            if demoActive {
                runInstruction()
            }
        }
    }
    
    var menuIsOpen = false {
        didSet {
            if demoActive {
                runInstruction()
            }
        }
    }
    
    private var demoActive: Bool {
        return shouldRunNextInstruction && applicationIsActive && !menuIsOpen
    }
    
    private func fillInstructions() {
        instructions = Array<Instruction>()
        
        let additionalInstructions = customInstructions()
        if additionalInstructions != nil {
            instructions.appendContentsOf(additionalInstructions!)
        }
    }
    
    func initialBoard() -> Board {
        let result = Board(rowLength: TutorialController.boardLength)
        for i in 0..<result.totalTiles {
            result[i] = .Empty
        }
        return result
    }
    
    /** Can be overridden to include custom instructions for the board view of `self` to execute in a loop. Instructions are run one at a time, with the exception of moving a tile, which immediately calls the next instruction after starting an animation. In this way, it is possible for the finger to "trace" the move if it is told to move directly after the tile is told to move. Inversely, a tile to be compressed should be compressed only after telling the finger to double-tap. */
    func customInstructions() -> Array<Instruction>? {
        return nil
    }
    
    func fingerVisible() -> Bool {
        return true
    }
    
    func topText() -> String? {
        return nil
    }
    
    func bottomText() -> String? {
        return nil
    }
    
    private func runInstruction() {
        if !instructions.isEmpty && !runningInstruction {
            runningInstruction = true
            let instruction = instructions.removeFirst()
            
            switch instruction.type {
            case .Wait:
                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(instruction.duration * Double(NSEC_PER_SEC)))
                dispatch_after(time, dispatch_get_main_queue(), {
                    self.afterRunInstruction()
                })
            case .MoveTile:
                if !board.moveTile(instruction.location, inDirection: instruction.direction) {
                    MediaPlayer.playMP3Sound(MediaPlayer.badMoveSoundLocation)
                    (board.boardListener as! BoardController).animateBadMove(instruction.location)
                } else {
                    MediaPlayer.playMP3Sound(MediaPlayer.moveSoundLocation)
                }
                afterRunInstruction()
            case .MoveFinger:
                let location = instruction.location
                let finger = (self.view as! TutorialSceneView).fingerImage
                let newFrame = fingerFrameForLocation(location)
                let duration: Double
                if instruction.direction == .Up {
                    // Want fast duration.
                    duration = standardMoveDuration * pythagoreanDistance(fromLocation: currentFingerLocation, toLocation: location)
                } else {
                    // Want slow duration.
                    duration = standardMoveDuration * pythagoreanDistance(fromLocation: currentFingerLocation, toLocation: location) * 2
                }
                currentFingerLocation = location
                UIView.animateWithDuration(duration, delay: 0, options: .CurveEaseInOut, animations: {
                    finger.frame = newFrame
                    }, completion: { _ in
                        finger.frame = newFrame
                        self.afterRunInstruction()
                })
            case .CheckConnections:
                board.removeLinks()
                afterRunInstruction()
            case .StepTime:
                board.stepTime()
                afterRunInstruction()
            case .BounceFinger:
                let finger = (self.view as! TutorialSceneView).fingerImage
                let boardView = (self.view as! TutorialSceneView).boardView
                UIView.animateWithDuration(0.1, delay: 0, options: .CurveEaseInOut, animations: {
                    finger.frame.origin.y -= boardView.tileButtonArray[0].frame.width / 4
                    }, completion: { _ in
                        UIView.animateWithDuration(0.1, delay: 0, options: .CurveEaseInOut, animations: {
                            finger.frame.origin.y += boardView.tileButtonArray[0].frame.width / 4
                            }, completion: { _ in
                                self.afterRunInstruction()
                        })
                })
            case .ShowBottomText:
                UIView.animateWithDuration(1.0, animations: {
                    (self.view as! TutorialSceneView).bottomTextLabel.alpha = 1.0
                })
                afterRunInstruction()
            }
        }
    }
    
    private func afterRunInstruction() {
        runningInstruction = false
        if instructions.isEmpty {
            let startBoard = initialBoard()
            for i in 0..<board.totalTiles {
                if startBoard[i] != .Broken {
                    board[i] = startBoard[i]
                }
            }
            fillInstructions()
        }
        if demoActive {
            runInstruction()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let sceneView = TutorialSceneView(coder: aDecoder)!
        self.view = sceneView
        self.board = initialBoard()
        if !fingerVisible() {
            sceneView.fingerImage.hidden = true
        }
        sceneView.topTextLabel.text = topText()
        sceneView.bottomTextLabel.text = bottomText()
        
        for i in 0..<board.totalTiles {
            sceneView.boardView.tileButtonArray[i].setImage(ImageManager.imageForTile(board[i]), forState: .Normal)
        }
        
        let startBoard = initialBoard()
        for i in 0..<board.totalTiles {
            board[i] = startBoard[i]
        }
        
        fillInstructions()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let boardView = (self.view as! TutorialSceneView).boardView
        
        let boardController = BoardController(boardView: boardView)
        boardController.allowTouchesDuringAnimation = true
        board.boardListener = boardController
        
        for i in 0..<board.totalTiles {
            board[i] = board[i]
        }
        
        shouldRunNextInstruction = true
    }
        
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue(), {
            self.runInstruction()
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        shouldRunNextInstruction = false
    }
    
    private func fingerFrameForLocation(location: Int) -> CGRect {
        let board = (self.view as! TutorialSceneView).boardView
        let finger = (self.view as! TutorialSceneView).fingerImage
        
        let tileViewFrame = board.tileButtonArray[location].frame
        return CGRect(x: board.frame.origin.x + tileViewFrame.origin.x + tileViewFrame.width / 2 - finger.frame.width / 2, y: board.frame.origin.y + tileViewFrame.origin.y + tileViewFrame.height / 2, width: finger.frame.width, height: finger.frame.height)
    }
    
    private func pythagoreanDistance(fromLocation fromLocation: Int, toLocation: Int) -> Double {
        let xDistance = (toLocation % TutorialController.boardLength) - (fromLocation % TutorialController.boardLength)
        let yDistance = (toLocation / TutorialController.boardLength) - (fromLocation / TutorialController.boardLength)
        
        return sqrt(Double(xDistance * xDistance + yDistance * yDistance))
    }
}


// MARK: InstructionType

private enum InstructionType {
    case Wait, MoveFinger, MoveTile, CheckConnections, StepTime, BounceFinger, ShowBottomText
}


// MARK: Instruction
private struct Instruction {
    // Initialized to filler values so the initializers don't have to repetitively initialize unneeded values.
    private let type: InstructionType
    private var duration: Double = 0.0
    private var location: Int = 0
    private var direction: Direction = .Up
    private var newText = ""
    
    init(wait: Double) {
        if wait < 0 {
            fatalError("Initialized with negative wait time.")
        }
        self.type = .Wait
        self.duration = wait
    }
    
    init(moveFingerToLocation location: Int, fastDuration: Bool) {
        if location < 0 || location >= TutorialController.boardLength * TutorialController.boardLength {
            fatalError("Initialized with invalid location.")
        }
        self.type = .MoveFinger
        self.location = location
        // Uses `direction` as a boolean value to avoid having to store another property in the struct.
        if fastDuration {
            direction = .Up
        } else {
            direction = .Down
        }
    }
    
    init(moveTileAtLocation location: Int, inDirection direction: Direction) {
        if location < 0 || location >= TutorialController.boardLength * TutorialController.boardLength {
            fatalError("Initialized with invalid location.")
        }
        self.type = .MoveTile
        self.location = location
        self.direction = direction
    }
    
    init(checkBoardConnections: Bool = true) {
        self.type = .CheckConnections
    }
    
    init(stepBoardTime: Bool = true) {
        self.type = .StepTime
    }
        
    init(fadeinBottomText: Bool = true) {
        self.type = .ShowBottomText
    }
}


// MARK: TutorialScene1Controller

private class TutorialScene1Controller: UIViewController {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.view = TutorialScene1View(coder: aDecoder)!
    }
    
}


// MARK: TutorialScene2Controller

private class TutorialScene2Controller: TutorialSceneControllerBase {
    
    override func customInstructions() -> Array<Instruction>? {
        var result = Array<Instruction>()
        
        result.append(Instruction(wait: 0.25))
        
        result.append(Instruction(moveFingerToLocation: 26, fastDuration: false))
        result.append(Instruction(wait: 0.25))
        result.append(Instruction(moveTileAtLocation: 26, inDirection: .Up))
        result.append(Instruction(moveFingerToLocation: 20, fastDuration: true))
        
        result.append(Instruction(fadeinBottomText: true))
        
        result.append(Instruction(wait: 0.5))
        result.append(Instruction(moveFingerToLocation: 17, fastDuration: false))
        result.append(Instruction(wait: 0.25))
        result.append(Instruction(moveTileAtLocation: 17, inDirection: .Left))
        result.append(Instruction(moveFingerToLocation: 16, fastDuration: true))
        
        result.append(Instruction(wait: 0.5))
        result.append(Instruction(moveFingerToLocation: 9, fastDuration: false))
        result.append(Instruction(wait: 0.25))
        result.append(Instruction(moveTileAtLocation: 9, inDirection: .Right))
        result.append(Instruction(moveFingerToLocation: 10, fastDuration: true))
        
        result.append(Instruction(checkBoardConnections: true))
        
        result.append(Instruction(wait: 0.25 + BoardController.connectFadeoutDuration))
        result.append(Instruction(moveFingerToLocation: 0, fastDuration: false))
        result.append(Instruction(wait: 0.25))
        
        return result
    }
    
    override func initialBoard() -> Board {
        let result = Board(rowLength: TutorialController.boardLength)
        for i in 0..<result.totalTiles {
            result[i] = .Empty
        }
        result[19] = .Zlink1
        result[4] = .Zlink2
        result[26] = .Number3
        result[17] = .Number2
        result[9] = .Number1
        return result
    }
    
    override func topText() -> String? {
        return "Swipe a number to make that many gold tiles."
    }
    
    override func bottomText() -> String? {
        return "Make a gold path touching two Zlinks to link them!"
    }
    
}


// MARK: TutorialScene3Controller

private class TutorialScene3Controller: TutorialSceneControllerBase {
    
    override func customInstructions() -> Array<Instruction>? {
        var result = Array<Instruction>()
        
        result.append(Instruction(wait: 0.75))
        
        for _ in 0..<6 {
            // Because there are 6 turns before the initial gold tiles break.
            result.append(Instruction(stepBoardTime: true))
        }
        
        result.append(Instruction(wait: 1.0))
        result.append(Instruction(fadeinBottomText: true))
        
        result.append(Instruction(wait: 0.75))
        result.append(Instruction(moveFingerToLocation: 11, fastDuration: false))
        result.append(Instruction(wait: 0.25))
        result.append(Instruction(moveTileAtLocation: 11, inDirection: .Left))
        result.append(Instruction(moveFingerToLocation: 10, fastDuration: true))
        
        result.append(Instruction(wait: 0.5))
        result.append(Instruction(moveFingerToLocation: 2, fastDuration: false))
        result.append(Instruction(wait: 0.25))
        result.append(Instruction(moveTileAtLocation: 2, inDirection: .Down))
        result.append(Instruction(moveFingerToLocation: 8, fastDuration: true))
        
        result.append(Instruction(checkBoardConnections: true))
        
        result.append(Instruction(wait: 0.25 + BoardController.connectFadeoutDuration))
        result.append(Instruction(moveFingerToLocation: 0, fastDuration: false))
        
        return result
    }
    
    override func initialBoard() -> Board {
        let result = Board(rowLength: TutorialController.boardLength)
        for i in 0..<result.totalTiles {
            result[i] = .Empty
        }
        
        result[14] = .Full5
        result[15] = .Full5
        result[20] = .Full5
        result[21] = .Full5
        
        result[7] = .Zlink1
        result[28] = .Zlink3
        result[2] = .Number1
        result[11] = .Number2
        result[16] = .Number1
        result[22] = .Number3
        
        return result
    }
    
    override func topText() -> String? {
        return "Gold tiles left on the board for too many moves turn into black holes."
    }
    
    override func bottomText() -> String? {
        return "Links CAN include numbers, but CAN'T include black holes."
    }
}


// MARK: TutorialScene4Controller

private class TutorialScene4Controller: TutorialSceneControllerBase {
    
    override func customInstructions() -> Array<Instruction>? {
        var result = Array<Instruction>()
        
        result.append(Instruction(wait: 1.0))
        result.append(Instruction(moveFingerToLocation: 13, fastDuration: false))
        
        result.append(Instruction(fadeinBottomText: true))
        
        result.append(Instruction(wait: 0.25))
        result.append(Instruction(moveTileAtLocation: 13, inDirection: .Right))
        result.append(Instruction(moveFingerToLocation: 14, fastDuration: true))
        
        result.append(Instruction(wait: 0.5))
        result.append(Instruction(moveFingerToLocation: 13, fastDuration: false))
        result.append(Instruction(wait: 0.25))
        result.append(Instruction(moveTileAtLocation: 13, inDirection: .Down))
        result.append(Instruction(moveFingerToLocation: 19, fastDuration: true))
        
        result.append(Instruction(wait: 0.5))
        result.append(Instruction(moveFingerToLocation: 13, fastDuration: false))
        result.append(Instruction(wait: 0.25))
        result.append(Instruction(moveTileAtLocation: 13, inDirection: .Up))
        result.append(Instruction(moveFingerToLocation: 7, fastDuration: true))
        
        result.append(Instruction(wait: 0.75))
        result.append(Instruction(moveFingerToLocation: 1, fastDuration: false))
        result.append(Instruction(wait: 0.25))
        result.append(Instruction(moveTileAtLocation: 1, inDirection: .Right))
        result.append(Instruction(moveFingerToLocation: 2, fastDuration: true))
        
        result.append(Instruction(wait: 0.5))
        result.append(Instruction(moveFingerToLocation: 13, fastDuration: false))
        result.append(Instruction(wait: 0.25))
        result.append(Instruction(moveTileAtLocation: 13, inDirection: .Up))
        result.append(Instruction(moveFingerToLocation: 7, fastDuration: true))
        
        result.append(Instruction(checkBoardConnections: true))
        
        result.append(Instruction(wait: 0.25 + BoardController.connectFadeoutDuration))
        result.append(Instruction(moveFingerToLocation: 0, fastDuration: false))
        
        return result
    }
    
    override func initialBoard() -> Board {
        let result = Board(rowLength: TutorialController.boardLength)
        for i in 0..<result.totalTiles {
            result[i] = .Empty
        }
        
        result[1] = .Number3
        result[5] = .Zlink1
        result[0] = .Zlink3
        result[13] = .Number2
        result[15] = .Zlink2
        result[19] = .Broken
        return result
    }
    
    override func topText() -> String? {
        return "Numbers can't be swiped into black holes or other objects."
    }
    
    override func bottomText() -> String? {
        return "The game ends when no numbers can be swiped."
    }
}


// MARK: TutorialScene5Controller

private class TutorialScene5Controller: UIViewController {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let sceneController = TutorialScene5View(coder: aDecoder)!
        self.view = sceneController
        
        if !SavedData.stats.isTrackingGame {
            sceneController.playButton.setImage(ImageManager.imageForName("new_button"), forState: .Normal)
            sceneController.playButton.setImage(ImageManager.imageForName("new_button_highlighted"), forState: .Highlighted)
        } else {
            sceneController.playButton.setImage(ImageManager.imageForName("play_button"), forState: .Normal)
            sceneController.playButton.setImage(ImageManager.imageForName("play_button_highlighted"), forState: .Highlighted)
        }
    }
    
}