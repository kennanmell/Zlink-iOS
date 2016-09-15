//
//  MediaPlayer.swift
//  Zlink
//
//  Created by Kennan Mell on 2/4/16.
//  Copyright © 2016 MegaWatt Gaming. All rights reserved.
//

import Foundation
import AVFoundation

/** `MediaPlayer` is a collection of static properties and functions that can be used to play sounds and background music. */
struct MediaPlayer {
    
    // MARK: Properties
    
    /** The location of the sound played when a player makes an invalid move. */
    static let badMoveSoundLocation = "sound_bad_move"
    
    /** The location of the sound played when a link is formed. */
    static let linkMadeSoundLocation = "sound_link_made"
    
    /** The location of the sound played when a game ends. */
    static let gameoverSoundLocation = "sound_game_over"
    
    /** The location of the sound played when a number is moved. */
    static let moveSoundLocation = "sound_move_piece"
    
    /** The location of the sound played when a tile is selected. */
    static let selectSoundLocation = "sound_select_piece"
    
    /** The location of the sound played when a button is pressed. */
    static let buttonPressSoundLocation = "sound_button_press"
    
    /** `true` if and only if background music is being played. (When this property is set, the background music is started or stopped accordingly.) */
    static var isPlayingBackgroundMusic = false {
        didSet {
            if isPlayingBackgroundMusic {
                if backgroundMusic.numberOfLoops != -1 {
                    backgroundMusic.numberOfLoops = -1
                }
                if !backgroundMusic.playing {
                    backgroundMusic.play()
                }
            } else {
                if backgroundMusic.playing {
                    backgroundMusic.pause()
                }
            }
        }
    }
    
    /** The `AVAudioPlayer` used to play background music. */
    private static var backgroundMusic = Sound.setupAudioPlayerWithFile("background_music", type: "mp3")
    // `Sound`s used to play the sounds specified by the static properties above.
    private static var badMoveSound = Sound(soundName: MediaPlayer.badMoveSoundLocation)
    private static var linkMadeSound = Sound(soundName: MediaPlayer.linkMadeSoundLocation)
    private static var gameoverSound = Sound(soundName: MediaPlayer.gameoverSoundLocation)
    private static var moveSound = Sound(soundName: MediaPlayer.moveSoundLocation)
    private static var selectSound = Sound(soundName: MediaPlayer.selectSoundLocation)
    private static var buttonPressSound = Sound(soundName: MediaPlayer.buttonPressSoundLocation)
    
    
    // MARK: Functions
    
    /**
     Plays a sound at a specified location.
     
     It is recommended to only call this function with locations specified by the static properties of `MediaPlayer`. Unexpected behavior may result from using other locations, especially if they are invalid.
     
     Unexpected behavior may also result from calling this function more than twice with the same `soundLocation` over a very short period of time.

     - parameters:
        - soundLocation: The location of the sound to play.
     */
    static func playMP3Sound(soundLocation: String) {
        if SavedData.sfxOn {
            let sound: AVAudioPlayer
            switch soundLocation {
            case badMoveSoundLocation: sound = badMoveSound.requestSound()
            case linkMadeSoundLocation: sound = linkMadeSound.requestSound()
            case gameoverSoundLocation: sound = gameoverSound.requestSound()
            case moveSoundLocation: sound = moveSound.requestSound()
            case selectSoundLocation: sound = selectSound.requestSound()
            case buttonPressSoundLocation: sound = buttonPressSound.requestSound()
            default:
                sound = Sound.setupAudioPlayerWithFile(soundLocation, type: "mp3")
                print("MediaPlayer: Playing non-native sound")
            }
            
            sound.play()
        }
    }
    
}

/** Private helper struct for MediaPlayer. Stores two `AVAudioPlayer`s representing the same sound instead of one to ensure that at least one version of the sound is always prepared to play. */
private struct Sound {
    
    // MARK: Properties
    
    /** One copy of the sound to be played. */
    private var storedSound1: AVAudioPlayer
    
    /** A second copy of the sound to be played. */
    private var storedSound2: AVAudioPlayer
    
    /** Determines which of the two stored sounds to play next. */
    private var firstLast: Bool
    
    /** The file name of the sound to be played by `self`. */
    let soundName: String
    
    
    // MARK: Initialization
    
    /**
     Returns a new `Sound` instance.
     - parameters:
        - soundName: The file path of the sound to be played.
     - requires: `soundName` is a valid file path for an MP3 sound.
     */
    init(soundName: String) {
        self.soundName = soundName
        self.firstLast = false
        self.storedSound2 = Sound.setupAudioPlayerWithFile(soundName, type:"mp3")
        self.storedSound1 = Sound.setupAudioPlayerWithFile(soundName, type:"mp3")
    }
    
    
    // MARK: Functions
    
    /**
     Returns an instance of `AVAudioPlayer` prepared to play the sound `self` stores.
     - returns: The `AVAudioPlayer` instance.
     - note: Calling this function more than 2 times over a very short period of time may result in unexpected behavior.
     */
    mutating func requestSound() -> AVAudioPlayer {
        firstLast = !firstLast
        if firstLast {
            storedSound2 = Sound.setupAudioPlayerWithFile(soundName, type:"mp3")
            return storedSound1
        } else {
            storedSound1 = Sound.setupAudioPlayerWithFile(soundName, type:"mp3")
            return storedSound2
        }
    }
    
    /**
     Creates and returns an `AVAudioPlayer` initialized with a audio from a specified file path.
     - parameters:
        - file: The file path of the sound to be created.
        - type: The type/extension of the sound to be created.
     - returns: The AVAudioPlayer.
     - requires: The passed parameters point to a valid file path.
     */
    static func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer  {
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        let url = NSURL.fileURLWithPath(path!)
        
        var audioPlayer: AVAudioPlayer
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
        } catch {
            fatalError("No media file exists at the specified path.")
        }
        
        return audioPlayer
    }
    
}