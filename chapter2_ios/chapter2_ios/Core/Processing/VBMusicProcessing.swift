//
//  VBMusicProcessing.swift
//  voicebox
//
//  Created by Dmitry on 17.03.2021.
//

import Foundation

class VBMusicProcessing : VBProcessingProtocol{
    
    private(set) var musicService: VBMusicServiceProtocol?
    
    init(musicService: VBMusicServiceProtocol) {
        self.musicService = musicService
    }
    
    func processMessage(message: String, userName: String?, completion: (processingMessageHandler?)) -> Bool {
        if message.sentenceContainsAny(phrases: "музыка,песни,включи музыку"){
            musicService?.resume()
            completion?(["type": ResponseTypeEnum.message.rawValue, "data" : "Включаю музыку.."], nil)
            return true
        }
        else if message.sentenceContainsAny(phrases: "следующая,далее,смени песню"){
            musicService?.next(play: true)
            completion?(["type": ResponseTypeEnum.message.rawValue, "data" : "Следующая песня включена.."], nil)
            return true
        }
        else if message.sentenceContainsAny(phrases: "предыдущая"){
            musicService?.prev(play: true)
            completion?(["type": ResponseTypeEnum.message.rawValue, "data" : "Предыдущая песня включена.."], nil)
            return true
        }
        else if message.sentenceContainsAny(phrases: "останови,стоп,пауза,останови музыку"){
             musicService?.pause()
             completion?(["type": ResponseTypeEnum.message.rawValue, "data" : "Выключаю музыку.."], nil)
             return true
        }
        
        return false
    }
    
}
