//
//  UIAlertController+Show.swift
//  UIAlertController+Show
//
//  Created by Erik Ackermann on 1/20/16.
//
//

import Foundation
import UIKit
import ObjectiveC

private var alertWindowAssociationKey: UInt8 = 0

extension UIAlertController {

    var alertWindow: UIWindow? {
        get {
            return objc_getAssociatedObject(self, &alertWindowAssociationKey) as? UIWindow
        }
        set(newValue) {
            objc_setAssociatedObject(self, &alertWindowAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    @objc public func show() {
        show(true)
    }

    @objc public func show(_ animated: Bool) {
        show(animated, completion: nil)
    }
  
    @objc static  func show(message: String, title: String? = nil, completion: (()->())? = nil) {
        let controller = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: nil))
        controller.show(true, completion: completion)
    }
    
    @objc public func show(_ animated: Bool, completion: (() -> Void)? = nil) {
        self.alertWindow = UIWindow(frame: UIScreen.main.bounds)
        self.alertWindow?.rootViewController = UIViewController()
        self.alertWindow?.windowLevel = UIWindow.Level.alert + 1
        self.alertWindow?.makeKeyAndVisible()
        self.alertWindow?.rootViewController?.present(self, animated: animated, completion: completion)
    }
    
    @objc public func show(_ animated: Bool, window: UIWindow? = nil, completion: (() -> Void)? = nil) {
        if window == nil {
            self.alertWindow = UIWindow(frame: UIScreen.main.bounds)
        }
        else{
            self.alertWindow = window
        }
        
        self.alertWindow?.rootViewController = UIViewController()
        self.alertWindow?.windowLevel = UIWindow.Level.alert + 1
        self.alertWindow?.makeKeyAndVisible()
        self.alertWindow?.rootViewController?.present(self, animated: animated, completion: completion)
    }

    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.alertWindow?.isHidden = true
        self.alertWindow = nil
    }
}
