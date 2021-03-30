//
//  VBSpeechProtocol.swift
//  VoiceBox
//
//  Created by Dmitry on 05.08.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

internal protocol VBSpeechSynthesizerProtocol {
    func sythesizeVoice(text: String, completion: ((_ error: Error?)->())?)
    func pauseSpeaking()
    func stopSynthesize()
    var delegate: VBAudioInputDelegate? {get set}
}

internal  protocol VBSpeechRecognizerProtocol{
    func startRecognize(withAnchors anchors: [String])/// Start streaming the microphone data to the speech recognizer to recognize it live.
    func finishRecognize()/// Finish the speech recognition.
    func cancelRecognize()///Cancels the speech recognition.
    var maxRecordTime: Int? {get}
    var delegate: VBSpeechRecognizerDelegate? {get set}
}

internal protocol VBSpeechSynthesizerDelegate {
    func audioMeterDidUpdate(peakLevel: Float)
}

internal  protocol VBSpeechRecognizerDelegate: class {
    func didStateChanged(state: VBAppleSpeechRecognizer.SpeechStatus)
    func didTimerChanged(timeLeft: Int)
    func didRecognizeSpeech(results: [String])
    func didReceiveError(error: Error)
    func audioMeterDidUpdate(dB: Float)
}
