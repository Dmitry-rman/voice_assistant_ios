//
//  VBHomeKitManager.swift
//  VoiceBox
//
//  Created by Dmitry on 31.07.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import Foundation
import HomeKit
import CocoaLumberjack

extension HMAccessory {
    
    var characteristcValue: Bool{
        
        var state = false
        if let characteristic = self.find(serviceType: VBHomeKitManager.lightType, characteristicType: HMCharacteristicMetadataFormatBool),
           let value = characteristic.value as? Bool {
            state = value
        }
        
        return state
    }
}

class VBHomeKitManager: NSObject{
    
    static let sharedInstance = VBHomeKitManager()
    static let lightType = HMServiceTypeOutlet
    static let vbHomeKitNotification = Notification.init(name: Notification.Name.init(rawValue: "vbHomeKitNotification"))
    
    let homeManager = HMHomeManager()
    private(set) var homes: [HMHome] = []
    
    var allLightAccessories: [HMAccessory]{

        var array: [HMAccessory] = []
        for home in homes {
            array.append(contentsOf: allLightAccessories(for: home))
        }
        return array
    }
    
    var firstLightAcessory: HMAccessory?{
        return allLightAccessories.first
    }
    
    override init() {
        super.init()
        addHomes(homeManager.homes)
        homeManager.delegate = self
    }
    
    func reload(){
        addHomes(homeManager.homes)
    }
    
    func allLightAccessories(for home: HMHome) -> [HMAccessory]{
        var accessories: [HMAccessory] = []
        
            for acessory in home.accessories {
                if acessory.find(serviceType: VBHomeKitManager.lightType,
                                 characteristicType: HMCharacteristicMetadataFormatBool) != nil{
                    accessories.append(acessory)
                }
            }
   
        return accessories
    }
    
    func firstLightAcessory(for home: HMHome) -> HMAccessory?{
        return allLightAccessories(for: home).first
    }
    
    func changeLightState(accessory: HMAccessory, state: Bool) -> Bool{
        guard let characteristic = accessory.find(serviceType: VBHomeKitManager.lightType,
                                                  characteristicType: HMCharacteristicMetadataFormatBool) else {
          return false
        }
        
        let toggleState = !accessory.characteristcValue
        characteristic.writeValue(NSNumber(value: toggleState)) { error in
          if error != nil {
             DDLogDebug("Something went wrong when attempting to update the service characteristic.")
          }
        }
        
        return true
    }
    
    private func addHomes(_ newHomes: [HMHome]){
        homes.removeAll()
        homes.append(contentsOf: newHomes)
        NotificationCenter.default.post(name: VBHomeKitManager.vbHomeKitNotification.name, object: self)
    }
}

extension VBHomeKitManager: HMHomeManagerDelegate{

    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        addHomes(manager.homes)
    }
}
