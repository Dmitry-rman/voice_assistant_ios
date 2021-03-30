//
//  HSpeechEngine.swift
//  Hallo
//
//  Created by Dmitry on 12/08/2019.
//  Copyright © 2019 Dmitry. All rights reserved.
//

import Foundation
import Speech
import CocoaLumberjack

public class VBAppleSpeechRecognizer{
    
    private var _soundLevelProcessor: VBVoiceLevelDetectorProtocol = VBVoiceLevelDetector()
    
    public enum SpeechStatus {
        case none
        case calibration
        case recognizing
        case recognized
        case unavailable
    }
    
    let speechRecognizer = SFSpeechRecognizer.init(locale: Locale.init(identifier: "Ru"))
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    var status = SpeechStatus.unavailable{
        didSet{
            self.delegate?.didStateChanged(state: self.status)
        }
    }
    
    private var anchors: [String] = []
    private var timerLeftValue = 0
    private var timer: Timer?
    private weak var _delegate: VBSpeechRecognizerDelegate?{
        didSet{
            _delegate?.didStateChanged(state: self.status)
        }
    }
    
    let _audioEngine: AVAudioEngine!
    
    init(engine: AVAudioEngine) {
    
        _audioEngine = engine
        _soundLevelProcessor.delegate = self
        requestAuthorization()
    }
    
    private func requestAuthorization(){
        SFSpeechRecognizer.requestAuthorization { status in
            OperationQueue.main.addOperation {
                switch status {
                case .authorized:
                    self.status = .none
                default:
                    self.status = .unavailable
                }
            }
        }
    }
    
    private func startTimer(){
        stopTimer()
        if let maxTime = self.maxRecordTime {
          self.timerLeftValue = maxTime
          timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerFire), userInfo: nil, repeats: true)
          self.delegate?.didTimerChanged(timeLeft: timerLeftValue)
        }
    }
    
    @objc private func timerFire(){
        
        timerLeftValue -= 1
        
        if timerLeftValue == 0 {
           // stopRecognize()
        }
        
        self.delegate?.didTimerChanged(timeLeft: timerLeftValue)
    }
    
    private func stopTimer(){
        timer?.invalidate()
        timer = nil
    }
}

extension VBAppleSpeechRecognizer : VBSpeechRecognizerProtocol {

   var delegate: VBSpeechRecognizerDelegate? {
        get{
            return _delegate
        }
        set{
            _delegate = newValue
        }
    }
    
    var maxRecordTime: Int? {
        return 60
    }
    
    
    func startRecognize(withAnchors anchors: [String] = []){
    
        _soundLevelProcessor.resetVoice()
        if _soundLevelProcessor.isCalibrated == false {
            status = .calibration
        }
        
        // Cancel the previous recognition task.
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // The AudioBuffer
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest?.shouldReportPartialResults = true
        
        self.anchors = anchors
                   
        DDLogDebug("start recognize")
        // Analyze the speech
        recognitionTask?.cancel()

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest!){[weak self] result, error in
                   if let result = result {
                
                       var recognitions: [String] = []
                       var newRecognition = ""
                       result.bestTranscription.segments.forEach({ (segment) in
                           if anchors.contains(segment.substring){
                               recognitions.append(newRecognition)
                               newRecognition = segment.substring
                           }
                           else{
                               newRecognition += " " + segment.substring
                           }
                       })
                       if newRecognition.count > 0 {
                           recognitions.append(newRecognition)
                       }
                   
                      if self?.status == .recognizing {
                         self?.delegate?.didRecognizeSpeech(results:  recognitions)
                      }
                   } else if let error = error {
                       self?.delegate?.didReceiveError(error: error)
                   }
        }
               

        let recordingFormat = self.audioEngine.inputNode.outputFormat(forBus: 0)
        self.audioEngine.inputNode.removeTap(onBus: 0)
        // The buffer size tells us how much data should the microphone record before dumping it into the recognition request.
        self.audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
             self?.recognitionRequest?.append(buffer)
             if let dBlevel = self?.avgPowerFromAudiobuffer(buffer: buffer){
                 self?._delegate?.audioMeterDidUpdate(dB: dBlevel)
                 self?._soundLevelProcessor.process(level: dBlevel)
             }
        }

        audioEngine.prepare()
        do {
            if (audioEngine.isRunning == false){
               try audioEngine.start()
            }
            startTimer()
            if _soundLevelProcessor.isCalibrated == true {
               self.status = .recognizing
            }
        } catch {
            status = .unavailable
            self.delegate?.didReceiveError(error: error)
        }
        
   }
    
   func cancelRecognize() {
    stopTimer()
    recognitionRequest?.endAudio()
    self.recognitionRequest = nil

    recognitionTask?.finish()
    self.recognitionTask = nil
   
    //self.audioEngine.stop()
    self.audioEngine.inputNode.removeTap(onBus: 0)
   }
    
  func finishRecognize(){
    
    if (status != .recognized){
       status = .recognized
    }
    cancelRecognize()
  }
    
    private func avgPowerFromAudiobuffer(buffer: AVAudioPCMBuffer) -> Float{
        
        let channelDataValue = buffer.floatChannelData!.pointee
        let channelDataValueArray = stride(from: 0, to: Int(buffer.frameLength), by: buffer.stride).map{Float(channelDataValue[$0])}
   
        var rms: Float = 0.0
        if buffer.frameLength != 0 {
           rms = sqrt(channelDataValueArray.map{$0 * $0}.reduce(0, +)/Float(buffer.frameLength))
        }
        let avgPower = 20 * log10 (rms)
        let value = avgPower.isFinite == true ? avgPower : -80
        return value
    }
}


extension  VBAppleSpeechRecognizer: VBVoiceLevelDetectorDelegate{
    
    func voiceCalibrated(level: Float) {
        DDLogDebug("Calibrated \(level)")
        self.status = .recognizing
    }
    
    func voiceDisappeared() {
        DDLogDebug("Sound did disappear")
        finishRecognize()
    }
}
