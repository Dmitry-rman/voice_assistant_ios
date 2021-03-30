//
//  VoiceBoxManager.swift
//  VoiceBox
//
//  Created by Dmitry on 29.07.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import Foundation
import CocoaLumberjack
import AVFoundation

enum ResponseTypeEnum : String{
    case message = "message"
    case news = "news"
    case username = "username"
    case openUrl = "open_url"
    case error = "error"
}

protocol VoiceBoxManagerDelegate: class {
   func textRecieved(text: String)
   func answerRecieved(text: String)
   func newsReceived(news: VBNews)
   func errorOccured(errorMessage: String)
}

protocol VoiceBoxManagerProtocol {
    
    var delegate: VoiceBoxManagerDelegate? {get set}
    var userName: String? {get set}
    var isLastLinkExist: Bool {get}
    var speechSynthesizer: VBSpeechSynthesizerProtocol {get}
    var speechSynthesizerDelegate: VBAudioInputDelegate? {get set}
    var speechRecognizerDelegate: VBSpeechRecognizerDelegate? {get set}
    func start()
    func processUserText(text: String)
}

class VoiceBoxManager{
    
    public static let sharedInstance = VoiceBoxManager()
    let musicService: VBMusicServiceProtocol!
    weak var delegate: VoiceBoxManagerDelegate?
    
    private let _audioEngine = AVAudioEngine()
    private var _speechSynthesizer: VBSpeechSynthesizerProtocol!
    private let _assistantProcessors: [VBProcessingProtocol]!
    private var _lastUrl: URL?
    private var _speechRecognizer: VBSpeechRecognizerProtocol!
    
    init() {
        
        _speechSynthesizer = VBAppleSpeechSynthesizer(engine: _audioEngine)
        _speechRecognizer =  VBAppleSpeechRecognizer(engine: _audioEngine)

         musicService = VBAppleMusicPlayer()
 
        //Набор навыков ассистента
        _assistantProcessors = [VBMusicProcessing(musicService: musicService),
                                VBLocalVoiceProcessing(),
                                VBHomeKitProcessing(),
                                VBNewsProcessing(),
                                VBQuotaProcessing(),
                                VBCurrencyProcessing(),//Реализован как заглушка
                                VBWeatherProcessing() //Реализован как заглушка
        ]
        
        try? initAudio()
    }
    
    private func initAudio() throws{
        // Audio session, to get information from the microphone.
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .videoChat)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    private func parseVoiceBoxResponse(_ responseData: [String:Any]? ){
        
        let sorryMessage = "Извини, cпроси меня о чем-нибудь другом?"
        
        guard let jsonData = responseData,
            let typeString = jsonData["type"] as? String,
            let type = ResponseTypeEnum(rawValue: typeString) else {
               self.delegate?.answerRecieved(text: sorryMessage)
               return
        }

        switch type {
        case .username:
            if let name = jsonData["data"] as? String{
               self.userName = name
               DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) { [weak self] in
                   self?.delegate?.answerRecieved(text: "Очень рада, \(name), давай о чем нибудь поговорим?")
               }
               return
            }
            break
        case .message:
            if let textMessage = jsonData["data"] as? String {
                self.delegate?.answerRecieved(text: textMessage)
                return
            }
            break
        case .openUrl:
            if let url = jsonData["data"] as? URL{
                UIApplication.shared.open(url)
                _lastUrl = nil
            }
            break
        case .news:
            if let news = jsonData["data"] as? VBNews{
                 self.delegate?.newsReceived(news: news)
                 if news.url != nil {
                   _lastUrl = news.url
                 }
                 return
            }
            break
         case .error:
            self.delegate?.errorOccured(errorMessage: "Error: " + (jsonData["data"] as? String ?? "Unknown error"))
            return
        }
        
        self.delegate?.answerRecieved(text: sorryMessage)
        self.delegate?.errorOccured(errorMessage: "Ошибка парсинга ответа")
    }
}


extension VoiceBoxManager : VoiceBoxManagerProtocol{
    
    var speechRecognizer: VBSpeechRecognizerProtocol{
        return _speechRecognizer
    }
    
    var isLastLinkExist: Bool{
        return _lastUrl != nil
    }
    
    weak var speechSynthesizerDelegate: VBAudioInputDelegate?{
        get{
            return _speechSynthesizer.delegate
        }
        set{
            _speechSynthesizer.delegate = newValue
        }
    }
    
    weak var speechRecognizerDelegate: VBSpeechRecognizerDelegate?{
        get{
            return _speechRecognizer.delegate
        }
        set{
            _speechRecognizer.delegate = newValue
        }
    }
    
    var userName: String?{
        get{
           return UserDefaults.standard.string(forKey: "userName")
        }
        set{
            UserDefaults.standard.set(newValue, forKey: "userName")
            UserDefaults.standard.synchronize()
        }
    }
    
    var speechSynthesizer: VBSpeechSynthesizerProtocol{
        return _speechSynthesizer
    }
    
    func start(){
        processUserText(text: VBLocalVoiceProcessing.startMessage)
    }
    
    func processUserText(text: String){
        
        DDLogDebug("User: " + text)
        
        let text = text.uppercased()

        if  let url = _lastUrl,
            text.sentenceContainsAny(phrases: "да,открыть,открой") == true {
               parseVoiceBoxResponse(["type" : ResponseTypeEnum.openUrl.rawValue, "data" : url])
        }else{
            for processor in _assistantProcessors {
                let processingResult = processor.processMessage(message: text,
                                                                userName: self.userName,
                                                                completion: { [weak self] (resposeData, errorMessage) in
                    if let message = errorMessage {
                         self?.delegate?.errorOccured(errorMessage: message)
                    }
                    self?.parseVoiceBoxResponse(resposeData)
                })
                if processingResult == true {
                    break
                }
            }
        }
    }
}
