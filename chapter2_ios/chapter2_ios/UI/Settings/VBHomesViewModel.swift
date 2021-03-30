//
//  VBHomesViewModel.swift
//  VoiceBox
//
//  Created by Dmitry on 31.07.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import Foundation
import HomeKit

class VBHomesViewModel : NSObject{
    
    var onHomesUpdated: (()->())?
    var homesCount: Int{
        return VBHomeKitManager.sharedInstance.homes.count
    }
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateHomeKitNotification),
                                               name: VBHomeKitManager.vbHomeKitNotification.name,
                                               object: nil)
    }
    
    @objc private func updateHomeKitNotification(){
         onHomesUpdated?()
    }
    
    func reload(){
        VBHomeKitManager.sharedInstance.reload()
    }
    
    func homeTitle(indexPath: IndexPath) -> String{
        return VBHomeKitManager.sharedInstance.homes[indexPath.row].name
    }
    
    func home(indexPath: IndexPath) -> HMHome{
        return VBHomeKitManager.sharedInstance.homes[indexPath.row]
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: VBHomeKitManager.vbHomeKitNotification.name, object: nil)
    }
}
