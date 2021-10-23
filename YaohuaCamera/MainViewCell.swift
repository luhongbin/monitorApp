//
//  MainViewCell.swift
//  LutecCamera
//
//  Created by Luhongbin on 2017/6/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.
//
import UIKit
import MBProgressHUD
import Foundation
import Photos

class MainViewCell: UICollectionViewCell ,TimeSelectionBarDelegate,TimeSelectCollectonDelegate,UIActionSheetDelegate {
    @IBOutlet weak var voiceProgress: GreenProgress!
    @IBOutlet weak var viocecontainer: UIView!
    @IBOutlet weak var screen: DisplayView!
    @IBOutlet weak var screenContainer: UIView!
    @IBOutlet weak var soundButton: UIButton!
    @IBOutlet weak var timeline: UIView!
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var progressBar: ProgressView!
    @IBOutlet weak var width_progressBar: NSLayoutConstraint!
    
    @IBOutlet weak var talkbutton: UIButton!
    @IBOutlet weak var hdsd: UIButton!
    @IBOutlet weak var playbacklabel: UILabel!
    @IBOutlet weak var liveLabel: UILabel!
    @IBOutlet weak var progressContainer: UIView!
    @IBOutlet weak var progressX: NSLayoutConstraint!
    
    @IBOutlet weak var mode: UILabel!
    @IBOutlet weak var alarm: UILabel!
    @IBOutlet weak var record: UILabel!
    @IBOutlet weak var sound: UILabel!
    @IBOutlet weak var screenshot: UILabel!
    var delegate:MainViewCellDelegate?
    var playButton:UIButton!
    var progressLandScape:ProgressView?
    var indicatorLandScape:UIImageView?
    var timeSelectionBar:TimeSelectionBar?
    var timeSelectCollectonView:TimeSelectCollectonView?
    //    var speedButton:UIButton?
    
    @IBOutlet weak var alarmButton: UIImageView!
    @IBOutlet weak var alarmButtonX: NSLayoutConstraint!
    @IBOutlet weak var alarmSettingView: UIView!
    
    @IBOutlet weak var bottombarx: UIView!
    @IBOutlet weak var lampButton: UIImageView!
    @IBOutlet weak var lampButtonX: NSLayoutConstraint!
    @IBOutlet weak var lampSettingView: UIView!
    @IBOutlet weak var holdToTalk: UILabel!
    var app:AppDelegate!
    let playButtonWidth:CGFloat = iPad ? 96:72
    var onTalk = false;
    var timerDelay:Task?
    @IBAction func onTalkDown(_ sender: UIButton) {
        talkbutton.setBackgroundImage(UIImage(named:"voice_bg"),for:.normal)
        timerDelay = delay(0.5){
            self.screen.talk(true)
            self.screen.sound(false)
        }
        if !self.soundButton.isSelected {
            self.soundButton.isSelected = true
            self.soundChange = true
        }
        //self.viocecontainer.bringSubview(toFront: voiceProgress)
        self.viocecontainer.backgroundColor = UIColor.clear
        holdToTalk.text = NSLocalizedString("release_to_listen", comment: "")
        onTalk = true;
    }
    
    var lastSyncTime:TimeInterval = 0
    var soundChange = false
    @IBAction func onTalkUp(_ sender: UIButton) {
        //self.viocecontainer.sendSubview(toBack: voiceProgress)
        talkbutton.setBackgroundImage(UIImage(named:"voice_front"),for:.normal)
        timerDelay?(true)
        screen.talk(false)
        holdToTalk.text = NSLocalizedString("hold_to_talk", comment: "")

        if soundChange {
            self.soundButton.isSelected = false
            screen.sound(true)
            self.soundChange = false
        }
        onTalk = false;
    }
    
    var endTime:DateComponents?
    var startTime:DateComponents?
    var calendar:Calendar!
    
