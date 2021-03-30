

import Foundation
import Bond
import CocoaLumberjack

enum VBVoiceControllerState{
    case notInitialized
    case ready
    case recognizedVoice
    case notRecognized
}

protocol VBVoiceControllerViewModelDelegate : class{
   func showMessage(_ message: String)
}

class VBVoiceControllerViewModel{
    
    let voiceLevel = Observable<Float>(0)
    let alertText = Observable<String>("")
    let textResult = Observable<String>("")

    let state = Observable<VBVoiceControllerState>(.notInitialized)

    weak var delegate: VBVoiceControllerViewModelDelegate?
    
    let isLoaderVisible = Observable<Bool>(false)
    let isRepeatVisible = Observable<Bool>(false)
   
    private var _recognizer: VBSpeechRecognizerProtocol!
    
    required init(recognizer: VBSpeechRecognizerProtocol) {
        
        _recognizer = recognizer
        
        _ = state.observeNext { [weak self] (value) in
            switch value {
            case .notInitialized:
                self?.alertText.value = NSLocalizedString("Инициализация..", comment: "")
                self?.isRepeatVisible.value = false
                self?.isLoaderVisible.value = true
                break
            case .ready:
                self?.alertText.value = NSLocalizedString("Говорите", comment: "")
                self?.isLoaderVisible.value = false
                self?.isRepeatVisible.value = false
                break
            case .recognizedVoice:
                self?.alertText.value = ""
                self?.isLoaderVisible.value = false
                self?.isRepeatVisible.value = false
                break
            case .notRecognized:
                self?.alertText.value = NSLocalizedString("Вас плохо слышно", comment: "")
                self?.isRepeatVisible.value = true
                self?.isLoaderVisible.value = false
                break
            
            }
        }
        
        VoiceBoxManager.sharedInstance.speechRecognizerDelegate = self
    }
    
    func toggleMicrophone(){
        if state.value != .ready {
            state.value = .ready
            start()
        }
        else{
            _recognizer.finishRecognize()
        }
    }
    
    func repeatRecord(){
        state.value = .ready
        start()
    }
    
    func start(){
        _recognizer.startRecognize(withAnchors: [])
    }
    
    func stop(){
        textResult.value = ""
        _recognizer.cancelRecognize()
    }
}

extension VBVoiceControllerViewModel : VBSpeechRecognizerDelegate{
    
    func didStateChanged(state: VBAppleSpeechRecognizer.SpeechStatus) {
        
        switch state {
        
        case .none:
            self.state.value = .notInitialized
            break
            
        case .calibration:
            self.state.value = .notInitialized
            break
            
        case .recognizing:
            self.state.value = .ready
            break
            
        case .recognized:
            self.state.value = .recognizedVoice
            break
            
        case .unavailable:
            break
        }
    }
    
    func didTimerChanged(timeLeft: Int) {
        DDLogDebug(timeLeft)
    }
    
    func didRecognizeSpeech(results: [String]) {
        
        voiceLevel.value = 0
        
        if results.count > 0 {
            results.forEach { [weak self] text in
                self?.textResult.value = text
            }
        }else{
            state.value = .notRecognized
        }
    }
    
    func didReceiveError(error: Error) {
        
        self.delegate?.showMessage(error.localizedDescription)
        self.isLoaderVisible.value = false
    }
    
    func audioMeterDidUpdate(dB: Float){
        if state.value == .ready {
            voiceLevel.value =  VBAudioEngine.scaledPower(power: dB)
        }
    }
}
