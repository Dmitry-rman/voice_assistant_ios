//
//  VBTextView.swift
//  SberDevices
//
//  Created by Dmitry on 27.07.2020.
//  Copyright © 2020 Dmitry. All rights reserved.

import UIKit

class VBTextView: UITextView {

    private let dataFormatter = DateFormatter()
    
    override func awakeFromNib() {
        setup()
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    fileprivate func setup() {
        
        dataFormatter.dateFormat = "HH:mm:ss"
    }
    
    func print(text: String) {
        self.text = self.text + "\n" + "[" + dataFormatter.string(from: Date()) + "]" + text
        self.scrollRangeToVisible(NSMakeRange(self.text.count - 1, 1))
    }
    
    func print(text: String, color: UIColor, font: UIFont = UIFont.systemFont(ofSize: 17.0)){
        
        let dateString = "\n" + "[" + dataFormatter.string(from: Date()) + "]"
        let string: NSMutableAttributedString = self.attributedText != nil ? NSMutableAttributedString.init(attributedString: self.attributedText!) :  NSMutableAttributedString.init()
        string.append(NSAttributedString.init(string: dateString + text, attributes: [NSAttributedString.Key.foregroundColor : color,
                                                                                      NSAttributedString.Key.font : font]))

        self.attributedText = string
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(100)) { [weak self] in
            self?.scrollRangeToVisible(NSMakeRange(string.string.count - 1, 1))
        }
    }

}
