//
//  VBAppleMusicPlayer.swift
//  voicebox
//
//  Created by Dmitry on 17.03.2021.
//

import UIKit
import MediaPlayer

class VBAppleMusicPlayer{
    
    private var _onConnectedChanged: ((_ isConnected: Bool)->())?
    private var _onFetchedArtWork: ((_ artWork: UIImage)->())?
    private var _onStateUpdated: ((_ isPlayerPaused: Bool, _ trackName: String)->())?
    
    private let _appleMusicPlayer = MPMusicPlayerApplicationController.applicationQueuePlayer
    
    private let _queue = DispatchQueue.global(qos: .userInitiated)
}

extension VBAppleMusicPlayer : VBMusicServiceProtocol{
    
    var isPlayng: Bool {
        return _appleMusicPlayer.playbackState == .playing
    }

    func disconnect() {
        
    }
    
    func pause() {
        _queue.async { [weak self] in
            self?._appleMusicPlayer.pause()
        }
    }
    
    func resume() {
        _queue.async { [weak self] in
            self?._appleMusicPlayer.setQueue(with: .songs())
            self?._appleMusicPlayer.play()
        }

    }
    
    func connect() {
        
    }
    
    func update() {
        
    }
    
    func next(play: Bool){
        _queue.async { [weak self] in
            self?._appleMusicPlayer.skipToNextItem()
            self?._appleMusicPlayer.play()
        }
    }
    
    func prev(play: Bool) {
        _queue.async { [weak self] in
            self?._appleMusicPlayer.skipToPreviousItem()
            self?._appleMusicPlayer.play()
        }
    }
    
    func play(uri: String) {
       resume()
    }
    
    var onConnectedChanged: ((Bool) -> ())? {
        get {
            return _onConnectedChanged
        }
        set {
            _onConnectedChanged = newValue
        }
    }
    
    var onFetchedArtWork: ((UIImage) -> ())? {
        get {
             return _onFetchedArtWork
        }
        set {
            _onFetchedArtWork = newValue
        }
    }
    
    var onStateUpdated: ((_ isPlayerPaused: Bool, _ trackName: String)->())? {
        get {
            return _onStateUpdated
        }
        set{
            _onStateUpdated = newValue
        }
    }
}
