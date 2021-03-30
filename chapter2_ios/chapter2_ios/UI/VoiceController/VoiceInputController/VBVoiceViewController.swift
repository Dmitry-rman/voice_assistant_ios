
import UIKit
import CocoaLumberjack


class VBVoiceViewController: VBPopupViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var micGradientView: UIView!
    @IBOutlet weak var voiceView: UIView!
    @IBOutlet weak var microphoneButton: UIButton!
    @IBOutlet weak var textResultLabel: UILabel!
    @IBOutlet weak var alertTextLabel: UILabel!

    private var _viewModel: VBVoiceControllerViewModel!
    weak var delegate: VBVoiceControllerDelegate?
    
    class func createViewController(withRecognizer recognizer: VBSpeechRecognizerProtocol) -> VBVoiceViewController{
        
         let controller = R.storyboard.voiceInput.vbSpeachInputViewController()!
         let viewModel = VBVoiceControllerViewModel(recognizer: recognizer)
         controller._viewModel = viewModel
        
         return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        voiceView.layer.cornerRadius = voiceView.bounds.size.height/2
        bind()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        _viewModel.stop()
    }
    
    private func bind(){
        
        _viewModel.isLoaderVisible.bind(to: self.activityIndicator.reactive.isAnimating)
        _viewModel.textResult.bind(to: self.textResultLabel.reactive.text)
        _viewModel.alertText.bind(to: self.alertTextLabel.reactive.text)
        
        _ = _viewModel.state.observeNext {  (newState) in
            
            DispatchQueue.main.async { [weak self] in
                
                self?.voiceLevelProgress(0)
                self?.repeatButton.isHidden = true
                self?.microphoneButton.alpha = 1.0
                self?.microphoneButton.isHidden = false
                self?.voiceView.backgroundColor = R.color.mainColor()
                
                switch newState{
                
                case .notInitialized:
                    self?.microphoneButton.isHidden = true
                    self?.voiceView.backgroundColor = UIColor.lightGray
                    break
                    
                case .ready:
                    break
                    
                case .recognizedVoice:
                    if let text = self?._viewModel.textResult.value, text.count > 0{
                        self?.delegate?.voiceRecognized(text: text)
                        self?.dismiss(animated: true)
                    }
                    break
                
                case .notRecognized:
                    self?.voiceView.backgroundColor = UIColor.red
                    self?.microphoneButton.alpha = 0.6
                    self?.repeatButton.isHidden = false
                    break
                }  
            }
        }
        
        _ = _viewModel.voiceLevel.observeNext(with: { [weak self] (value) in
            DispatchQueue.main.async {
                self?.voiceLevelProgress(value)
            }
        })
        
        _viewModel.start()
    }
    
    //MARK: - actions
    
    @IBAction func closeAction(_ sender: Any?){
        self.dismiss(animated: true)
    }
    
    @IBAction func microphoneAction(_ sender: Any?){
        _viewModel.toggleMicrophone()
    }
    
    @IBAction func repeatAction(_ sender: Any?){
        _viewModel.repeatRecord()
    }
    
    //MARK: - support
    
    private func voiceLevelProgress(_ value: Float){
        
        let treshold: Float = 0.2
        let resultScale = value > treshold ? CGFloat(1.25 - treshold + value*2) : CGFloat(1.0)
        micGradientView.layer.transform = CATransform3DMakeScale(resultScale, resultScale, 1.0)
    }
}

extension VBVoiceViewController : VBVoiceControllerViewModelDelegate{
    
    func showMessage(_ message: String) {
        UIAlertController.show(message: message)
    }

}

protocol VBVoiceControllerDelegate : class {
    func voiceRecognized(text: String)
}

