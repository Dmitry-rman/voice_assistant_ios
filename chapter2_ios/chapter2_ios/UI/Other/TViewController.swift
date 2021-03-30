//
//  TViewController.swift
//  TrackerMonitor
//
//  Created by Dmitry on 21.03.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import UIKit
import MBProgressHUD

class TViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @objc func showBusy(){
        let hud = MBProgressHUD.showAdded(to: self.view, animated:  true)
        hud.bezelView.style = .solidColor
        hud.bezelView.backgroundColor =  UIColor.clear
        hud.contentColor = R.color.mainColor()
    }
    
    @objc func hideBusy(){
        MBProgressHUD.hide(for: self.view, animated:  true)
    }

   func showAlertController(message: String){
        UIAlertController.show(message: message)
    }
    
   func showAlertController(title: String, message: String, completion: (()->())?){
        UIAlertController.show(message: message, title: title, completion: completion)
   }

}
