//
//  TimeSelectionBar.swift
//  Created by Luhongbin on 2017/6/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.
//

import UIKit

class TimeSelectionBar: UIView {

    @IBOutlet weak var previousBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var timeSwitchBtn: UIButton!
    @IBOutlet weak var timeScaleBtn: UIButton!

    var currentTime : TimeInterval!{
        didSet{
            let currentDate = Date(timeIntervalSince1970: currentTime) as NSDate
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM"
            self.timeSwitchBtn.setTitle(dateFormatter.string(from: currentDate as Date), for: UIControlState())
            //self.timeSwitchBtn.setTitle(NSDate.dateMonthDayTimeWithDate4(NSDate(timeIntervalSince1970: currentTime)), forState: .Normal)
            
//            //更新按钮状态
//            self.previousBtn.enabled = !NSDate(timeIntervalSince1970: currentTime).isEqualToDateIgnoringTime(NSDate())
//            self.nextBtn.enabled     = !NSDate(timeIntervalSince1970: currentTime).isEqualToDateIgnoringTime(NSDate.dateYesterday())
        }
    }
    var delegate : TimeSelectionBarDelegate?
    
    func initView(_ frame: CGRect) {
//        if #available(iOS 11.0, *) {
//            self.frame = safeAreaLayoutGuide.layoutFrame
//        } else {
            self.frame = frame
//        }
        self.previousBtn.setTitle("Previous", for: UIControlState())
        self.nextBtn.setTitle("Next", for: UIControlState())
        
        
        self.previousBtn.isHidden = true
        self.nextBtn.isHidden = true
        
        currentTime = Date().timeIntervalSince1970
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    @IBAction func previousBtnClick(_ sender: UIButton) {
        if self.nextBtn.isEnabled {
            self.delegate?.didTapNextClick!(currentTime + 86400)
        }
    }
    @IBAction func nextBtnClick(_ sender: UIButton) {
        if self.nextBtn.isEnabled {
            self.delegate?.didTapNextClick!(currentTime - 86400)
        }
    }
    @IBAction func timeSwitchBtnClick(_ sender: UIButton) {
        self.delegate?.didTaptimeSwitchClick!()
    }
    @IBAction func timeScaleBtnClick(_ sender: UIButton) {
        self.delegate?.didTaptimeScaleClick!()
    }
   
}
//MARK:- TimeSelectionBarDelegate
@objc protocol TimeSelectionBarDelegate : NSObjectProtocol{
    
    @objc optional func didTapNextClick(_ nextTime:TimeInterval)
    @objc optional func didTapPreviousNextClick(_ previousTime:TimeInterval)
    @objc optional func didTaptimeSwitchClick()
    @objc optional func didTaptimeScaleClick()
}
