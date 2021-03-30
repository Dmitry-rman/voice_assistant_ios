//
//  UIColor+random.swift
//  VRTimeMonitor
//
//  Created by Dmitry on 15.05.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import UIKit
import Foundation

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(
           red:   .random(),
           green: .random(),
           blue:  .random(),
           alpha: 1.0
        )
    }
}
