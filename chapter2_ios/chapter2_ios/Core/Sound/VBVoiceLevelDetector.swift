
//  Created by Dmitry on 12/08/2019.
//  Copyright © 2019 Dmitry. All rights reserved.
//

import Foundation
import CocoaLumberjack

protocol VBVoiceLevelDetectorProtocol {
    func resetCalibration()
    func resetVoice()
    func process(level: Float)
    var delegate: VBVoiceLevelDetectorDelegate? {get set}
    var isCalibrated: Bool {get}
}

protocol VBVoiceLevelDetectorDelegate : class{
    func voiceDisappeared()
    func voiceCalibrated(level: Float)
}

class VBVoiceLevelDetector{
    
    private var _isVoiceFound = false
    private let _maxCaibrationCount = 32//выборка калибровки, влияет на длительность процесса калибровки назкого уровня звука
    private var _minVoiceLevelTimer: Timer?
    private let _minVoiceLevelTimeout = 1.0
    private var _calibrationNumber = 0
    private let _voiceLevelThreshold: Float = 0.1 //% процент нечувствительности уровня звука
    private var _startVoiceLevel: Float?
    
    weak var delegate: VBVoiceLevelDetectorDelegate?
    
    private func calibrate(level: Float){
        if let oldLevel = _startVoiceLevel {
                   _startVoiceLevel = (oldLevel + level)/2
               }
               else{
                   _startVoiceLevel = level
               }
               _calibrationNumber += 1
               
               if isCalibrated == true{
                 delegate?.voiceCalibrated(level: _startVoiceLevel ?? 0)
               }
    }
    
    private func startVoiceDetectionTimer(){
        
        stopVoiceDetectionTimer()
        DDLogDebug("startVoiceDetectionTimer")
        
        DispatchQueue.main.async { [unowned self] in
            _minVoiceLevelTimer = Timer.scheduledTimer(withTimeInterval: self._minVoiceLevelTimeout, repeats: false){ [weak self] (timer) in
                self?.delegate?.voiceDisappeared()
                self?.stopVoiceDetectionTimer()
            }
        }
    }
    
    private func stopVoiceDetectionTimer(){
        DDLogDebug("stopVoiceDetectionTimer")
        _minVoiceLevelTimer?.invalidate()
        _minVoiceLevelTimer = nil
    }
    
    deinit {
        stopVoiceDetectionTimer()
    }
}

extension VBVoiceLevelDetector : VBVoiceLevelDetectorProtocol{
    
    var isCalibrated: Bool{
       return _calibrationNumber >= _maxCaibrationCount
    }
    
    func resetCalibration(){
        _startVoiceLevel = nil
        _calibrationNumber = 0
    }
    
    func resetVoice(){
        _isVoiceFound = false
    }
    
    func process(level: Float){
        
        //DDLogDebug(level)
        
        if isCalibrated == true{
            if let startSoundLevel = _startVoiceLevel{
                let minLevel = startSoundLevel*(1.0 - _voiceLevelThreshold)
                
                if level > minLevel{
                    _isVoiceFound = true
                }
                
                if _isVoiceFound == true {
                   if _minVoiceLevelTimer == nil, level < minLevel{
                       DDLogDebug("\(level) < \(minLevel)")
                       startVoiceDetectionTimer()
                   }else if _minVoiceLevelTimer != nil, level >= minLevel{
                       DDLogDebug("\(level) >= \(minLevel)")
                       stopVoiceDetectionTimer()
                   }
                }
            }
        }
        else{
            calibrate(level: level)
        }
    }
}
