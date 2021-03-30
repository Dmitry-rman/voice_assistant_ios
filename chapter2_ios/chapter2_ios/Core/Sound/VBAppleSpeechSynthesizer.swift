//
//  VBAppleVoiceSynthesizer.swift
//  VoiceBox
//
//  Created by Dmitry on 05.08.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import Foundation
import Speech
import CocoaLumberjack

class VBAppleSpeechSynthesizer{
    
    weak var delegate: VBAudioInputDelegate?
    
    private var _synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    private var _avEngine: AVAudioEngine!
    private var _updater: CADisplayLink?
    
    private var averagePowerPeakForChannel: Float = 0.0 //0..1
    private var averagePowerDbForChannel: Float = 0.0
    
    var voiceIdentifier: String{
        return "com.apple.ttsbundle.Milena-premium"// return "com.apple.ttsbundle.Katya-premium"
    }
    
    var metering: Bool {
        return true
    }
    
    init(engine: AVAudioEngine) {
        
        _avEngine = engine
        
        showAvailableSpeechVoices()
        
        if #available(iOS 13.0, *) {
            _synthesizer.usesApplicationAudioSession = true
        }
        
        if self.metering {
            self.startMetering()
        }
    }
    
   private func showAvailableSpeechVoices(){
        let speechVoices = AVSpeechSynthesisVoice.speechVoices()
        for voice in speechVoices{
            print("\(voice.identifier) \(voice.name) \(voice.quality) \(voice.language)")
        }
    }
    
    private func printAudioInfo(format: AVAudioFormat){
         DDLogDebug("Sample Rate: \(format.sampleRate)")
         DDLogDebug("Channel Count: \(format.channelCount)")
         DDLogDebug("Common format: \(format.commonFormat)")
     }
    
    private func audioMetering(buffer: AVAudioPCMBuffer) {
         
         let channelDataValue = buffer.int16ChannelData!.pointee
         let channelDataValueArray = stride(from: 0, to: Int(buffer.frameLength), by: buffer.stride).map{Float(channelDataValue[$0])/255.0}
    
         var rms: Float = 0.0
         if buffer.frameLength != 0 {
            rms = sqrt(channelDataValueArray.map{$0 * $0}.reduce(0, +)/Float(buffer.frameLength))
         }
        
         averagePowerPeakForChannel = rms/30
     }
    
    @objc public func updateMeter()
    {
        let power = averagePowerPeakForChannel
        delegate?.audioInputMeterDidUpdate?(peakLevel:power, db: false)
    }
    
    private func startMetering()
    {
        _updater = CADisplayLink(target: self, selector: #selector(updateMeter))
        _updater?.add(to: RunLoop.current, forMode: .default)
        _updater?.isPaused = true
    }
    
    private func stopMetering()
    {
        _updater?.isPaused = true
    }
    
    //MARK: -
    
    deinit {
        stopSynthesize()
        _updater?.invalidate()
    }
}

extension VBAppleSpeechSynthesizer : VBSpeechSynthesizerProtocol{
    
    func sythesizeVoice(text: String, completion: ((Error?) -> ())?) {
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.5
        utterance.voice = AVSpeechSynthesisVoice.init(identifier: self.voiceIdentifier)
        _synthesizer.speak(utterance)
        
        //TO DO: Implement audio metering here..
        
        completion?(nil)
    }
    
    func stopSynthesize() {
        _synthesizer.stopSpeaking(at: .immediate)
        if (_avEngine.isRunning) {
            _avEngine.stop()
            _avEngine.reset()
        }
    }
    
    func pauseSpeaking() {
        _synthesizer.pauseSpeaking(at: .immediate)
    }
}
