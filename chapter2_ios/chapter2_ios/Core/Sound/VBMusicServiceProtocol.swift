//
//  VBMusicServiceProtocol.swift
//  VoiceBox
//
//  Created by Dmitry on 01.08.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import UIKit

protocol VBMusicServiceProtocol : class{
    
    var isPlayng: Bool {get}
    
    func disconnect()
    func resume()
    func pause()
    func connect()
    func next(play: Bool)
    func prev(play: Bool)
    func update()
    func play(uri: String)
    
    var onConnectedChanged: ((_ isConnected: Bool)->())? { get set }
    var onFetchedArtWork: ((_ artWork: UIImage)->())? { get set }
    var onStateUpdated: ((_ isPlayerPaused: Bool, _ trackName: String)->())?{ get set }
}
