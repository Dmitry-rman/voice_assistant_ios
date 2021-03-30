//
//  VBPlayerViewController.swift
//  VoiceBox
//
//  Created by Dmitry on 01.08.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import UIKit
import CocoaLumberjack

class VBPlayerViewController: TViewController {
    
    @IBOutlet weak var playButton: UIButton?
    @IBOutlet weak var artImage: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    
    let noConnectionMessage = NSLocalizedString("No audio", comment: "")
    let connectedMessage = NSLocalizedString("Соединение установлено", comment: "")
    
    private var musicPlayer: VBMusicServiceProtocol?{
        return VoiceBoxManager.sharedInstance.musicService
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel?.text = noConnectionMessage
        
        musicPlayer?.onConnectedChanged = { [weak self] (isConnected) in
             DispatchQueue.main.async {
                //self?.playButton?.isEnabled = isConnected
                self?.artImage?.isHidden = !isConnected
                self?.titleLabel?.text = (isConnected == true ? self?.connectedMessage : self?.noConnectionMessage)
                if isConnected == true {
                    self?.musicPlayer?.play(uri: "")
                }
             }
        }
        
        musicPlayer?.onFetchedArtWork = { [weak self] (artWorkImage)in
            DispatchQueue.main.async {
                self?.artImage?.image = artWorkImage
            }
        }
        
        musicPlayer?.onStateUpdated = { [weak self] (isPlayerPaused, trackName) in
             DispatchQueue.main.async {
                if isPlayerPaused == true {
                    self?.playButton?.setImage(R.image.play_button(), for:  .normal)
                }
                else{
                    self?.playButton?.setImage(R.image.pause_button(), for:  .normal)
                }
                self?.titleLabel?.text = trackName
            }
        }
        
        musicPlayer?.connect()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        musicPlayer?.update()
    }
    
    @IBAction func playPauseTap(_ sender: Any){
        if let isPlaying = musicPlayer?.isPlayng{
            isPlaying == true ? musicPlayer?.pause() : musicPlayer?.resume()
        }
    }
    
    deinit {
         musicPlayer?.onConnectedChanged  = nil
         musicPlayer?.onFetchedArtWork = nil
         musicPlayer?.onStateUpdated = nil
         musicPlayer?.disconnect()
         DDLogDebug("Deinit VBPLayerViewController")
    }
}
