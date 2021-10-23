//
//  InductionModelCell.swift
//  LutecCamera
//
//  Created by Luhongbin on 2017/6/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.
//


import UIKit

class InductionModelCell: UITableViewCell {

    @IBOutlet var textLbl: UILabel!
    @IBOutlet var detailLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadView(_ level:Level){
        switch level {
        case .MIDDLE:
            textLbl.text = NSLocalizedString("middle", comment: "")
            detailLbl.text = "适合您日常工作的时候启用"
        case .HIGH:
            textLbl.text = NSLocalizedString("high", comment: "")
            detailLbl.text = "适合您长期外出的时候启用。"
        case .LOW:
            textLbl.text = NSLocalizedString("low", comment: "")
            detailLbl.text = "适合您在家的时候启用。"
        case .CUSTOM:
            textLbl.text = NSLocalizedString("custom", comment: "")
            detailLbl.text = ""
        }

    }
    
}
