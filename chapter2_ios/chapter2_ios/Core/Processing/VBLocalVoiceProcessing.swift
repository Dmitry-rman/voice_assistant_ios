//
//  BVLocalVoiceProcessing.swift
//  VoiceBox
//
//  Created by Dmitry on 31.07.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import Foundation
import CocoaLumberjack


class VBLocalVoiceProcessing{
    
    static let startMessage = "СТАРТ"
    
    private let _voiceProcessingDict: [String:Any]
    
    init() {
        if let path =  R.file.voiceProcesingPhrasesPlist.path(){
           _voiceProcessingDict = NSDictionary(contentsOfFile: path) as! [String:Any]
        }else{
            _voiceProcessingDict = Dictionary<String,Any>()
        }
    }
}

extension VBLocalVoiceProcessing: VBProcessingProtocol{
    
    func processMessage(message : String, userName: String?, completion: (processingMessageHandler?)) -> Bool{
        
        if let messagesPhrases = _voiceProcessingDict[ResponseTypeEnum.message.rawValue] as? [String:Any]{
            for phraseKeys in Array(messagesPhrases.keys){
                if message.sentenceContainsAny(phrases: phraseKeys),
                    let answer = messagesPhrases[phraseKeys] as? String{
                       completion?(getResponse(with: .message, payload: answer), nil)
                       return true
                }
            }
        }
        
        if message == VBLocalVoiceProcessing.startMessage{
            guard let startDict = _voiceProcessingDict["start"] as? [String:Any] else{
                completion?(["type": ResponseTypeEnum.error.rawValue, "data" : "Start error.."], nil)
                return true
            }
            
            let defaultMessage = "Привет!"
            if let userName = userName{
                let message = startDict["second"] as? String ?? defaultMessage
                completion?(["type": ResponseTypeEnum.message.rawValue, "data" : message.replacingOccurrences(of: "%@", with: userName)], nil)
                return true
            }
            else {
                let message = startDict["first"] as? String ?? defaultMessage
                completion?(["type": ResponseTypeEnum.message.rawValue, "data" : message], nil)
                return true
            }
        }
        else if  message.sentenceContainsAll(phrases: "меня зовут"){
            if let nameRange = message.range(of: "МЕНЯ ЗОВУТ") {
               let name = String(message.suffix(from: nameRange.upperBound))
               completion?(["type": ResponseTypeEnum.username.rawValue, "data" : name], nil)
               return true
            }
        }
        
        return false
    }
}
