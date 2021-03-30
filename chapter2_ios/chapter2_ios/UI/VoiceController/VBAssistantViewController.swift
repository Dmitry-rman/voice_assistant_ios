//
//  ViewController.swift
//  SberDevices
//
//  Created by Dmitry on 27.07.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import UIKit
import WebKit
import CocoaLumberjack

class VBAssistantViewController: TViewController, UITextFieldDelegate {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var inTextView: VBTextView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var buttonSpeakView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    
    private let _viewModel:  VBAssistantViewModel = VBAssistantViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        _viewModel.stop()
    }

    private func bind(){
        
        _viewModel.onMessagesTextRecieved = { [weak self] (text, isVoiceBox) in
            DispatchQueue.main.async {
                let color = R.color.mainColor()!
                self?.inTextView?.print(text: text, color: isVoiceBox == true ? color : UIColor.black, font: UIFont.systemFont(ofSize: 15.0))
            }
            DDLogDebug(text)
        }
        _viewModel.onErrorReceived = { [weak self] (text) in
            DispatchQueue.main.async {
                self?.inTextView?.print(text: text, color: UIColor.red, font: UIFont.systemFont(ofSize: 15.0))
            }
            DDLogDebug(text)
        }
        _viewModel.onLogTextRecieved = { [weak self] (text) in
            DispatchQueue.main.async {
                self?.inTextView?.print(text: text)
            }
            DDLogDebug(text)
        }
        _viewModel.onChangeBusy = { [weak self] (isBusy) in
            DispatchQueue.main.async {
               if isBusy == true{
                   self?.showBusy()
                   self?.playButton?.isEnabled = false
               }
               else{
                   self?.hideBusy()
                   self?.playButton?.isEnabled = true
               }
            }
        }
        _viewModel.onReceiveVoice = { [weak self] peakLevel in
            DispatchQueue.main.async { [weak self] in
                self?.buttonSpeakView?.alpha = CGFloat(peakLevel)
                UIView.animate(withDuration: 0.2) {
                    self?.buttonSpeakView?.layer.transform = CATransform3DMakeScale(CGFloat(peakLevel), CGFloat(peakLevel), 0)
                }
            }
        }
        
        _viewModel.onStartVoice = { [weak self] in
            self?.playButton?.isEnabled = false
        }
        
        _viewModel.onStopVoice = { [weak self] in
            self?.playButton?.isEnabled = true
        }
    
        _viewModel.inputText.bind(to: inputTextField.reactive.text)
        
        _viewModel.start()
    }
    
    //MARK: - actions
    
    @IBAction func playButtonTap(_ sender: Any){
        _viewModel.playLastMessage()
    }
    
    @IBAction func sendTextButtonTap(_ sender: Any){
        if let text = inputTextField.text {
           _viewModel.sendText(text: text)
        }
        inputTextField.resignFirstResponder()
    }

    @IBAction func recordButtonTap(_ sender : Any){
        
        _viewModel.stop()
        
        self.inTextView.resignFirstResponder()
        
        let controller = VBVoiceViewController.createViewController(withRecognizer: VoiceBoxManager.sharedInstance.speechRecognizer)
        controller.delegate = _viewModel
        
        
        controller.modalPresentationStyle = .overCurrentContext
        self.present(controller, animated: false, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        
        textField.resignFirstResponder()
        return true
    }
}

