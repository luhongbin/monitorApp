//
//  SettingViewCell.swift
//  LutecCamera
//
//  Created by Luhongbin on 2017/6/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.
//


import UIKit

class SettingViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var startLabel: UILabel!
    @IBOutlet var endLabel: UILabel!
    @IBOutlet var slider: UISlider!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
//        titleLabel.text=NSLocalizedString("Lux", comment: "")
//        startLabel.text=NSLocalizedString("short", comment: "")
//        endLabel.text=NSLocalizedString("high", comment: "")
        // Configure the view for the selected state
    }
    
}
