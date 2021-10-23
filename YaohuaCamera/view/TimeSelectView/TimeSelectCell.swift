//
//  TimeSelectCell.swift
//  Created by Luhongbin on 2017/6/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.

import UIKit

class TimeSelectCell: UICollectionViewCell {
    
    @IBOutlet weak var timeSelectBG: UIImageView!
    @IBOutlet weak var timeSelectLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    func loadCellView(_ time:String){
        self.timeSelectLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.timeSelectLbl.numberOfLines = 0
        if time == "Today"  {
            self.timeSelectLbl.text = time
        }else if time == "Yesterday"{
            self.timeSelectLbl.text = time
        }else{
            self.timeSelectLbl.text = (time as NSString).substring(to: 5) + "\n" + (time as NSString).substring(from: 6)
        }
        print("time:",time)
        self.timeSelectLbl.adjustsFontSizeToFitWidth = true
    }
}

