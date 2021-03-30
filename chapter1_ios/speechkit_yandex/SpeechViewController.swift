//
//  SpeechViewController.swift
//  speechkit_demo_ios
//
//  Created by Dmitry Kudryavtsev on 24/12/2018.
//  Copyright © 2021 Dmitry Kudryavtsev. All rights reserved.
//

import UIKit

class SpeechViewController: UIViewController, UITextViewDelegate{
 
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var logTextView: UITextView!
    @IBOutlet weak var speakButton: UIButton!
    @IBOutlet weak var startRecButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    private var _recognizer: YSKOnlineRecognizer?
    private var _vocalizer: YSKOnlineVocalizer?
    
    let kYandexSpeechKitSDKAPIKey = "YOUR API KEY" //ключ доступа к API
    
    private var _isSpeechRecognitionAvailable = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        YSKSpeechKit.sharedInstance().apiKey = kYandexSpeechKitSDKAPIKey
        YSKSpeechKit.sharedInstance().logLevel = .error
        if let uuidString = UIDevice.current.identifierForVendor?.uuidString{
           YSKSpeechKit.sharedInstance().uuid = uuidString
        }
        
        enableStartRec(isEnabled: false)
        
        DispatchQueue.global(qos: .default).async { [unowned self] in
            var prepareErrorReson: String?
            do {
                // This process could take much time, so it's recommended to call this method in background thread.
                try YSKAudioSessionHandler.sharedInstance().activateAudioSession()
            }
            catch let error {
                prepareErrorReson = error.localizedDescription
            }
            
            if let errorReson = prepareErrorReson {
                DispatchQueue.main.async { [weak self] in
                    let alertController = UIAlertController.init(title: NSLocalizedString("Error", comment: ""),
                                                                 message: errorReson,
                                                                 preferredStyle: .alert)
                    self?.present(alertController, animated: true, completion: nil)
                    self?.log(text: errorReson)
                }
            } else {
                self.createVocalizer()
                self.createRecognizer()
                DispatchQueue.main.async { [weak self] in
                   self?.enableStartRec(isEnabled: true)
                }
            }
        }
        
    }

    //MARK: - Actions
    
    @IBAction func speakButtonTap(){
        _vocalizer?.synthesize(inputTextView.text, mode: .append)
    }
    
    @IBAction func startRecButtonTap() {
        log(text: NSLocalizedString("Connecting..", comment: ""))
        _recognizer?.startRecording()
    }
    
    @IBAction func stopButtonTap() {
        _recognizer?.stopRecording()
    }
    
    //MARK: - support
    
    private func createVocalizer() {
        
        let settings = YSKOnlineVocalizerSettings(language: YSKLanguage.russian())
        //Optional settings
        settings.voice = YSKVoice.ermil()
        settings.emotion = YSKEmotion.good()

        _vocalizer = YSKOnlineVocalizer(settings: settings)
        _vocalizer?.delegate = self
        _vocalizer?.prepare()
    }
    
    private func createRecognizer(){

        let settings = YSKOnlineRecognizerSettings(language: YSKLanguage.russian(), model: YSKOnlineModel.queries())
        //Optional settings
        settings.disableAntimat = true
        settings.enablePunctuation = false

        _recognizer = YSKOnlineRecognizer(settings: settings)
        _recognizer?.delegate = self
        _recognizer?.prepare()
        _isSpeechRecognitionAvailable = true
    }
    
    private func enableStartRec(isEnabled: Bool){
        self.startRecButton.isEnabled = isEnabled && _isSpeechRecognitionAvailable
        self.startRecButton.alpha = (self.startRecButton.isEnabled == true ? 1.0 : 0.5)
    }
    
    func log(text: String) {
        DispatchQueue.main.async { [unowned self] in
            self.logTextView.text = self.logTextView.text + text + "\n"
            self.logTextView.scrollRangeToVisible(NSMakeRange(self.logTextView.text.count - 1, 1))
        }
    }

    //MARK: - UITextViewDelegate
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
}

extension SpeechViewController : YSKVocalizerDelegate{
    
    func vocalizer(_ vocalizer: YSKVocalizing, didReceivePartialSynthesis synthesis: YSKSynthesis) {
        log(text: "Synthesis: " + synthesis.description)
    }

    func vocalizerDidStartPlaying(_ vocalizer: YSKVocalizing) {
        log(text: "Start playing")
    }

    func vocalizerDidFinishPlaying(_ vocalizer: YSKVocalizing) {
        log(text: "Finish playing")
    }

    func vocalizer(_ vocalizer: YSKVocalizing, didFailWithError error: Error) {
        log(text: error.localizedDescription)
    }
}

extension SpeechViewController : YSKRecognizerDelegate{
    
    func recognizerDidStartRecording(_ recognizer: YSKRecognizing) {
        log(text: "Start recording...")
        progressView.progress = 0.0
    }
    
    func recognizerDidFinishRecording(_ recognizer: YSKRecognizing) {
        log(text: "Finish recording")
        progressView.progress = 0.0
    }
    
    func recognizer(_ recognizer: YSKRecognizing, didReceivePartialResults results: YSKRecognition, withEndOfUtterance endOfUtterance: Bool) {
        log(text: "Hypotheses: " + results.description)

        if endOfUtterance {
            log(text: "Best result: " + results.bestResultText);
        }
    }
    
    func recognizerDidFinishRecognition(_ recognizer: YSKRecognizing) {
        log(text: "Finish recognition process")
    }
    
    func recognizer(_ recognizer: YSKRecognizing, didUpdatePower power: Float) {
        progressView.progress = power
    }
    
    func recognizer(_ recognizer: YSKRecognizing, didFailWithError error: Error) {
        log(text: error.localizedDescription)
    }
}
