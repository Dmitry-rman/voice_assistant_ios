//
//  VBHomeKitProcessing.swift
//  voicebox
//
//  Created by Dmitry on 18.03.2021.
//

import Foundation
import HomeKit

class VBHomeKitProcessing : VBProcessingProtocol{
    
    private var _homeKitManager: VBHomeKitManager{
        return  VBHomeKitManager.sharedInstance
    }
    
    func processMessage(message: String, userName: String?, completion: (processingMessageHandler?)) -> Bool {
        
        if message.sentenceContainsAll(phrases: "свет,выключи"){
            if changeLight(state: false) {
                completion?(["type": ResponseTypeEnum.message.rawValue, "data" : "Выключаю свет.."], nil)
            }else{
                completion?(["type": ResponseTypeEnum.message.rawValue, "data" : "Ошибка автоматизации включения света.."], nil)
            }
            return true
        }else if message.sentenceContainsAll(phrases: "свет") {
            if changeLight(state: true) {
               completion?(["type": ResponseTypeEnum.message.rawValue, "data" : "Включаю свет.."], nil)
            }else{
                completion?(["type": ResponseTypeEnum.message.rawValue, "data" : "Ошибка автоматизации выключении света.."], nil)
            }
            return true
        }
         
         return false
    }
    
    
    //MARK: -
    
    private func changeLight(state: Bool) -> Bool{
        
        var automationCount = 0
        var rooms: [String: HMRoom] = [:]
    
        _homeKitManager.allLightAccessories.forEach { (light) in
            if let room = light.room{
                if rooms[room.uniqueIdentifier.uuidString] == nil {
                    rooms[room.uniqueIdentifier.uuidString] = room
                }
            }
            if _homeKitManager.changeLightState(accessory: light, state: true) == true {
                automationCount += 1
            }
        }
        //let roomsNames =  rooms.values.map{$0.name}.joined(separator: " ")
        return automationCount > 0
    }
    
}
