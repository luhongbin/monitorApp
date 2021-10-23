//
//  TimeSelectCollectonView.swift
//  Created by Luhongbin on 2017/6/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.
//

import UIKit
import Foundation

class TimeSelectCollectonView: UIView ,UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var DateTitleLbl: UILabel!
    @IBOutlet var closeBtn: UIButton!
    
    @IBOutlet var timeList: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var backgroundView : UIView?
    
    //默认显示最近30天日期
    //var timeNumber = 0
    
    var selectedTime : TimeInterval = Date().timeIntervalSince1970 //当前选择的时间日期
    var timesData :[TimeInterval] = [TimeInterval]() //日期数据源
    var delegate : TimeSelectCollectonDelegate? //代理
    var isShow = false//是否正在展示
    
    func reload(_ data:[TimeInterval]){
        timesData = data
        timeList.reloadData()
    }
    
    func initView(_ frame: CGRect) {
        self.frame = frame
        self.DateTitleLbl.text = "Date"
        timeList.allowsSelection = true
        timeList.allowsMultipleSelection = false
        timeList.delegate = self
        timeList.dataSource = self
        timeList.register(UINib(nibName: "TimeSelectCell", bundle: nil), forCellWithReuseIdentifier: "TimeSelectCell")
        timeList.reloadData()
        
        if backgroundView == nil {
            backgroundView = UIView(frame: frame)
            backgroundView?.backgroundColor = UIColor.black
            backgroundView?.alpha = 0.5
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(TimeSelectCollectonView.hideTimeSelectionCollectionView))
            tap.cancelsTouchesInView = false
            backgroundView?.addGestureRecognizer(tap)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    @IBAction func closeBtnClick(_ sender: UIButton) {
        self.hideTimeSelectionCollectionView()
    }
    //MARK:Public Action
    func showTimeSelectionCollectionView(_ view: UIView,targetframe: CGRect){
        if !self.isShow {
            print("gunda1")
            print(timesData)
            backgroundView?.frame = view.frame
            backgroundView?.alpha = 0.0
            self.frame = CGRect(x: 0, y: view.frame.height, width: self.frame.width, height: self.frame.height)
            view.addSubview(backgroundView!)
            view.addSubview(self)
            
            UIView.animate(withDuration: 0.25, animations: {
                self.frame = CGRect(x: 0, y: targetframe.minY, width: self.frame.width, height: self.frame.height)
                self.backgroundView?.alpha = 0.5
            }, completion: { a in
                self.isShow = true
            })
        }
    }
    @objc func hideTimeSelectionCollectionView(){
        print("gunda3")
        print(selectedTime)
        self.delegate?.didChooseOneTime!(selectedTime)
        UIView.animate(withDuration: 0.25, animations: {
            self.frame = CGRect(x: 0, y: self.superview!.frame.height, width: self.frame.width, height: self.frame.height)
            self.backgroundView?.alpha = 0.0
        }, completion: { a in
            self.isShow = false
            self.removeFromSuperview()
            self.backgroundView?.removeFromSuperview()
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timesData.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TimeSelectCell! = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeSelectCell", for: indexPath) as? TimeSelectCell
        let time = timesData[indexPath.row]
        let currentDate = Date(timeIntervalSince1970: time) as NSDate
        var timeStr = ""
        let calender = NSCalendar.current
        let dateFormatter = DateFormatter()
        
        if (calender.isDateInToday(currentDate as Date)) {
            timeStr = "Today"
        }
        else if (calender.isDateInYesterday(currentDate as Date)){
            timeStr = "Yesterday"
        }else{
            dateFormatter.dateFormat = "dd/MM/yyyy" ///yyyy
            timeStr=dateFormatter.string(from: currentDate as Date)
        }
        cell.loadCellView(timeStr)
        let hightlight = currentDate as Date==Date(timeIntervalSince1970: selectedTime)
        cell.timeSelectBG.image = UIImage(named: hightlight ? "time_selected_bg" : "time_unselected_bg" )
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell : TimeSelectCell = timeList.cellForItem(at: indexPath) as! TimeSelectCell
        cell.isSelected = true
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let rowIndex = indexPath.row
        let time = timesData[rowIndex]
        self.selectedTime = time
        print("gggg:")
        print(time)
        collectionView.reloadData()
        
        // self.delegate?.didChooseOneTime!(time)
    }
    
}
//MARK:- TimeSelectCollectonDelegate
@objc protocol TimeSelectCollectonDelegate : NSObjectProtocol{
    
    @objc optional func didChooseOneTime(_ time:TimeInterval)
}

