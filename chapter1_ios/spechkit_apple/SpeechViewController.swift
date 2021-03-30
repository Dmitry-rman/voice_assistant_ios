//
//  SpeechViewController.swift
//  speechkit_demo_ios
//
//  Created by Dmitry Kudryavtsev on 24/12/2018.
//  Copyright © 2021 Dmitry Kudryavtsev. All rights reserved.
//

import UIKit
import Speech

class SpeechViewController: UIViewController {
 
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var logTextView: UITextView!
    @IBOutlet weak var speakButton: UIButton!
    @IBOutlet weak var startRecButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    private var _synthesizer = AVSpeechSynthesizer()
    private let _speechRecognizer = SFSpeechRecognizer.init(locale: Locale.init(identifier: "Ru"))
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private var isSpeechRecognitionAvailable: Bool{
        let status = SFSpeechRecognizer.authorizationStatus()
        return (_speechRecognizer?.isAvailable ?? false) && (status == .authorized)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestTranscribePermissions()
        showAvailableSpeechVoices()
    }
    
    //MARK: - actions
    
    @IBAction func speakButtonTap(){
        if let textToSpeech  = inputTextView.text {
           sythesizeVoice(text: textToSpeech)
        }
    }
    
    @IBAction func startRecButtonTap() {
        do{
           try startRecording()
        }catch{
            log(text: error.localizedDescription)
        }
    }
    
    @IBAction func stopButtonTap() {
        stopRecording()
        _synthesizer.stopSpeaking(at: .immediate) //_synthesizer.pauseSpeaking(at: .immediate)
    }
    
    //MARK: - support
    
    private func requestTranscribePermissions() {
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    self?.enableStartRec(isEnabled: true)
                } else {
                    self?.enableStartRec(isEnabled: false)
                    self?.log(text: "Transcription permission was declined.")
                }
            }
        }
    }
    
    private func initAudio() throws{
        // Audio session, to get information from the microphone.
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .measurement)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    private func startRecording() throws {
      
      // Cancel the previous recognition task.
      recognitionTask?.cancel()
      recognitionTask = nil
      
      // The AudioBuffer
      recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
      recognitionRequest!.shouldReportPartialResults = true
      
      // Force speech recognition to be on-device
      if #available(iOS 13, *) {
        recognitionRequest!.requiresOnDeviceRecognition = true
      }
      
      // Actually create the recognition task. We need to keep a pointer to it so we can stop it.
        recognitionTask = _speechRecognizer?.recognitionTask(with: recognitionRequest!) { [weak self] result, error in
        var isFinal = false
        
        if let result = result {
          isFinal = result.isFinal
          self?.log(text: result.bestTranscription.formattedString)
        }
    
        if  error != nil || isFinal {
          // Stop recognizing speech if there is a problem.
            self?.stopRecording()
            if isFinal == false, let errorMessage = error?.localizedDescription{
                self?.log(text: errorMessage)
            }
        }
            
        if isFinal == true{
            self?.log(text: NSLocalizedString("Finish voice recognition..", comment: ""))
        }
      }
      
      // Configure the microphone.
      let recordingFormat = self.audioEngine.inputNode.outputFormat(forBus: 0)
      // The buffer size tells us how much data should the microphone record before dumping it into the recognition request.
      self.audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
           self?.recognitionRequest?.append(buffer)
      }
      
      audioEngine.prepare()
      try audioEngine.start()
        
      enableStartRec(isEnabled: false)
      log(text: NSLocalizedString("Start voice recognition..", comment: ""))
    }
    
    private func stopRecording(){
        
        self.recognitionRequest?.endAudio()
        self.recognitionTask?.finish()
        
        self.audioEngine.stop()
        self.audioEngine.inputNode.removeTap(onBus: 0)
        
        self.recognitionRequest = nil
        self.recognitionTask = nil
        
        enableStartRec(isEnabled: true)
    }
    
    private func enableStartRec(isEnabled: Bool){
        self.startRecButton.isEnabled = isEnabled && isSpeechRecognitionAvailable
        self.startRecButton.alpha = (self.startRecButton.isEnabled == true ? 1.0 : 0.5)
    }
    
    private func showAvailableSpeechVoices(){
         log(text: NSLocalizedString("Available voices:", comment: ""))
         let speechVoices = AVSpeechSynthesisVoice.speechVoices()
         for voice in speechVoices{
            log(text: "\(voice.identifier) - \(voice.name)");
         }
     }
    
    private func sythesizeVoice(text: String) {
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.5
        let  voiceIdentifier = "com.apple.ttsbundle.Milena-premium"
        utterance.voice = AVSpeechSynthesisVoice.init(identifier: voiceIdentifier)
        _synthesizer.speak(utterance)
    }
    
    func log(text: String) {
        DispatchQueue.main.async { [unowned self] in
            self.logTextView.text = self.logTextView.text + text + "\n"
            self.logTextView.scrollRangeToVisible(NSMakeRange(self.logTextView.text.count - 1, 1))
        }
    }
}
