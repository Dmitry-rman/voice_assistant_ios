//
//  VBAccesoryCell.swift
//  VoiceBox
//
//  Created by Dmitry on 31.07.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import UIKit
import HomeKit

class VBAccesoryCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subtitleLabel: UILabel?
    @IBOutlet weak var switchSegment: UISegmentedControl?
    
    var onChangeState: ((_ state: Bool)->())?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func segmentChanged(_ sender: Any){
        onChangeState?(switchSegment?.selectedSegmentIndex != 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