    // 添加所有的手势
    func addGestureRecognizerToView(_ view:UIView){
        print("添加所有的手势")
        // 旋转手势
        //        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: "rotateView:")
        //        view.addGestureRecognizer(rotationGestureRecognizer)
        // 缩放手势
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(MainViewCell.pinchView(_:)))
        view.addGestureRecognizer(pinchGestureRecognizer)
        //        let longPress = UILongPressGestureRecognizer(target: self, action: "longPress:")
        //        longPress.minimumPressDuration = 1
        //        view.addGestureRecognizer(longPress)
        let  panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(MainViewCell.panView(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(MainViewCell.doubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
    }

    func removeGestureRecognizerFromView(_ view:UIView) {
        if let arr = view.gestureRecognizers {
            for item in arr {
                view.removeGestureRecognizer(item)
            }
        }
    }
    
    func rotateView(_ rotationGestureRecognizer:UIRotationGestureRecognizer){
        if let view = rotationGestureRecognizer.view{ // 处理旋转手势
            if (rotationGestureRecognizer.state == UIGestureRecognizerState.began || rotationGestureRecognizer.state == UIGestureRecognizerState.changed) {
                view.transform = view.transform.rotated(by: rotationGestureRecognizer.rotation);
                rotationGestureRecognizer.rotation = 0
            }
        }
    }
    
    @objc func doubleTap(_ doubleTap:UIRotationGestureRecognizer){
        if let view = doubleTap.view{ //双击
            view.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.screenContainer.layer.borderColor = UIColor.black.cgColor
            view.center = CGPoint(x: view.center.x - moveX,y: view.center.y - moveY)
            moveX = 0
            moveY = 0
        }
    }
    
    @objc func pinchView(_ pinchGestureRecognizer:UIPinchGestureRecognizer){
        if let view = pinchGestureRecognizer.view{ // 处理缩放手势
            if (pinchGestureRecognizer.state == UIGestureRecognizerState.began || pinchGestureRecognizer.state == UIGestureRecognizerState.changed) {
                let transform = view.transform.scaledBy(x: pinchGestureRecognizer.scale, y: pinchGestureRecognizer.scale)
                if transform.a > 1 && transform.a < 4 {
                    view.transform = transform
                }
                pinchGestureRecognizer.scale = 1;
            }
        }
    }
    var moveX:CGFloat = 0
    var moveY:CGFloat = 0
    @objc func panView(_ panGestureRecognizer:UIPanGestureRecognizer){
      if panGestureRecognizer.state == UIGestureRecognizerState.ended{ // 处理拖拉手势
            //            self.screenContainer.layer.borderColor = UIColor.blackColor().CGColor
            //            panGestureRecognizer.view?.removeGestureRecognizer(panGestureRecognizer)
      }else{
         if let view = panGestureRecognizer.view{
            if (panGestureRecognizer.state == UIGestureRecognizerState.began || panGestureRecognizer.state == UIGestureRecognizerState.changed) {
                let translation = panGestureRecognizer.translation(in: view.superview)
                moveX = moveX + translation.x
                moveY = moveY + translation.y
                view.center = CGPoint(x: view.center.x + translation.x,y: view.center.y + translation.y)
                panGestureRecognizer.setTranslation(CGPoint.zero, in: view.superview)
                }
            }
        }
    }

    @IBAction func onhd(_ sender: UIButton) {
        Thread.sleep(forTimeInterval: 0.02)

        if hdsd.currentTitle==NSLocalizedString("live_btn_hd", comment: "") {
           hdsd.setTitle(NSLocalizedString("live_btn_sd", comment: ""), for:UIControlState.normal)
            self.screen.play(1)
        } else {
           hdsd.setTitle(NSLocalizedString("live_btn_hd", comment: ""), for:UIControlState.normal)
            self.screen.play(0)
        }
    }
    @IBAction func onSwitchClick(_ sender: UIButton) {
        delegate?.onSwitchButtonClick(self)
        sender.isSelected = !sender.isSelected
//        var snid = ""
        if sender.isSelected {
            playbacklabel.text=NSLocalizedString("view_live", comment: "")
            self.hdsd.isHidden = true
            self.progressContainer.isHidden = false
            self.timeSelectionBar?.isHidden = false
            self.liveLabel.isHidden = true
            //            self.speedButton?.hidden = false
            endTime = calendar.dateComponents(in: TimeZone.autoupdatingCurrent, from: Date())
            endTime?.hour = 23;
            endTime?.minute = 59;
            endTime?.second = 59;
            
            startTime = calendar.dateComponents(in: TimeZone.autoupdatingCurrent, from: Date())
            startTime?.hour = 0;
            startTime?.minute = 0;
            startTime?.second = 0;
            refresh()
            self.screen.search(startTime, end: endTime)
            self.progressX.constant = 0
//            snid = "实时"
        }else{
            playbacklabel.text=NSLocalizedString("play_back", comment: "")

            self.hdsd.isHidden = false
            self.progressContainer.isHidden = true
            self.timeSelectionBar?.isHidden = true
            //            self.speedButton?.hidden = true
            self.liveLabel.isHidden = false
            Thread.sleep(forTimeInterval: 0.02)

            if hdsd.currentTitle==NSLocalizedString("live_btn_hd", comment: "") {
                hdsd.setTitle(NSLocalizedString("live_btn_sd", comment: ""), for:UIControlState.normal)
                self.screen.play(1)
            } else {
                hdsd.setTitle(NSLocalizedString("live_btn_hd", comment: ""), for:UIControlState.normal)
                self.screen.play(0)
            }
//            snid = "回放"
        }
//        self.liveLabel.text=NSLocalizedString("live", comment: "")
//        let action = "播放"
//        addlog(action:action,snid:snid)
//        sleep(2)
    }
    func refresh(_ autoStart:Bool = true){
        self.progressBar.reset(self.startTime!, end: self.endTime!, files: self.screen.timeArray)
        self.progressLandScape?.reset(self.startTime!, end: self.endTime!, files: self.screen.timeArray)
        
        if let arr = self.screen.timeArray {
            if  arr.count == 0 {
                self.progressX.constant = 0
                Thread.sleep(forTimeInterval: 0.02)

                MBProgressHUD.hide(for: self.screenContainer, animated: false)
                let hud = MBProgressHUD.showAdded(to: self.screenContainer, animated: true)
                hud.label.text = NSLocalizedString("EE_DSS_NO_VIDEO", comment: "")
                hud.mode = .text
                hud.label.textColor = UIColor.init(hex: 0x770B2F)
                hud.hide(animated: true, afterDelay: 2)
            }else{
                let start = arr.lastObject as! FileData
                updateProgress((self.progressBar.startlong + TimeInterval(start.stBeginTime))*1000)
                if autoStart {
                    print("zidongkaishi")
                    self.delegate?.onTouchup(self,progress: currentProgress())
                }
                print("shuaxin")
            }
        }

    }
    func  currentProgress() -> CGFloat {
        return -self.progressX.constant/self.progressBar.bounds.width
    }
    
    @IBAction func onScreenShotClick(_ sender: UIButton) {
        let authStatus = PHPhotoLibrary.authorizationStatus()  // 相册权限
        if authStatus == .notDetermined { // 第一次触发授权 alert
            // 权限认证
            PHPhotoLibrary.requestAuthorization { (status:PHAuthorizationStatus) -> Void in
                print(authStatus)
            }
        }
        if authStatus == .restricted && authStatus == .denied {
            let hud = MBProgressHUD.showAdded(to: self.screen, animated: true)
            hud.mode = MBProgressHUDMode.text
            hud.label.text = "Allows access to the photo library for saving the images and videos from device."
            hud.backgroundView.style = .solidColor
            hud.hide(animated: true, afterDelay: 2)
        }

        if  authStatus == .authorized {
            self.screen.shot()
        }
    }

    @IBAction func onSoundClick(_ sender: UIButton) {
        screen.sound(sender.isSelected)
        sender.isSelected = !sender.isSelected
    }
    var getresult = ""
    func refreshStatus(){
        self.liveLabel.text=NSLocalizedString("live", comment: "")
        getresult = UserDefaults.standard.string(forKey: "连灯状态")!
        print("连灯状态",getresult)
        if getresult == "O" || getresult == "d" || getresult == "T" {
            self.liveLabel.text=NSLocalizedString("Offline", comment: "")
        }
        switch device.alarm {
        case .DEFAULT: alarmButtonX.constant = 0
        case .ON: alarmButtonX.constant = ScreenWidth * 0.17
        case .OFF: alarmButtonX.constant = -ScreenWidth * 0.17
        }
        
        switch device.mode {
        case .AlwaysOn: lampButtonX.constant =  ScreenWidth * 0.17
        case .Sensor: lampButtonX.constant =  0
        case .Test:   lampButtonX.constant = -ScreenWidth * 0.17
        case .D2D :break
        }
        Thread.sleep(forTimeInterval: 0.02)

        if device.mode == .Test {
            let _ = (SDK.sharedSDK() as AnyObject).send(CMD.Indicator(true).str, dev: device.sn)
        } else {
            let _ = (SDK.sharedSDK() as AnyObject).send(CMD.Indicator(false).str, dev: device.sn)
        }
        app.onDeviceChange()
    }
    @IBAction func onRecordClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        screen.record(sender.isSelected)
    }
    var device: Device!
    func load(_ device:Device){
        self.device = device
        self.app = UIApplication.shared.delegate as! AppDelegate
        self.hdsd.setTitle(NSLocalizedString("live_btn_sd", comment: ""), for:UIControlState.normal)
        self.liveLabel.text=NSLocalizedString("live", comment: "")
        self.sound.text=NSLocalizedString("sound", comment: "")
        self.screenshot.text=NSLocalizedString("screenshot", comment: "")
        self.record.text=NSLocalizedString("record", comment: "")
        self.playbacklabel.text=NSLocalizedString("play_back", comment: "")
        self.holdToTalk.text = NSLocalizedString("hold_to_talk", comment: "")
        self.mode.text = NSLocalizedString("mode", comment: "")
        self.alarm.text = NSLocalizedString("alarm", comment: "")
        
        if iPhonex { //下边约束
//            let bottom:NSLayoutConstraint = NSLayoutConstraint(item: bottombarx, attribute: NSLayoutAttribute.bottom, relatedBy:NSLayoutRelation.equal, toItem:self.screen, attribute:NSLayoutAttribute.bottom, multiplier:1.0, constant: -24)
//            bottombarx.superview!.addConstraint(bottom)//父控件添加约束
        }
        if iPad {
            self.playbacklabel.font = UIFont(name: "HelveticaNeue-Bold", size: 9)
            self.screenshot.font = UIFont(name: "HelveticaNeue-Bold", size: 9)
            self.record.font = UIFont(name: "HelveticaNeue-Bold", size: 9)
            self.holdToTalk.font = UIFont(name: "HelveticaNeue-Bold", size: 9)
            self.sound.font = UIFont(name: "HelveticaNeue-Bold", size: 9)
        }
        if self.playButton == nil{
            timeFormat.dateFormat = "HH:mm"
            calendar = Calendar.current
            self.screen.load(device.sn,pwd: device.password)
            self.screenContainer.clipsToBounds = true
           
            self.screenContainer.bounds = CGRect(x: 0, y: 0, width: SW, height: SH)
            self.timeline.clipsToBounds = true
            self.playButton = UIButton()
            self.playButton.alpha = 0.6
            self.playButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 12, 0)
            self.playButton.setImage(UIImage(named: "play"), for: UIControlState())
            self.playButton.setImage(UIImage(named: "pause"), for: .selected)
            self.playButton.frame = CGRect(x: (self.screenContainer.bounds.width - playButtonWidth)/2,y: self.screenContainer.bounds.height/2 - playButtonWidth/2,width: playButtonWidth,height: playButtonWidth)
            self.playButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MainViewCell.onPlayButtonClick)))
            self.screenContainer.addSubview(playButton)


            self.alarmSettingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MainViewCell.handelAlarmSettingTap(_:))))
            self.lampSettingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MainViewCell.handelLampSettingTap(_:))))
            self.alarmSettingView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(MainViewCell.handelAlarmSettingPan(_:))))
            self.lampSettingView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(MainViewCell.handelLampSettingPan(_:))))
            self.progressBar.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(MainViewCell.onProgressPan(_:))))
            
            if timeSelectionBar == nil {
                timeSelectionBar = (Bundle.main.loadNibNamed("TimeSelectionBar", owner: self, options: nil)! as NSArray).lastObject as? TimeSelectionBar

                timeSelectionBar?.currentTime = Date().timeIntervalSince1970
                timeSelectionBar?.delegate = self
                self.screenContainer.addSubview(timeSelectionBar!)
                timeSelectionBar?.isHidden = true
//                let insets = screenContainer.frame.safeAreaInsets ?? UIEdgeInsets.zero
//                view1.frame = CGRect(
//                            x: insets.left,
//                                            y: insets.top,
//                                                            width:view.bounds.width - insets.left - insets.right,
//                                                                            height: 200)
                if iPhonex {
                    //                    timeSelectionBar?.initView(CGRect(x: 0, y: screenContainer.frame.height - 36 - 38, width: screenContainer.frame.width, height: 36))
                    timeSelectionBar?.initView(CGRect(x: 0, y: screenContainer.frame.height - 36 , width: screenContainer.frame.width, height: 36))
//                    timeSelectionBar?.timeScaleBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0,0 - 50, 0)
                } else {
                    timeSelectionBar?.initView(CGRect(x: 0, y: screenContainer.frame.height - 36 , width: screenContainer.frame.width, height: 36))
                }
            }
            if timeSelectCollectonView == nil {
                timeSelectCollectonView = (Bundle.main.loadNibNamed("TimeSelectCollectonView", owner: self, options: nil)! as NSArray).lastObject as? TimeSelectCollectonView
                timeSelectCollectonView?.initView(CGRect(x: 0, y: self.screenContainer.frame.maxY + 5, width: self.frame.width, height: self.frame.height - self.screenContainer.frame.maxY - 5))
                timeSelectCollectonView?.delegate = self
            }
        }
        //初始化Progressbar
        progressBar.time_scale = .fifteenMins
        width_progressBar.constant = CGFloat(FifteenMinsTotalWidth)
        progressBar.layoutIfNeeded()
        refreshStatus()
    }
    
    // MARK: - TimeSelectionBarDelegate
    func didTapNextClick(_ nextTime: TimeInterval) {
    }
    func didTapPreviousNextClick(_ previousTime: TimeInterval) {
    }

    func didTaptimeSwitchClick() {
        if  let data =  screen.dateArray {
            self.timeSelectCollectonView?.reload(data.compactMap({($0 as AnyObject).doubleValue}))
        }
        timeSelectCollectonView?.showTimeSelectionCollectionView(self.window!, targetframe: CGRect(x: 0, y: self.screenContainer.frame.maxY + 5 + ( iPhonex ? 88:64 ), width: self.frame.width, height: self.frame.height - self.screenContainer.frame.maxY - 5 - ( iPhonex ? 88:64 )))
    }
    func didTaptimeScaleClick() {
        let percent = currentProgress()
        switch progressBar.time_scale {
        case .fifteenMins:
            progressBar.time_scale = .halfFifteenMins
            width_progressBar.constant = CGFloat(HalfFifteenMinsTotalWidth)
        case .halfFifteenMins:
            progressBar.time_scale = .halfFiveMins
            width_progressBar.constant = CGFloat(HalfFiveMinsTotalWidth)
        case .halfFiveMins:
            progressBar.time_scale = .fifteenMins
            width_progressBar.constant = CGFloat(FifteenMinsTotalWidth)
        }
        progressBar.layoutIfNeeded()
        progressBar.setNeedsDisplay()
        
        self.progressX.constant = CGFloat(-width_progressBar.constant * percent)
    }
    // MARK: - TimeSelectCollectonDelegate
    func didChooseOneTime(_ time: TimeInterval) {
        screen.stop()
        onStop()
        endTime = calendar.dateComponents(in: TimeZone.autoupdatingCurrent, from: Date(timeIntervalSince1970: time))
        endTime?.hour = 23;
        endTime?.minute = 59;
        endTime?.second = 59;
        
        startTime = calendar.dateComponents(in: TimeZone.autoupdatingCurrent, from: Date(timeIntervalSince1970: time))
        startTime?.hour = 0;
        startTime?.minute = 0;
        startTime?.second = 0;
        timeSelectionBar?.currentTime = time
       refresh()
        self.screen.search(startTime, end: endTime)
    }
    
    func resetPlayButtonStatus(){
        Thread.sleep(forTimeInterval: 0.02)

        if screen.isPlaying() {
            onPlay()
        }else{
            onStop()
        }
    }
    
    func onPlay(){
        UIView.animate(withDuration: 0.3, animations: {
            self.playButton.isSelected = true
            self.playButton.frame = CGRect(x: 0,y: self.screenContainer.bounds.height - self.playButtonWidth, width: self.playButtonWidth, height: self.playButtonWidth)
        })
    }
    
    func onStop(){
        MBProgressHUD.hide(for: self.screenContainer, animated: true)
        UIView.animate(withDuration: 0.3, animations: {
            self.playButton.isSelected = false
            self.playButton.frame = CGRect(x: self.screenContainer.bounds.width/2 - self.playButtonWidth/2,y: self.screenContainer.bounds.height/2 - self.playButtonWidth/2,width: self.playButtonWidth,height: self.playButtonWidth)
        })
    }
    
    @objc func onPlayButtonClick(){
        delegate?.onPlayButtonClick(self)
    }
    
    var xDown:CGFloat = 0
    var xBefore:CGFloat = 0
    var onTouch = false;
    var notice:MBProgressHUD?
    let timeFormat = DateFormatter()
    
    @objc func onProgressPan(_ panGestureRecognizer :UIPanGestureRecognizer){//拖动手势。。
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "HH:mm:ss"
        switch panGestureRecognizer.state {
        case .began:
            onTouch = true;
            xDown = panGestureRecognizer.location(in: self.progressContainer).x
            xBefore = self.progressX.constant
            notice = MBProgressHUD.showAdded(to: self.screen, animated: true)
            notice?.mode = .text
            notice?.label.textColor = UIColor.white
            playButton.isHidden = true
            notice?.label.text = timeFormat.string(from: Date(timeIntervalSince1970: self.progressBar.timelong * Double(currentProgress()) + Double(self.progressBar.startlong)))
        case .changed :
            let offset_x = xBefore + panGestureRecognizer.location(in: self.progressContainer).x - xDown //禁止超滑
            if offset_x > 1 || offset_x < -(width_progressBar.constant + 1) {
                return;
            }
            
            self.progressX.constant = CGFloat(offset_x)
            notice?.label.text = timeFormat.string(from: Date(timeIntervalSince1970: self.progressBar.timelong * Double(currentProgress()) + Double(self.progressBar.startlong)))
        case .ended,.cancelled,.failed:
            playButton.isHidden = false
            notice?.hide(animated: true, afterDelay: 0)
            onTouch = false
            self.delegate?.onTouchup(self,progress: currentProgress())
        default:break
        }
        indicatorLandScape?.image = UIImage(named: "pointer_icon") //加了也没效果
        
    }
    
    @objc func onLandScapeProgressPan(_ panGestureRecognizer :UIPanGestureRecognizer){
        if let view = panGestureRecognizer.view{ //拖动手势
            if panGestureRecognizer.state == UIGestureRecognizerState.began{
                view.alpha = 1
                self.indicatorLandScape?.alpha = 1
                onTouch = true
                notice = MBProgressHUD.showAdded(to: self.screen, animated: true)
                notice?.mode = .text
                notice?.label.textColor = UIColor.white
                playButton.isHidden = true
                
            }else if panGestureRecognizer.state == UIGestureRecognizerState.ended || panGestureRecognizer.state == UIGestureRecognizerState.failed || panGestureRecognizer.state == UIGestureRecognizerState.cancelled{
                notice?.hide(animated: true, afterDelay: 0)
                view.alpha = 0.2
                playButton.isHidden = false
                self.indicatorLandScape?.alpha = 0.2
                onTouch = false
                self.delegate?.onTouchup(self, progress: (2*ScreenHeight - view.center.x) / (3*ScreenHeight))
            }
            
            if (panGestureRecognizer.state == UIGestureRecognizerState.began || panGestureRecognizer.state == UIGestureRecognizerState.changed) {
                let translation = panGestureRecognizer.translation(in: view.superview)
                view.center = CGPoint(x: view.center.x + translation.x,y: view.center.y)
                panGestureRecognizer.setTranslation(CGPoint.zero, in: view.superview)
                let progress =  (2*ScreenHeight - view.center.x) / (3*ScreenHeight)
                notice?.label.text = timeFormat.string(from: Date(timeIntervalSince1970: self.progressBar.timelong * Double(progress) + Double(self.progressBar.startlong)))
            }
        }
    }
    func updateProgress(_ current:TimeInterval){ //更新进度条
        if iPhone { //历史初始位置
            let progress_width = self.width_progressBar.constant
            if !onTouch {
                self.progressX.constant = -CGFloat((current/1000.0 - self.progressBar.startlong) / self.progressBar.timelong) * progress_width
                if self.progressLandScape != nil{
                    self.progressLandScape?.center.x = 2*ScreenHeight +  -CGFloat((current/1000.0 - self.progressBar.startlong) / self.progressBar.timelong) * (3*ScreenHeight)
                }
            }
        }
//        if iPad { //历史初始位置
//            let progress_width = self.width_progressBar.constant
//            if !onTouch {
//                self.progressX.constant = -CGFloat((current/1000.0 - self.progressBar.startlong) / self.progressBar.timelong) * progress_width
//                if self.progressLandScape != nil{
//                    self.progressLandScape?.center.x = 2*ScreenHeight +  -CGFloat((current/1000.0 - self.progressBar.startlong) / self.progressBar.timelong) * (3*ScreenHeight)
//                }
//            }
//        }
//    print(self.progressX.constant)
//    print(self.progressLandScape?.center.x)
    }
    // MARK: - UITapGestureRecognizer Action
    @objc func handelAlarmSettingTap(_ tapGestureRecognizer:UITapGestureRecognizer)
    {
        if !self.playButton.isSelected {
            self.onPlay()
            Thread.sleep(forTimeInterval: 0.02)

            if !self.switchButton.isSelected {
                if hdsd.currentTitle==NSLocalizedString("live_btn_hd", comment: "") {
                    hdsd.setTitle(NSLocalizedString("live_btn_sd", comment: ""), for:UIControlState.normal)
                    self.screen.play(1)
                } else {
                    hdsd.setTitle(NSLocalizedString("live_btn_hd", comment: ""), for:UIControlState.normal)
                    self.screen.play(0)
                }
            }
        }
        let point = tapGestureRecognizer.location(in: self.alarmSettingView)
        switch checkStatus(point.x){
        case 0: alarmButtonX.constant = -ScreenWidth * 0.17
        handleAlarmChange(.OFF)
        case 1: alarmButtonX.constant = 0
        handleAlarmChange(.DEFAULT)
        case 2: alarmButtonX.constant = ScreenWidth * 0.17
        handleAlarmChange(.ON)
        default: break
        }
        alarmButton.layoutIfNeeded()
    }
    // MARK: - UITapGestureRecognizer Action
    @objc func handelAlarmSettingPan(_ pan:UIPanGestureRecognizer)
    {
        let point = pan.location(in: self.alarmSettingView)
        switch pan.state {
        case .began:
            break
        case .changed:
            if point.x >= ScreenWidth/2 * 0.16 && point.x <= ScreenWidth/2 * 0.84{
                alarmButtonX.constant = point.x - (ScreenWidth * 0.25)
            }
        case .ended,.failed,.cancelled:
            switch checkStatus(point.x) {
            case 0: alarmButtonX.constant = -ScreenWidth * 0.17
            handleAlarmChange(.OFF)
            case 1: alarmButtonX.constant = 0
            handleAlarmChange(.DEFAULT)
            case 2: alarmButtonX.constant = ScreenWidth * 0.17
            handleAlarmChange(.ON)
            default: break
            }
        default:break
        }
        alarmButton.layoutIfNeeded()
    }

    func checkStatus(_ x:CGFloat) -> Int{
        if x < ScreenWidth/8{
            return 0
        }else if x < ScreenWidth/4 + ScreenWidth/8{
            return 1
        }else {
            return 2
        }
    }
    
    @objc func handelLampSettingTap(_ tapGestureRecognizer :UITapGestureRecognizer)
    {
        if !self.playButton.isSelected {
            self.onPlay()
            Thread.sleep(forTimeInterval: 0.02)

            if !self.switchButton.isSelected {
                if hdsd.currentTitle==NSLocalizedString("live_btn_hd", comment: "") {
                    hdsd.setTitle(NSLocalizedString("live_btn_sd", comment: ""), for:UIControlState.normal)
                    self.screen.play(1)
                } else {
                    hdsd.setTitle(NSLocalizedString("live_btn_hd", comment: ""), for:UIControlState.normal)
                    self.screen.play(0)
                }
            }
        }
        let point = tapGestureRecognizer.location(in: self.lampSettingView) //点按
        switch checkStatus(point.x) {
        case 0:
            lampButtonX.constant = -ScreenWidth * 0.17
            handleModeChange(.Test)
        case 1:
            lampButtonX.constant =  0
            handleModeChange(.Sensor)
        case 2:
            lampButtonX.constant =  ScreenWidth * 0.17
            handleModeChange(.AlwaysOn)
        default: break
        }
        lampButton.layoutIfNeeded()
    }
    
    @objc func handelLampSettingPan(_ pan:UIPanGestureRecognizer){
        let point = pan.location(in: self.lampSettingView)
        switch pan.state {
        case .began:
            break
        case .changed:
            if point.x >= ScreenWidth/2 * 0.16 && point.x <= ScreenWidth/2 * 0.84{
                lampButtonX.constant = point.x - (ScreenWidth * 0.25)
            }
        case .ended,.failed,.cancelled:
            switch checkStatus(point.x) {
            case 0:
                lampButtonX.constant = -ScreenWidth * 0.17
                handleModeChange(.Test)
            case 1:
                lampButtonX.constant =  0
                handleModeChange(.Sensor)
            case 2:
                lampButtonX.constant =  ScreenWidth * 0.17
                handleModeChange(.AlwaysOn)
            default: break
            }
        default:break
        }
        
        lampButton.layoutIfNeeded()
    }
    
    func handleModeChange(_ mode:LampMode){
        Thread.sleep(forTimeInterval: 0.02)

        if mode == .Sensor {
            let _ = (SDK.sharedSDK() as AnyObject).send(CMD.SLevel(device.level).str, dev: device.sn)
        }else{
            let _ = (SDK.sharedSDK() as AnyObject).send(CMD.SMode(mode).str, dev: device.sn)
        }
        self.device.mode = mode
        app.onDeviceChange()
        Thread.sleep(forTimeInterval: 0.02)
        if mode == .Test {
            let _ = (SDK.sharedSDK() as AnyObject).send(CMD.Indicator(true).str, dev: device.sn)
        } else {
            let _ = (SDK.sharedSDK() as AnyObject).send(CMD.Indicator(false).str, dev: device.sn)
        }

        app.onDeviceChange()
        var snid = "a"
        switch mode {
        case .Sensor:
            snid = "Sensor"
        case .Test:
            snid = "Test"
        case .AlwaysOn:
            snid = "AlwaysOn"
        case .D2D:
            snid = "D2D"
        }
        let action = "模式变更"
        addlog(action:action,snid:snid)
    }
    func handleAlarmChange(_ alarm:AlarmMode){
        Thread.sleep(forTimeInterval: 0.02)
        self.device.alarm = alarm
        let _ = (SDK.sharedSDK() as AnyObject).send(CMD.Alarm(alarm == .ON).str, dev: device.sn)
        Thread.sleep(forTimeInterval: 0.02)
        let _ = (SDK.sharedSDK() as AnyObject).setAlarm(alarm == .DEFAULT || alarm == .ON, sn: self.device.sn,name: self.device.name)
        Thread.sleep(forTimeInterval: 0.02)
        let _ = (SDK.sharedSDK() as AnyObject).beep(self.device.sn,on: alarm == .ON)

        app.onDeviceChange()
        var snid = "a"
        switch alarm {
        case .ON:
             snid = "b"
        case .DEFAULT:
             snid = "a"
        case .OFF:
             snid = "z"
        }
        let action = "报警方式"
        addlog(action:action,snid:snid)

    }
}
protocol MainViewCellDelegate{
    func onPlayButtonClick(_ cell:MainViewCell)
    func onTouchup(_ cell:MainViewCell,progress:CGFloat)
    func onSwitchButtonClick(_ cell:MainViewCell)
}
