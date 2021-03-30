//
//  VBWeatherProcessing.swift
//  voicebox
//
//  Created by Dmitry on 18.03.2021.
//

import Foundation

class VBWeatherProcessing{
    //TODO: Implement weather processing
}

extension VBWeatherProcessing : VBProcessingProtocol{
    
    func processMessage(message: String, userName: String?, completion: (processingMessageHandler?)) -> Bool {
        
        if message.sentenceContainsAny(phrases: "погода,погоды,прогноз,улиц,дождь,ветер,температура,погоду"){
            completion?( ["type" : ResponseTypeEnum.error.rawValue, "data" : "Not implemented weather request"], nil)
            return true
        }
        return false
    }

}
