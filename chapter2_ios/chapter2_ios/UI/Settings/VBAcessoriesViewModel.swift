//
//  VBAcessoriesViewModel.swift
//  VoiceBox
//
//  Created by Dmitry on 31.07.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import Foundation
import HomeKit
import CocoaLumberjack
import Bond

class VBAcessoriesViewModel : NSObject{

    private(set) var isBusy = Observable<Bool>(false)
    var onAcessoriesUpdated: (()->())?
    
    private var _home: HMHome!
    private var _acessories: [HMAccessory] = []
    
    // For discovering new accessories
    private let browser = HMAccessoryBrowser()
    private var discoveredAccessories: [HMAccessory] = []
    
    var acessoriesCount: Int{
        return _acessories.count
    }
    
    func acessoryInfo(indexPath: IndexPath) -> (String, String, Bool){
        let accessory = _acessories[indexPath.row]
        return (accessory.name, accessory.room?.name ?? "", accessory.characteristcValue)
    }
    
    convenience init(home: HMHome) {
        self.init()
        
        _home = home

    }
    
    func reload(){
        loadAccessories()
    }
    
    private func loadAccessories() {

        _acessories.removeAll()
        
      for accessory in _home.accessories {
        if let characteristic = accessory.find(serviceType: HMServiceTypeOutlet, characteristicType: HMCharacteristicMetadataFormatBool){
            DDLogDebug(characteristic.properties.description)
           _acessories.append(accessory)
           accessory.delegate = self
           characteristic.enableNotification(true) { error in
             if error != nil {
              DDLogDebug("Something went wrong when enabling notification for a chracteristic.")
            }
          }
        }
      }
      
      onAcessoriesUpdated?()
        self.isBusy.value = false
    }
    
    func discoverAccessories(){
        discoveredAccessories.removeAll()
        self.isBusy.value = true
        perform(#selector(stopDiscoveringAccessories), with: nil, afterDelay: 10)
        browser.delegate = self
        browser.startSearchingForNewAccessories()
    }
    
    func changeState(state: Bool, indexPath: IndexPath){
        let accessory = _acessories[indexPath.row]
        _ = VBHomeKitManager.sharedInstance.changeLightState(accessory: accessory, state: state)
    }
    
    @objc private func stopDiscoveringAccessories() {
        self.isBusy.value = false
        onAcessoriesUpdated?()
    }
}

extension VBAcessoriesViewModel: HMAccessoryDelegate {
  func accessory(_ accessory: HMAccessory, service: HMService, didUpdateValueFor characteristic: HMCharacteristic) {
     onAcessoriesUpdated?()
  }
}

extension VBAcessoriesViewModel: HMAccessoryBrowserDelegate {
  func accessoryBrowser(_ browser: HMAccessoryBrowser, didFindNewAccessory accessory: HMAccessory) {
     discoveredAccessories.append(accessory)
     stopDiscoveringAccessories()
  }
}

extension HMAccessory {
  func find(serviceType: String, characteristicType: String) -> HMCharacteristic? {
    return services.lazy
      .filter { $0.serviceType == serviceType }
      .flatMap { $0.characteristics }
      .first { $0.metadata?.format == characteristicType }
  }
}
