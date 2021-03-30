//
//  VoiceViewModel.swift
//  VoiceBox
//
//  Created by Dmitry on 28.07.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import CocoaLumberjack
import Bond

class VBAssistantViewModel {

    let inputText = Observable<String>("")
    
    var onMessagesTextRecieved: ((_ text: String, _ isVoiceBox: Bool)->())?
    var onLogTextRecieved: ((_ text: String)->())?
    var onErrorReceived: ((_ text: String)->())?
    var onChangeBusy: ((_ busy: Bool)->())?
    var onReceiveVoice: ((_ peakLevel: Float)->())?
    var onStartVoice: (()->())?
    var onStopVoice: (()->())?
    
    private var _lastVoiceMessage: String = ""
    private var _isNeedsOpenQuestion: Bool = false
    private var _synthesizer: VBSpeechSynthesizerProtocol{
        return VoiceBoxManager.sharedInstance.speechSynthesizer
    }
    private var _speechRecognizer: VBSpeechRecognizerProtocol{
        return VoiceBoxManager.sharedInstance.speechRecognizer
    }
    
    init() {
    
        VoiceBoxManager.sharedInstance.speechSynthesizerDelegate = self
        
        NotificationCenter.default.addObserver(self,
                                                  selector: #selector(applicationEnterBackground),
                                                  name: UIApplication.willEnterForegroundNotification,
                                                  object: nil)
        VoiceBoxManager.sharedInstance.delegate = self
    }
    
    //MARK: -
    
    @objc private func applicationEnterBackground(){
        stopSynthesize()
    }
    
    private func stopSynthesize(){
        onChangeBusy?(false)
        _synthesizer.stopSynthesize()
        onStopVoice?()
    }
    
    private func sythesizeVoice(text: String, showText: Bool){
          
        onChangeBusy?(true)
        onStartVoice?()
          
        _synthesizer.sythesizeVoice(text: text) { [weak self] (error) in
            
              self?.onChangeBusy?(false)
                                      
              if let err = error {
                  self?.onLogTextRecieved?(err.localizedDescription)
              }else if showText == true {
                   self?.onMessagesTextRecieved?("VoiceBox: " + text, true)
              }
          }
      }
    
    //MARK: -
    
    func start(){
        VoiceBoxManager.sharedInstance.start()
    }
    
    func playLastMessage(){
        if _lastVoiceMessage.count > 0 {
            sythesizeVoice(text: _lastVoiceMessage, showText: false)
        }
    }
    
    private func stopVoiceRecognition(){
        _speechRecognizer.finishRecognize()
        onStopVoice?()
        sendText(text: inputText.value)
    }
    
    func stop(){
        stopSynthesize()
        stopVoiceRecognition()
    }
    
    func sendText(text: String){
        if (inputText.value.count > 0){
            onMessagesTextRecieved?( NSLocalizedString("Вы: ", comment: "") + text, false)
            VoiceBoxManager.sharedInstance.processUserText(text: text)
            inputText.value = ""
        }
    }
    
    //MARK: -
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.willEnterForegroundNotification,
                                                  object: nil)
    }
}

extension VBAssistantViewModel : VoiceBoxManagerDelegate {
    
    func errorOccured(errorMessage: String) {
        onErrorReceived?(errorMessage)
    }
    
    func textRecieved(text: String){
        self.onMessagesTextRecieved?("VoiceBox: " + text, true)
    }
    
    func answerRecieved(text: String) {
        _lastVoiceMessage = text
        sythesizeVoice(text: text, showText: true)
        _isNeedsOpenQuestion = false
    }
    
    func newsReceived(news: VBNews){
        let description = news.description
        var text = " \(news.title) - \(description)"
        if let source = news.source{
           text += " \(source)."
        }
        _lastVoiceMessage = text
        _isNeedsOpenQuestion = true
        sythesizeVoice(text: text, showText: true)
    }

}

//MARK: VBAudioInputDelegate
extension VBAssistantViewModel: VBAudioInputDelegate{

    func audioInputMeterDidUpdate(peakLevel: Float, db: Bool){
        onReceiveVoice?( db == true ? VBAudioEngine.scaledPower(power: peakLevel) : peakLevel)
    }

    func audioFinished(_ success: Bool, _ error: Error?){
        onStopVoice?()
        if let err = error {
            onLogTextRecieved?(err.localizedDescription)
        }
        if _isNeedsOpenQuestion == true,
            VoiceBoxManager.sharedInstance.isLastLinkExist == true {
            sythesizeVoice(text: NSLocalizedString("Открыть ссылку?", comment: ""), showText: false)
        }
        _isNeedsOpenQuestion = false
    }
}

extension VBAssistantViewModel: VBVoiceControllerDelegate{
    
    func voiceRecognized(text: String) {
        inputText.value = text
        sendText(text: text)
    }
}
