
import UIKit
import CocoaLumberjack

class VBPopupViewController: UIViewController {
    
    private var _popupAnimationDuration: Double = 0.5
    @IBInspectable var popupAnimationDuration: Double{
        get{
            return _popupAnimationDuration
        }
        set{
            _popupAnimationDuration = newValue
        }
    }
    
    @IBOutlet var topContentConstraint: NSLayoutConstraint?
    @IBOutlet var contentView: UIView?
    @IBOutlet var navigationBar: UINavigationBar?
    
    var backgroundView: UIView!
    var popupAnimationEnabled = true
    
    private var isPopupShowed = false

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundView = UIView.init(frame: self.view.frame)
        backgroundView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.79)
        backgroundView.alpha = 0
        self.view.addSubview(backgroundView!)
        self.view.sendSubviewToBack(backgroundView!)
        
        if (UIDevice.current.userInterfaceIdiom == .pad) && (self.modalPresentationStyle == .popover || self.navigationController?.modalPresentationStyle == .popover ||
            self.modalPresentationStyle == .formSheet || self.navigationController?.modalPresentationStyle == .formSheet){
            var bar = navigationBar
            if bar == nil {
                bar = self.navigationController?.navigationBar
            }
            //bar?.backgroundColor = PDAUI.PDAColors.pdaSelectionColor
            bar?.tintColor = UIColor.white
            bar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.init(white: 1.0, alpha: 0.6)]
            //popoverPresentationController?.backgroundColor = PDAUI.PDAColors.pdaSelectionColor
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear( animated)
        if popupAnimationEnabled == true{
          self.topContentConstraint?.constant = self.view.frame.size.height
          self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if(isPopupShowed == false && popupAnimationEnabled == true){
            
            UIView.animate(withDuration: self.popupAnimationDuration,
                           animations: { [weak self] in
                            self?.topContentConstraint?.constant = 0
                            self?.view.layoutIfNeeded()
                            self?.backgroundView?.alpha = 1
            }) { (completed: Bool) in
                
            }
            isPopupShowed = true
        }

    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        
        if popupAnimationEnabled == true{
        
            if(flag == true){
                UIView.animate(withDuration: self.popupAnimationDuration,
                               animations: { [weak self] in
                                self?.topContentConstraint?.constant = (self?.view.frame.size.height)!
                                self?.view.layoutIfNeeded()
                                self?.backgroundView?.alpha = 0
                }) { (completed: Bool) in
                    super.dismiss(animated: false, completion: completion)
                }
            }
            else{
                super.dismiss(animated: false, completion: completion)
            }
        }
        else{
             super.dismiss(animated: flag, completion: completion)
        }
        
    }
    
    deinit {
        DDLogDebug("Deinit " + String(describing: self))
    }

}
