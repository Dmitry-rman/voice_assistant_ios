//
//  VBAudioEngine.swift
//  VoiceBox
//
//  Created by Dmitry on 28.07.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import Foundation
import AVFoundation
import CocoaLumberjack

@objc protocol VBAudioInputDelegate: class {
    @objc optional func audioInputMeterDidUpdate(peakLevel: Float, db: Bool)
    func audioFinished(_ success: Bool, _ error: Error?)
}

class VBAudioEngine : NSObject{
    
    weak var delegate: VBAudioInputDelegate?
    var player: AVAudioPlayer?
    
    static let minimalVoiceDBLevel: Float = -80.0
    private var _updater: CADisplayLink?
    
    private var averagePowerPeakForChannel: Float = 0.0 //0..1
    private var averagePowerDbForChannel: Float = 0.0
    
    var metering: Bool {
        return true
    }
    
    override init(){
        super.init()
        
        if self.metering {
            self.startMetering()
        }
     }
    
    func play(buffer: AVAudioPCMBuffer){
       
        let data = VBAudioEngine.audioBufferToData(PCMBuffer: buffer)
        playData(data: data)
    }
    
    func playData(data: Data){
        
        _updater?.isPaused = false
        try? player = AVAudioPlayer.init(data: data)
        player?.isMeteringEnabled = true
        player?.play()
        player?.delegate = self
    }

     
     func stop(){
         stopMetering()
         player?.stop()
     }
     
     static internal func dataToPCMBuffer(format: AVAudioFormat, data: NSData) -> AVAudioPCMBuffer? {
         
         let audioBuffer = AVAudioPCMBuffer(pcmFormat: format,
                                            frameCapacity: UInt32(data.length) / format.streamDescription.pointee.mBytesPerFrame)
         
         audioBuffer!.frameLength = audioBuffer!.frameCapacity
         let channels = UnsafeBufferPointer(start: audioBuffer!.floatChannelData, count: Int(audioBuffer!.format.channelCount))
         data.getBytes(UnsafeMutableRawPointer(channels[0]) , length: data.length)
         return audioBuffer
     }
    
    static func audioBufferToData(PCMBuffer: AVAudioPCMBuffer) -> Data {
        let channelCount = 1  // given PCMBuffer channel count is 1
        let channels = UnsafeBufferPointer(start: PCMBuffer.int16ChannelData, count: channelCount)
        //let data = NSData(bytes: channels[0], length:Int(PCMBuffer.frameLength * PCMBuffer.format.streamDescription.pointee.mBytesPerFrame))
        let data = Data.init(bytes: channels[0], count: Int(PCMBuffer.frameLength * PCMBuffer.format.streamDescription.pointee.mBytesPerFrame))
        return data
    }
    
    static func dBFS_convertTo_dB (dBFSValue: Float) -> Float
    {
       var level:Float = 0.0
        let peak_bottom: Float = VBAudioEngine.minimalVoiceDBLevel // dBFS -> -160..0   so it can be -80 or -60

       if dBFSValue < peak_bottom
       {
           level = 0.0
       }
       else if dBFSValue >= 0.0
       {
           level = 1.0
       }
       else
       {
           let root:Float              =   2.0
           let minAmp:Float            =   powf(10.0, 0.05 * peak_bottom)
           let inverseAmpRange:Float   =   1.0 / (1.0 - minAmp)
           let amp:Float               =   powf(10.0, 0.05 * dBFSValue)
           let adjAmp:Float            =   (amp - minAmp) * inverseAmpRange

           level = powf(adjAmp, 1.0 / root)
       }
       return level
    }
    
    static func scaledPower(power: Float) -> Float {

          guard power.isFinite else { return 0.0 }

          if power < VBAudioEngine.minimalVoiceDBLevel {
             return 0.0
          } else if power >= 1.0 {
             return 1.0
          } else {
             return (abs(VBAudioEngine.minimalVoiceDBLevel) - abs(power)) / abs(VBAudioEngine.minimalVoiceDBLevel)
          }
    }
     
     //MARK: -
     
     private func audioMetering(buffer: AVAudioPCMBuffer) {
         
         let channelDataValue = buffer.floatChannelData!.pointee
         let channelDataValueArray = stride(from: 0, to: Int(buffer.frameLength), by: buffer.stride).map{Float(channelDataValue[$0])/255.0}
    
         //var rms: Float = 0.0 //import Accelerate
         //vDSP_meamgv(channelDataValueArray, 1, &rms, UInt(buffer.frameLength))
         var rms: Float = 0.0
         if buffer.frameLength != 0 {
            rms = sqrt(channelDataValueArray.map{$0 * $0}.reduce(0, +)/Float(buffer.frameLength))
         }
         averagePowerPeakForChannel = rms
     }
     
     
     @objc public func updateMeter()
     {
        guard let player = self.player else {
            return
        }
        
        player.updateMeters()
        let power = player.averagePower(forChannel: 0)

        self.delegate?.audioInputMeterDidUpdate?(peakLevel:power, db: true)
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
         stop()
         _updater?.invalidate()
     }
}

extension VBAudioEngine : AVAudioPlayerDelegate{
 
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
        delegate?.audioFinished(flag, nil)
    }

    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?){
        delegate?.audioFinished(false, error)
    }
}
