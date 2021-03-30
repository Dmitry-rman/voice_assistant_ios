//
//  VBCurrencyProcessing.swift
//  voicebox
//
//  Created by Dmitry on 18.03.2021.
//

import Foundation

class VBCurrencyProcessing{
    //TODO: Implement currency processing
}

extension VBCurrencyProcessing : VBProcessingProtocol{
    
    func processMessage(message: String, userName: String?, completion: (processingMessageHandler?)) -> Bool {
        if message.sentenceContainsAny(phrases: "курс,доллар,валюта,юань,евро"){
            completion?( ["type" : ResponseTypeEnum.error.rawValue, "data" : "Not implemented currency request"], nil)
            return true
        }
        
        return false
    }
    
}
